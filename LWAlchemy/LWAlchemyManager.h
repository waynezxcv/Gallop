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

#import <UIKit/UIKit.h>

@class NSPersistentStoreCoordinator;
@class NSManagedObjectContext;
@class NSManagedObjectModel;
@class NSManagedObjectID;
@class NSManagedObject;
@class NSFetchRequest;

typedef void(^Completion)(void);
typedef void(^FetchResults)(NSArray* results, NSError *error);
typedef void(^ExistingObject)(NSManagedObject* existedObject);


@interface LWAlchemyManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;//主线程Context，用户增，改，删（在内存中操作）。
@property (readonly, strong, nonatomic) NSManagedObjectContext* parentContext;//用来写入数据到SQLite的Context，在一个后台线程中操作。




+ (LWAlchemyManager *)sharedManager;


/**
 *  批量插入数据，并指定UniqueAttributesName，
 *  若存在则重复插入，改为更新数据（总共新开一个线程）
 *
 *  @param cls                  Entity的类(如：[Student Class])
 *  @param jsonArray            包含JSON的数组
 *  @param uniqueAttributesName unique约束的属性名
 *  @param isSave               是否保存
 *  @param completeBlock        完成回调
 */
- (void)insertEntitysWithClass:(Class)cls
                    JSONsArray:(NSArray *)jsonArray
           uiqueAttributesName:(NSString *)uniqueAttributesName
                          save:(BOOL)isSave
                    completion:(Completion)completeBlock;


/**
 *  增入一条数据。
 *
 */
- (void)insertEntityWithClass:(Class)cls
                         JSON:(id)json
                         save:(BOOL)isSave
                   completion:(Completion)completeBlock;


/**
 *  批量插入数据。
 *
 */
- (void)insertEntitysWithClass:(Class)cls
                    JSONsArray:(NSArray *)jsonArray
                          save:(BOOL)isSave
                    completion:(Completion)completeBlock;


/**
 *  查
 */
- (void)fetchNSManagedObjectWithObjectClass:(Class)objectClass
                                  predicate:(NSPredicate *)predicate
                             sortDescriptor:(NSArray<NSSortDescriptor *> *)sortDescriptors
                                fetchOffset:(NSInteger)offset
                                 fetchLimit:(NSInteger)limit
                                fetchReults:(FetchResults)resultsBlock;
/**
 *  删
 */
- (void)deleteNSManagedObjectWithObjectWithObjectIdsArray:(NSArray<NSManagedObjectID *> *)objectIDs;


/**
 *  改
 *
 */
- (void)updateNSManagedObjectWithObjectID:(NSManagedObjectID *)objectID JSON:(id)json;


/**
 *  保存
 *
 */
- (void)saveContext:(Completion)completionBlock;



@end
