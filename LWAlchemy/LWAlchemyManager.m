//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAlchemy
//  See LICENSE for this sample’s licensing information
//


#import "LWAlchemyManager.h"
#import <CoreData/CoreData.h>
#import "NSObject+LWAlchemy.h"

@interface LWAlchemyManager ()

@property (nonatomic,strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic,strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,strong) NSManagedObjectContext* parentContext;
@property (nonatomic,copy) NSString* executableFile;

@end


@implementation LWAlchemyManager


#pragma mark - CURD

- (void)insertEntityWithClass:(Class)cls JSON:(id)json save:(BOOL)saved completion:(Completion)completeBlock {
    [cls entityWithJSON:json context:self.managedObjectContext];
    if (!saved) {
        completeBlock();
        return;
    }
    [self saveContext:completeBlock];
}

- (void)insertEntityWithClass:(Class)cls JSON:(id)json completion:(Completion)completeBlock {
    [cls entityWithJSON:json context:self.managedObjectContext];
    completeBlock();
}


- (void)insertEntitysWithClass:(Class)cls JSONsArray:(NSArray *)jsonArray save:(BOOL)isSave completion:(Completion)completeBlock {
    for (id json in jsonArray) {
        [cls entityWithJSON:json context:self.managedObjectContext];
    }
    if (!isSave) {
        completeBlock();
        return;
    }
    [self saveContext:completeBlock];
}

- (void)insertEntitysWithClass:(Class)cls
                    JSONsArray:(NSArray *)jsonArray
           uiqueAttributesName:(NSString *)uniqueAttributesName
                          save:(BOOL)isSave
                    completion:(Completion)completeBlock {
    __weak typeof(self) weakSelf = self;
    NSManagedObjectContext* ctx = [self createPrivateObjectContext];
    [ctx performBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        for (id json in jsonArray) {
            NSError* error = nil;
            NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(cls) inManagedObjectContext:ctx]];
            if (uniqueAttributesName == nil) {
                return;
            }
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", uniqueAttributesName,
                                      [[strongSelf dictionaryWithJSON:json]objectForKey:uniqueAttributesName]];
            if (predicate) {
                [fetchRequest setPredicate:predicate];
            }
            NSArray* results = [ctx executeFetchRequest:fetchRequest error:&error];
            NSManagedObject* object = [results lastObject];
            if (object) {
                [strongSelf.managedObjectContext performBlockAndWait:^{
                    //objectID是线程安全的
                    [strongSelf updateNSManagedObjectWithObjectID:object.objectID JSON:json];
                }];
            } else {
                [strongSelf.managedObjectContext performBlockAndWait:^{
                    [cls entityWithJSON:json context:strongSelf.managedObjectContext];
                }];
            }
        }
        if (!isSave) {
            [strongSelf.managedObjectContext performBlockAndWait:^{
                completeBlock();
                return ;
            }];
        }
        [strongSelf.managedObjectContext performBlockAndWait:^{
            [strongSelf saveContext:completeBlock];
        }];
    }];
}

- (void)fetchNSManagedObjectWithObjectClass:(Class)objectClass
                                  predicate:(NSPredicate *)predicate
                             sortDescriptor:(NSArray<NSSortDescriptor *> *)sortDescriptors
                                fetchOffset:(NSInteger)offset
                                 fetchLimit:(NSInteger)limit
                                fetchReults:(FetchResults)resultsBlock {
    __weak typeof(self) weakSelf = self;
    NSManagedObjectContext* ctx = [self createPrivateObjectContext];
    [ctx performBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
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
        NSArray* results = [ctx executeFetchRequest:fetchRequest error:&error];
        if (error) {
            [strongSelf.managedObjectContext performBlock:^{
                resultsBlock(@[],error);
            }];
        }
        if ([results count] < 1) {
            [strongSelf.managedObjectContext performBlock:^{
                resultsBlock(@[],nil);
            }];
        }
        NSMutableArray* result_ids = [[NSMutableArray alloc] init];
        for (NSManagedObject* object  in results) {
            [result_ids addObject:object.objectID];
        }
        [strongSelf.managedObjectContext performBlockAndWait:^{
            NSMutableArray* final_results = [[NSMutableArray alloc] init];
            for (NSManagedObjectID* objectID in result_ids) {
                [final_results addObject:[strongSelf.managedObjectContext objectWithID:objectID]];
            }
            resultsBlock(final_results, nil);
        }];
    }];
}


- (void)updateNSManagedObjectWithObjectID:(NSManagedObjectID *)objectID JSON:(id)json {
    NSManagedObject* object = [self.managedObjectContext objectWithID:objectID];
    if ([json isKindOfClass:[NSDictionary class]]) {
        object = [object entity:object modelWithDictionary:json context:self.managedObjectContext];
    } else {
        NSDictionary* dict = [self dictionaryWithJSON:json];
        object = [object entity:object modelWithDictionary:dict context:self.managedObjectContext];
    }
}


- (void)deleteNSManagedObjectWithObjectWithObjectIdsArray:(NSArray<NSManagedObjectID *> *)objectIDs {
    for (NSManagedObjectID* objectID in objectIDs) {
        NSManagedObject* object = [self.managedObjectContext objectWithID:objectID];
        if (object) {
            [self.managedObjectContext deleteObject:object];
        }
    }
}

- (void)backgroundTask {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication* application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    [self saveContext:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}


#pragma mark - Init

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

- (void)saveContext:(Completion)completionBlock {
    __weak typeof(self) weakSelf = self;
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } else {
        [self.parentContext performBlock:^{
            //            NSLog(@"写入到数据库的线程:%@",[NSThread currentThread]);
            __strong typeof(weakSelf) strongSelf = weakSelf;
            __block NSError* inner_error = nil;
            [strongSelf.parentContext save:&inner_error];
            [strongSelf.managedObjectContext performBlock:^{
                completionBlock();
            }];
        }];
    }
}

- (NSManagedObjectContext *)createPrivateObjectContext {
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    __weak typeof(self) weakSelf = self;
    [ctx performBlockAndWait:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [ctx setParentContext:strongSelf.managedObjectContext];
    }];
    return ctx;
}

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
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setParentContext:self.parentContext];
    }
    return _managedObjectContext;
}

- (NSManagedObjectContext *)parentContext {
    if (!_parentContext) {
        _parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        __weak typeof(self) weakSelf = self;
        [_parentContext performBlockAndWait:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [_parentContext setPersistentStoreCoordinator:strongSelf.persistentStoreCoordinator];
            [_parentContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            [_parentContext setUndoManager:nil];
        }];

    }
    return _parentContext;
}


@end
