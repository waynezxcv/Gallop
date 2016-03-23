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


#import "LWAlchemyCoreDataManager.h"
#import <CoreData/CoreData.h>
#import "NSObject+LWAlchemy.h"
#import "AppDelegate.h"

@interface LWAlchemyCoreDataManager ()

@property (strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong,nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong,nonatomic) NSManagedObjectContext* parentContext;


@property (nonatomic,copy) NSString* executableFile;

@end


@implementation LWAlchemyCoreDataManager

+ (LWAlchemyCoreDataManager *)sharedManager {
    static dispatch_once_t onceToken;
    static LWAlchemyCoreDataManager* sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [[LWAlchemyCoreDataManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - CURD

- (id)insertNSManagedObjectWithObjectClass:(Class)objectClass JSON:(id)json {
    NSManagedObject* model = [objectClass nsManagedObjectModelWithJSON:json
                                                               context:self.managedObjectContext];
    return model;
}


- (void)insertNSManagedObjectWithObjectClass:(Class)objectClass
                                  JSONsArray:(NSArray *)JSONsArray
                         uiqueAttributesName:(NSString *)uniqueAttributesName {

    NSManagedObjectContext* ctx = [self createPrivateObjectContext];
    [ctx performBlock:^{
//        NSLog(@"查询的线程:%@",[NSThread currentThread]);
        for (id json in JSONsArray) {
            NSError* error = nil;
            NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(objectClass) inManagedObjectContext:ctx]];
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", uniqueAttributesName, [[self dictionaryWithJSON:json]objectForKey:uniqueAttributesName]];
            if (predicate) {
                [fetchRequest setPredicate:predicate];
            }
            NSArray* results = [ctx executeFetchRequest:fetchRequest error:&error];
            NSManagedObject* object = [results lastObject];
            if (object) {
                [self.managedObjectContext performBlockAndWait:^{
//                    NSLog(@"修改内从中内容的线程:%@",[NSThread currentThread]);
                    [self updateNSManagedObjectWithObjectID:object.objectID JSON:json];
                }];
            } else {
                [self.managedObjectContext performBlockAndWait:^{
                    [self insertNSManagedObjectWithObjectClass:objectClass JSON:json];
                }];
            }
        }
    }];
}

- (void)insertNSManagedObjectWithObjectClass:(Class)objectClass
                                        JSON:(id)json
                         uiqueAttributesName:(NSString *)uniqueAttributesName {
    NSManagedObjectContext* ctx = [self createPrivateObjectContext];
    [ctx performBlock:^{
        NSError* error = nil;
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(objectClass) inManagedObjectContext:ctx]];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", uniqueAttributesName, [[self dictionaryWithJSON:json]objectForKey:uniqueAttributesName]];
        if (predicate) {
            [fetchRequest setPredicate:predicate];
        }
        NSArray* results = [ctx executeFetchRequest:fetchRequest error:&error];
        NSManagedObject* object = [results lastObject];
        if (object) {
            [self.managedObjectContext performBlockAndWait:^{
                [self updateNSManagedObjectWithObjectID:object.objectID JSON:json];
            }];
        } else {
            [self.managedObjectContext performBlockAndWait:^{
                [self insertNSManagedObjectWithObjectClass:objectClass JSON:json];
            }];
        }
    }];
}

- (void)fetchNSManagedObjectWithObjectClass:(Class)objectClass
                                  predicate:(NSPredicate *)predicate
                             sortDescriptor:(NSArray<NSSortDescriptor *> *)sortDescriptors
                                fetchOffset:(NSInteger)offset
                                 fetchLimit:(NSInteger)limit
                                fetchReults:(FetchResults)resultsBlock {
    NSManagedObjectContext* ctx = [self createPrivateObjectContext];
    [ctx performBlock:^{
        NSError* error = nil;
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(objectClass) inManagedObjectContext:ctx]];
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
            [self.managedObjectContext performBlock:^{
                resultsBlock(@[],error);
            }];
        }
        if ([results count] < 1) {
            [self.managedObjectContext performBlock:^{
                resultsBlock(@[],nil);
            }];
        }
        NSMutableArray *result_ids = [[NSMutableArray alloc] init];
        for (NSManagedObject* object  in results) {
            [result_ids addObject:object.objectID];
        }
        [self.managedObjectContext performBlockAndWait:^{
            NSMutableArray* final_results = [[NSMutableArray alloc] init];
            for (NSManagedObjectID* objectID in result_ids) {
                [final_results addObject:[self.managedObjectContext objectWithID:objectID]];
            }
            resultsBlock(final_results, nil);
        }];
    }];
}


- (void)updateNSManagedObjectWithObjectID:(NSManagedObjectID *)objectID JSON:(id)json {
    NSManagedObject* object = [self.managedObjectContext objectWithID:objectID];
    if ([json isKindOfClass:[NSDictionary class]]) {
        object = [object nsManagedObject:object modelWithDictionary:json context:self.managedObjectContext];
    } else {
        NSDictionary* dict = [self dictionaryWithJSON:json];
        object = [object nsManagedObject:object modelWithDictionary:dict context:self.managedObjectContext];
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



#pragma mark - CoreData Stack

- (void)saveContext:(Completion)completionBlock {
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } else {
        [self.parentContext performBlock:^{
//            NSLog(@"写入到数据库的线程:%@",[NSThread currentThread]);
            __block NSError* inner_error = nil;
            [self.parentContext save:&inner_error];
            [self.managedObjectContext performBlock:^{
                completionBlock();
            }];
        }];
    }
}

- (NSManagedObjectContext *)createPrivateObjectContext {
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [ctx performBlockAndWait:^{
        [ctx setParentContext:self.managedObjectContext];
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
        [_parentContext performBlockAndWait:^{
            [_parentContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
            [_parentContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            [_parentContext setUndoManager:nil];
        }];

    }
    return _parentContext;
    
}
@end
