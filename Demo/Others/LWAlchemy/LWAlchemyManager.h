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


#import <UIKit/UIKit.h>

@class NSPersistentStoreCoordinator;
@class NSManagedObjectContext;
@class NSManagedObjectModel;
@class NSManagedObjectID;
@class NSManagedObject;
@class NSFetchRequest;



/**
 *  无参数的回调Block
 */
typedef void(^Completion)(void);


/**
 *  查询结果Block
 *
 *  @param results 查询结果，包含NSManagedObject对象的数组
 *  @param error   NSError对象
 */
typedef void(^FetchResults)(NSArray* results, NSError *error);

/**
 *  更新结果Block
 *
 *
 */
typedef void(^UpdatedResults)(id updatedEnity,NSError *error);


/**
 *  用于CoreData管理。CoreData的结构使用的是三层结构。
 *
 *
 */
/******************************************************************************


 ------------------
 |                  |
 |     writeMOC     | background thread ➡︎ NSPersistentStoreCoordinator
 |                  |
 ------------------

 ⬆︎ parent

 ------------------
 |                  |
 |     mainMOC      | main thread ➡︎ NSFetchResultsController
 |                  |
 ------------------

 ⬆︎ parent

 ------------------
 |                  |
 |   temporaryMOC   | background thread
 |                  |
 ------------------


 ******************************************************************************/


@interface LWAlchemyManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;//PSC
@property (readonly, strong, nonatomic) NSManagedObjectContext* mainMOC;//主线程Context
@property (readonly, strong, nonatomic) NSManagedObjectContext* writeMOC;//用来写入数据到本地的Context，mainMOC的parent

/**
 *  获取LWAlchemyManager单例对象
 *
 *  @return LWAlchemyManager单例对象
 */
+ (LWAlchemyManager *)sharedManager;


/**
 *  批量插入数据，并指定UniqueAttributesName，
 *  若存在则重复插入，改为更新数据（总共新开一个线程）
 *
 *  @param cls                  Entity的所属的类(如：[Student Class])
 *  @param jsonArray            包含JSON的数组
 *  @param uniqueAttributesName unique约束的属性名
 *  @param completeBlock        完成回调
 */
- (void)lw_insertEntitysWithClass:(Class)objectClass
                       JSONsArray:(NSArray *)jsonArray
              uiqueAttributesName:(NSString *)uniqueAttributesName
                       completion:(Completion)completeBlock;


/**
 *  异步查询,需要iOS8.0及以上
 *
 *  @param objectClass     查询的实例所属的类
 *  @param predicate       NSPredicate对象，指定过滤方式
 *  @param sortDescriptors 排序方式
 *  @param offset          偏移量
 *  @param limit           最大量
 *  @param resultsBlock    查询结果
 */
- (void)lw_asyncFetchEntityWithClass:(Class)objectClass
                           predicate:(NSPredicate *)predicate
                      sortDescriptor:(NSArray<NSSortDescriptor*> *)sortDescriptors
                         fetchOffset:(NSInteger)offset
                          fetchLimit:(NSInteger)limit
                         fetchReults:(FetchResults)resultsBlock NS_AVAILABLE(10_10, 8_0);

/**
 *  查询
 *
 *  @param objectClass     查询的实例所属的类
 *  @param predicate       NSPredicate对象，指定过滤方式
 *  @param sortDescriptors 排序方式
 *  @param offset          偏移量
 *  @param limit           最大量
 *  @param resultsBlock    查询结果
 */
- (void)lw_fetchEntityWithClass:(Class)objectClass
                      predicate:(NSPredicate *)predicate
                 sortDescriptor:(NSArray<NSSortDescriptor*> *)sortDescriptors
                    fetchOffset:(NSInteger)offset
                     fetchLimit:(NSInteger)limit
                    fetchReults:(FetchResults)resultsBlock;



/**
 *  批量更新，需要iOS8.3以上
 *
 *  @param objectClass        查询的实例所属的类
 *  @param propertiesToUpdate 属性更新字典,格式：@{@"属性名称":更新的值};
 *
 *  @return 更新的数据条数
 */
- (NSInteger)lw_batchUpdateWithEntityWithClass:(Class)objectClass
                            propertiesToUpdate:(NSDictionary *)propertiesToUpdate  NS_AVAILABLE(10_10, 8_3);


/**
 *  更新
 *
 *  @param objectID 要更新的实例的NSManagedObjectID
 *  @param json     需要更新的数据JSON字典
 */
- (void)lw_updateEntityWithObjectID:(NSManagedObjectID *)objectID
                               JSON:(id)json
                         completion:(UpdatedResults)updateResults;



/**
 *  批量删除,需要iOS8.3以上
 *
 *  @param objectClass 查询的实例所属的类
 *  @param predicate   NSPredicate对象，指定过滤方式
 *
 *  @return 删除的条数
 */
- (NSInteger)lw_batchDeleteEntityWithClass:(Class)objectClass
                                 predicate:(NSPredicate *)predicate NS_AVAILABLE(10_10, 8_3);

/**
 *  删除
 *
 *  @param objectIDs 存放需要删除实例的NSManagedObjectID的数组
 */
- (void)lw_deleteNSManagedObjectWithObjectWithObjectIdsArray:(NSArray<NSManagedObjectID *> *)objectIDs
                                                  completion:(Completion)completio;

/**
 *  保存到Sqlite
 */
- (void)saveToSqlite;


@end
