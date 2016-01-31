//
//  LWImageCache.h
//  LWWebImage
//
//  Created by 刘微 on 16/1/4.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LWImageCacheType) {
    LWImageCacheTypeNone,//无类型
    LWImageCacheTypeMemory,//内存缓存类型
    LWImageCacheTypeDisk,//硬盘缓存类型
};

typedef void(^LWWebImageQueryCompletedBlock)(UIImage *image, LWImageCacheType cacheType);
typedef void(^LWWebImageNoParametersBlock)(void);

@interface LWImageCache : NSObject

//缓存名字
@property (nonatomic,copy) NSString* name;

//缓存类型
@property (nonatomic,assign) LWImageCacheType cacheType;

//内存缓存
@property (nonatomic,strong) NSCache* memoryCache;

@property (nonatomic,assign) NSUInteger totalCostLimit;

@property (nonatomic,assign) NSUInteger countLimit;

@property (nonatomic,assign) BOOL evictsObjectsWithDiscardedContent;

@property (nonatomic,assign) BOOL shouldDecompressImages;

@property (nonatomic,assign) NSInteger maxCacheAge;

@property (nonatomic,assign) NSInteger maxDiskCacheCost;

//创建获取单例
+(LWImageCache *)sharedImageCache;

/************************** 读取 ******************************/

//从缓存读取图片
- (void)imageFromCacheForKey:(NSString *)cacheKey Completion:(LWWebImageQueryCompletedBlock)completion;

//通过CacheKey获取内存缓存图片
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)cacheKey;

//通过CacheKey获取硬盘缓存图片
- (UIImage *)imageFromDiskCacheForKey:(NSString *)cacheKey;

//判断是否存在硬盘缓存
- (BOOL)diskImageExistsWithKey:(NSString *)cacheKey;


/************************ 写入 ******************************/

//将一张图片写入到缓存
- (void)saveToImageCacheWithImage:(UIImage *)image forkey:(NSString *)cacheKey;

//将一张图片保存到内存缓存
- (void)saveToMemoryWithImamge:(UIImage *)image forkey:(NSString *)cacheKey;

//将一张图片保存到硬盘
- (void)saveToDiskWithImage:(UIImage *)image forkey:(NSString *)cacheKey;


/********************** 删除 ***********************************/

//清除硬盘缓存
- (void)cleanDiskWithCompletionBlock:(LWWebImageNoParametersBlock)completion;

//通过Key将一张图片存内存缓存中移除
- (void)removeObjectFromMemoryForKey:(NSString *)cacheKey;

//通过Key将一张图片从硬盘中删除
- (void)removeObjectFromDiskForKey:(NSString *)cacheKey;

//移除所有MemoryCache
- (void)removeAllMemoryCacheObjects;

//移除所有DiskCache
- (void)removeAllDiskCacheObjects;


@end
