/*
 https://github.com/waynezxcv/LWAlchemy

 Copyright (c) 2016 waynezxcv <liuweiself@126.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


#import "LWAlchemyManager.h"
#import <CoreData/CoreData.h>
#import "NSObject+LWAlchemy.h"

@interface LWAlchemyManager ()

@property (nonatomic,strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic,strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (strong,nonatomic) NSManagedObjectContext* mainMOC;//主线程Context
@property (strong,nonatomic) NSManagedObjectContext* writeMOC;//用来写入数据到本地的Context，mainMOC的parent

@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundTaskId;
@property (nonatomic,copy) NSString* executableFile;

@end

@implementation LWAlchemyManager

#pragma mark - CURD

- (void)lw_insertEntitysWithClass:(Class)objectClass
                       JSONsArray:(NSArray *)jsonArray
              uiqueAttributesName:(NSString *)uniqueAttributesName
                       completion:(Completion)completeBlock {
    NSManagedObjectContext* ctx = [self createTemporaryBackgroundMoc];
    [ctx performBlock:^{
        for (id json in jsonArray) {
            @autoreleasepool {
                __weak typeof(self) weakSelf = self;
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSError* error = nil;
                NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
                [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(objectClass)
                                                    inManagedObjectContext:ctx]];
                if (!uniqueAttributesName){
                    return;
                }
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", uniqueAttributesName,
                                          [[strongSelf dictionaryWithJSON:json]objectForKey:uniqueAttributesName]];

                if (predicate) {
                    [fetchRequest setPredicate:predicate];
                }
                NSArray* results = [ctx executeFetchRequest:fetchRequest error:&error];
                NSManagedObject* object = [results lastObject];
                if (!object) {
                    object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(objectClass)
                                                           inManagedObjectContext:ctx];
                    if (![json isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* dict = [self dictionaryWithJSON:json];
                        object = [object entity:object modelWithDictionary:dict context:ctx];
                    }
                    else {
                        object = [object entity:object modelWithDictionary:json context:ctx];
                    }

                    [ctx performBlockAndWait:^{
                        //save temporary context
                        NSError* error = nil;
                        if ([ctx hasChanges] && ![ctx save:&error]) {
#if DEBUG
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                            abort();
                        }
                    }];
                }

                else {
                    if (![json isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* dict = [self dictionaryWithJSON:json];
                        object = [object entity:object modelWithDictionary:dict context:ctx];
                    }
                    else {
                        object = [object entity:object modelWithDictionary:json context:ctx];
                    }
                }
            }
        }
        //save temporary context
        NSError* error = nil;
        if ([ctx hasChanges] && ![ctx save:&error]) {
#if DEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            abort();
        }
        [self.mainMOC performBlock:^{
            //save main context
            NSError* error = nil;
            if ([self.mainMOC hasChanges] && ![self.mainMOC save:&error]) {
#if DEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
            completeBlock();
        }];
    }];
}


- (void)lw_fetchEntityWithClass:(Class)objectClass
                      predicate:(NSPredicate *)predicate
                 sortDescriptor:(NSArray<NSSortDescriptor*> *)sortDescriptors
                    fetchOffset:(NSInteger)offset
                     fetchLimit:(NSInteger)limit
                    fetchReults:(FetchResults)resultsBlock {

    __weak typeof(self) weakSelf = self;
    NSManagedObjectContext* ctx = [self createTemporaryBackgroundMoc];
    [ctx performBlock:^{

        NSError* error = nil;
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(objectClass)
                                            inManagedObjectContext:ctx]];
        if (predicate) {
            [fetchRequest setPredicate:predicate];
        }
        if (sortDescriptors != nil && sortDescriptors.count != 0) {
            [fetchRequest setSortDescriptors:sortDescriptors];
        }
        if (offset > 0) {
            [fetchRequest setFetchOffset:offset];
        }
        if (limit > 0) {
            [fetchRequest setFetchLimit:limit];
        }
        NSArray* results = [self.mainMOC executeFetchRequest:fetchRequest error:&error];
        if (error) {
            resultsBlock(@[],error);
        }
        if ([results count] < 1) {
            resultsBlock(@[],nil);
        }
        NSMutableArray* resultIds = [[NSMutableArray alloc] init];
        for (NSManagedObject* object  in results) {
            [resultIds addObject:object.objectID];
        }
        __strong typeof(weakSelf) sself = weakSelf;
        [sself.mainMOC performBlock:^{
            NSMutableArray* finalResults = [[NSMutableArray alloc] init];
            for (NSManagedObjectID* objectID in resultIds) {
                [finalResults addObject:[sself.mainMOC objectWithID:objectID]];
            }
            resultsBlock(finalResults, nil);
        }];
    }];
}

- (void)lw_asyncFetchEntityWithClass:(Class)objectClass
                           predicate:(NSPredicate *)predicate
                      sortDescriptor:(NSArray<NSSortDescriptor*> *)sortDescriptors
                         fetchOffset:(NSInteger)offset
                          fetchLimit:(NSInteger)limit
                         fetchReults:(FetchResults)resultsBlock  NS_AVAILABLE(10_10, 8_0) {

    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(objectClass)
                                        inManagedObjectContext:self.mainMOC]];

    if (predicate) {
        [fetchRequest setPredicate:predicate];

#if DEBUG
        NSLog(@"fetch :%@",predicate);
#endif
    }
    if (sortDescriptors && sortDescriptors.count) {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    if (offset > 0) {
        [fetchRequest setFetchOffset:offset];
    }
    if (limit > 0) {
        [fetchRequest setFetchLimit:limit];
    }
    NSAsynchronousFetchRequest* asycFetchRequest =
    [[NSAsynchronousFetchRequest alloc]
     initWithFetchRequest:fetchRequest
     completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {

         NSMutableArray* finalResults = [[NSMutableArray alloc] init];

         [result.finalResult enumerateObjectsUsingBlock:^(id  _Nonnull obj,
                                                          NSUInteger idx,
                                                          BOOL * _Nonnull stop) {
             [finalResults addObject:obj];
         }];

#if DEBUG
         NSLog(@"fetched object count:%ld",finalResults.count);
#endif
         resultsBlock(finalResults, nil);
     }];

    NSError* error = nil;
    [self.mainMOC executeRequest:asycFetchRequest error:&error];

    if (error) {
        resultsBlock(@[],error);
#if DEBUG
        NSLog(@"fetch request result error : %@", error);
#endif
    }
}


- (NSInteger)lw_batchUpdateWithEntityWithClass:(Class)objectClass
                            propertiesToUpdate:(NSDictionary *)propertiesToUpdate  NS_AVAILABLE(10_10, 8_0){

    NSBatchUpdateRequest* updateRequest = [NSBatchUpdateRequest
                                           batchUpdateRequestWithEntityName:NSStringFromClass(objectClass)];
    updateRequest.resultType = NSUpdatedObjectsCountResultType;

    updateRequest.propertiesToUpdate = propertiesToUpdate;

    NSError* error = nil;
    NSBatchUpdateResult* result = [self.mainMOC executeRequest:updateRequest error:&error];
#if DEBUG
    NSLog(@"batch update count is %ld", [result.result integerValue]);
#endif
    if (error) {
#if DEBUG
        NSLog(@"batch update request result error : %@", error);
#endif
    }
    [self.mainMOC refreshAllObjects];
    return [result.result integerValue];
}

- (void)lw_updateEntityWithObjectID:(NSManagedObjectID *)objectID
                               JSON:(id)json
                         completion:(UpdatedResults)updateResults {
    NSManagedObjectContext* ctx = [self createTemporaryBackgroundMoc];
    [ctx performBlock:^{
        NSManagedObject* object = [ctx objectWithID:objectID];
        if ([json isKindOfClass:[NSDictionary class]]) {
            object = [object entity:object modelWithDictionary:json context:ctx];
        } else {
            NSDictionary* dict = [self dictionaryWithJSON:json];
            object = [object entity:object modelWithDictionary:dict context:ctx];
        }
        //save temporary context
        NSError* error = nil;
        if ([ctx hasChanges] && ![ctx save:&error]) {
#if DEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            updateResults(nil,error);
            abort();
        }
        [self.mainMOC performBlock:^{
            //save main context
            NSError* error = nil;
            if ([self.mainMOC hasChanges] && ![self.mainMOC save:&error]) {
#if DEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                updateResults(nil,error);
                abort();
            }
            NSLog(@"update completion");
            updateResults([self.mainMOC objectWithID:objectID],error);
        }];
    }];
}


- (BOOL)lw_deleteNSManagedObjectWithObjectWithObjectIdsArray:(NSArray<NSManagedObjectID *> *)objectIDs {
    NSManagedObjectContext* ctx = [self createTemporaryBackgroundMoc];
    [ctx performBlock:^{
        for (NSManagedObjectID* objectID in objectIDs) {
            @autoreleasepool {

                NSManagedObject* object = [ctx objectWithID:objectID];
                if (object) {
                    [ctx deleteObject:object];
                }
            }
        }
        //save temporary context
        NSError* error = nil;
        if ([ctx hasChanges] && ![ctx save:&error]) {
#if DEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            abort();
        }
        [self.mainMOC performBlock:^{
            //save main context
            NSError* error = nil;
            if ([self.mainMOC hasChanges] && ![self.mainMOC save:&error]) {
#if DEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }];
    }];
    return YES;
}


- (NSInteger)lw_batchDeleteEntityWithClass:(Class)objectClass
                                 predicate:(NSPredicate *)predicate  NS_AVAILABLE(10_10, 8_0) {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(objectClass)];
    if (predicate) {
        fetchRequest.predicate = predicate;
    }

    NSBatchDeleteRequest* deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    deleteRequest.resultType = NSBatchDeleteResultTypeCount;

    NSError* error = nil;
    NSBatchDeleteResult* result = [self.mainMOC executeRequest:deleteRequest error:&error];
#if DEBUG
    NSLog(@"batch delete request result count is %ld",[result.result integerValue]);
#endif
    if (error) {
#if DEBUG
        NSLog(@"batch delete request error : %@", error);
#endif
    }
    [self.mainMOC refreshAllObjects];
    return [result.result integerValue];
}


#pragma mark - Methods

- (NSManagedObjectContext *)createTemporaryBackgroundMoc {
    NSManagedObjectContext* ctx = [[NSManagedObjectContext alloc]
                                   initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    ctx.parentContext = self.mainMOC;
    return ctx;
}

- (void)backgroundTask {
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
    if (hasApplication) {
        __weak __typeof__ (self) wself = self;
        UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
        self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof (wself) sself = wself;
            if (sself) {
                [app endBackgroundTask:sself.backgroundTaskId];
                sself.backgroundTaskId = UIBackgroundTaskInvalid;
#if DEBUG
                NSLog(@"end background task");
#endif
            }
        }];
    }
#endif
    [self saveToSqlite];
}


- (void)saveToSqlite {
    __weak typeof(self) weakSelf = self;
    [self.mainMOC performBlock:^{
        __strong typeof(weakSelf) sself = weakSelf;
        //save main context
        NSError* error = nil;
        if ([sself.mainMOC hasChanges] && ![sself.mainMOC save:&error]) {
#if DEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            abort();
        }
        [sself.writeMOC performBlock:^{
            NSError* writeError = nil;
            [sself.writeMOC save:&writeError];
#if DEBUG
            NSLog(@"write entity to sqlite in backgournd ==================\nThread:%@",[NSThread currentThread]);
#endif
        }];
    }];
}


#pragma mark - LifeCycle

+ (LWAlchemyManager *)sharedManager {
    static dispatch_once_t onceToken;
    static LWAlchemyManager* sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [[LWAlchemyManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundTask)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundTask)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}


#pragma mark - CoreData Stack

- (NSString *)executableFile {
    if (!_executableFile) {
        _executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    }
    return _executableFile;
}


- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];;
    return _managedObjectModel;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSString* sql = [NSString stringWithFormat:@"%@.sqlite",self.executableFile];
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:sql];
    NSError* error = nil;
    NSString* failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
#if DEBUG
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
        abort();
    }
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)mainMOC {
    if (_mainMOC) {
        return _mainMOC;
    }
    _mainMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainMOC.parentContext = self.writeMOC;
    return _mainMOC;
}

- (NSManagedObjectContext *)writeMOC {
    if (_writeMOC) {
        return _writeMOC;
    }
    _writeMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    __weak typeof(self) weakSelf = self;
    [_writeMOC performBlockAndWait:^{
        __strong typeof(weakSelf) swself = weakSelf;
        [_writeMOC setPersistentStoreCoordinator:swself.persistentStoreCoordinator];
        [_writeMOC setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_writeMOC setUndoManager:nil];
    }];
    return _writeMOC;
}

@end
