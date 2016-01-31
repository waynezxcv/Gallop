//
//  LWWebImageManager.m
//  LWWebImage
//
//  Created by 刘微 on 16/1/3.
//  Copyright © 2016年 WayneInc. All rights reserved.//
//

#import "LWWebImageManager.h"
#import "LWImageDownloadeOperation.h"


@interface LWWebImageSuperOperation : NSObject

@property (nonatomic,strong) LWImageDownloadeOperation* downloadOpertion;

@end

@implementation LWWebImageSuperOperation

- (void)cancel {
    [self.downloadOpertion cancel];
}


@end


@interface LWWebImageManager ()

@property (nonatomic,strong) NSMutableArray* runningOperations;

@end



@implementation LWWebImageManager

//获取单例
+ (instancetype)sharedManager {
    static LWWebImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSOperationQueue* downloadQueue = [[NSOperationQueue alloc] init];
        //NSOperationQueue并没有区分串行和并行。设MaxCount = 1.则是串行，否则为并行。
        //自定义NSOperation的子类，可以实现同步和异步，NSOperation通过isFinished的状态来判断是否返回
        //（同步异步的区别在于是否立即返回，还有是否堵塞当前线程。。）
        downloadQueue.maxConcurrentOperationCount = 10;
        manager = [[LWWebImageManager alloc] init];
        manager.downloadQueue = downloadQueue;
        manager.timeout = 15.0;
        manager.headers = @{@"Accept":@"image/webp,image/*;q=0.8"};
        manager.imageCache = [LWImageCache sharedImageCache];
        manager.runningOperations = [[NSMutableArray alloc] init];
    });
    return manager;
}

//获取cacheKey
- (NSString *)cacheKeyForURL:(NSURL *)url {
    return [url absoluteString];
}

//是否存在缓存
- (BOOL)cachedImageExistsForURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url];
    if ([self.imageCache imageFromMemoryCacheForKey:key] != nil){
        return YES;
    }
    return [self.imageCache diskImageExistsWithKey:key];
}

//请求数据
- (NSOperation *)requestImageWithURL:(NSURL *)requestUrl
                      dowloadOptions:(LWWebImageOptions)options
                            progress:(LWWebImageDownloadProgressBlock)progress
                           transform:(LWWebImageDownloadTransformBlock)transform
                          completion:(LWWebImageDownloadCompletionBlock)completion {
    //处理URL，防止错误输入
    if ([requestUrl isKindOfClass:[NSString class]]) {
        NSString* urlString = (NSString *)requestUrl;
        requestUrl = [NSURL URLWithString:urlString];
    }
    if (![requestUrl isKindOfClass:NSURL.class]) {
        requestUrl = nil;
        return nil;
    }
    //如果存在缓存，则从缓存中读取
    if ([self cachedImageExistsForURL:requestUrl]) {
        [self.imageCache imageFromCacheForKey:[self cacheKeyForURL:requestUrl]
                                   Completion:^(UIImage *image, LWImageCacheType cacheType) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completion(image,requestUrl,nil,YES);
                                       });
                                   }];
        return nil;
    }

    //没有找到缓存，则从网络下载。并保存
    else {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:requestUrl];
        request.timeoutInterval = self.timeout;
        __weak typeof(self) weakSelf = self;
        __block LWWebImageSuperOperation* operation = [[LWWebImageSuperOperation alloc] init];
        __weak typeof(operation) weakOperaton = operation;
        @synchronized(self.runningOperations) {
            [self.runningOperations addObject:weakOperaton];
        }
        LWImageDownloadeOperation* downLoadOperation = [[LWImageDownloadeOperation alloc]
                                                        initWithRequest:request
                                                        options:0
                                                        progress:progress
                                                        transform:transform
                                                        completion:^(UIImage *image, NSURL *url, NSError *error, BOOL isFinished) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                completion(image,url,error,isFinished);
                                                            });
                                                            if (isFinished) {
                                                                @synchronized(weakSelf.runningOperations) {
                                                                    [weakSelf.runningOperations removeObject:weakOperaton];
                                                                    [weakSelf.imageCache saveToImageCacheWithImage:image
                                                                                                            forkey:[url absoluteString]];
                                                                }
                                                            }
                                                        }];
        operation.downloadOpertion = downLoadOperation;
        if (downLoadOperation) {
            if (self.downloadQueue) {
                [self.downloadQueue addOperation:downLoadOperation];
            } else {
                [downLoadOperation start];
            }
        }
        return downLoadOperation;
    }
}


- (NSInteger)currentRunningOperationCount {
    return [self.downloadQueue operations].count;
}

@end
