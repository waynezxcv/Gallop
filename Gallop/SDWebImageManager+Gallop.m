/*
 https://github.com/waynezxcv/Gallop
 
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




#import "SDWebImageManager+Gallop.h"
#import <objc/message.h>
#import "LWImageProcessor.h"
#import "SDImageCache+Gallop.h"


@interface SDWebImageCombinedOperation : NSObject <SDWebImageOperation>


@property (nonatomic,assign,getter = isCancelled) BOOL cancelled;
@property (nonatomic,copy) SDWebImageNoParamsBlock cancelBlock;
@property (nonatomic,strong) NSOperation* cacheOperation;


@end


@implementation SDWebImageManager(Gallop)

@dynamic runningOperations;
@dynamic failedURLs;

- (id <SDWebImageOperation>)lw_downloadImageWithURL:(NSURL *)url
                                       cornerRadius:(CGFloat)cornerRadius
                              cornerBackgroundColor:(UIColor *)cornerBackgroundColor
                                        borderColor:(UIColor *)borderColor
                                        borderWidth:(CGFloat)borderWidth
                                               size:(CGSize)size
                                        contentMode:(UIViewContentMode)contentMode
                                             isBlur:(BOOL)isBlur
                                            options:(SDWebImageOptions)options
                                           progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                          completed:(SDInternalCompletionBlock)completedBlock {
    
    
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }
    
    __block SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
    __weak SDWebImageCombinedOperation *weakOperation = operation;
    
    BOOL isFailedUrl = NO;
    if (url) {
        @synchronized (self.failedURLs) {
            isFailedUrl = [self.failedURLs containsObject:url];
        }
    }
    if (url.absoluteString.length == 0 || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        [self lw_callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil] url:url];
        return operation;
    }
    @synchronized (self.runningOperations) {
        [self.runningOperations addObject:operation];
    }
    
    /***  将图片的圆角半径、模糊信息信息保存到key中  ***/
    NSString* key;
    if (cornerRadius != 0 || isBlur) {
        key = [LWImageProcessor lw_imageTransformCacheKeyForURL:url
                                                   cornerRadius:cornerRadius
                                                           size:size
                                          cornerBackgroundColor:cornerBackgroundColor
                                                    borderColor:borderColor
                                                    borderWidth:borderWidth
                                                    contentMode:contentMode
                                                         isBlur:isBlur];
    } else {
        key = [self cacheKeyForURL:url];
    }
    
    /********************************************/
    //先从缓存中查找，先内存后硬盘
    operation.cacheOperation = [self.imageCache queryCacheOperationForKey:key done:^(UIImage *cachedImage, NSData *cachedData, SDImageCacheType cacheType) {
        //如果取消了，从下载队列中移除
        if (operation.isCancelled) {
            [self lw_safelyRemoveOperationFromRunning:operation];
            return;
        }
        
        if ((!cachedImage || options & SDWebImageRefreshCached)/*缓存中没找到，或者需要刷新缓存*/ &&
            (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] ||
             [self.delegate imageManager:self shouldDownloadImageForURL:url])) {
                //如果存在已经存在缓存，但是需要刷新缓存
                if (cachedImage && options & SDWebImageRefreshCached) {
                    [self lw_callCompletionBlockForOperation:weakOperation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
                }
                
                //开始下载图片
                SDWebImageDownloaderOptions downloaderOptions = 0;
                if (options & SDWebImageLowPriority) downloaderOptions |= SDWebImageDownloaderLowPriority;
                if (options & SDWebImageProgressiveDownload) downloaderOptions |= SDWebImageDownloaderProgressiveDownload;
                if (options & SDWebImageRefreshCached) downloaderOptions |= SDWebImageDownloaderUseNSURLCache;
                if (options & SDWebImageContinueInBackground) downloaderOptions |= SDWebImageDownloaderContinueInBackground;
                if (options & SDWebImageHandleCookies) downloaderOptions |= SDWebImageDownloaderHandleCookies;
                if (options & SDWebImageAllowInvalidSSLCertificates) downloaderOptions |= SDWebImageDownloaderAllowInvalidSSLCertificates;
                if (options & SDWebImageHighPriority) downloaderOptions |= SDWebImageDownloaderHighPriority;
                if (options & SDWebImageScaleDownLargeImages) downloaderOptions |= SDWebImageDownloaderScaleDownLargeImages;
                
                if (cachedImage && options & SDWebImageRefreshCached) {
                    downloaderOptions &= ~SDWebImageDownloaderProgressiveDownload;
                    downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
                }
                
                SDWebImageDownloadToken *subOperationToken =
                [self.imageDownloader downloadImageWithURL:url
                                                   options:downloaderOptions
                                                  progress:progressBlock
                                                 completed:^(UIImage *downloadedImage,
                                                             NSData *downloadedData,
                                                             NSError *error,
                                                             BOOL finished) {
                                                     
                                                     __strong __typeof(weakOperation) strongOperation = weakOperation;
                                                     if (!strongOperation || strongOperation.isCancelled) {//下载取消
                                                     } else if (error) {//下载出现错误
                                                         [self lw_callCompletionBlockForOperation:strongOperation completion:completedBlock error:error url:url];
                                                         
                                                         if (   error.code != NSURLErrorNotConnectedToInternet
                                                             && error.code != NSURLErrorCancelled
                                                             && error.code != NSURLErrorTimedOut
                                                             && error.code != NSURLErrorInternationalRoamingOff
                                                             && error.code != NSURLErrorDataNotAllowed
                                                             && error.code != NSURLErrorCannotFindHost
                                                             && error.code != NSURLErrorCannotConnectToHost
                                                             && error.code != NSURLErrorNetworkConnectionLost) {
                                                             @synchronized (self.failedURLs) {
                                                                 [self.failedURLs addObject:url];
                                                             }
                                                         }
                                                     } else {//下载完成
                                                         if ((options & SDWebImageRetryFailed)) {
                                                             @synchronized (self.failedURLs) {
                                                                 [self.failedURLs removeObject:url];
                                                             }
                                                         }
                                                         
                                                         BOOL cacheOnDisk = !(options & SDWebImageCacheMemoryOnly);
                                                         //刷新图片缓存触发了NSURLCache缓存
                                                         if (options & SDWebImageRefreshCached && cachedImage && !downloadedImage) {
                                                             
                                                         } else if (downloadedImage && (!downloadedImage.images || (options & SDWebImageTransformAnimatedImage)) && [self.delegate respondsToSelector:@selector(imageManager:transformDownloadedImage:withURL:)]) {
                                                             
                                                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                                                 UIImage* transformedImage = [self.delegate imageManager:self transformDownloadedImage:downloadedImage withURL:url];
                                                                 if (transformedImage && finished) {
                                                                     BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                                                     /********* 缓存图片，这个方法已经被替换  **************/
                                                                     [self.imageCache storeImage:transformedImage imageData:(imageWasTransformed ? nil : downloadedData) forKey:key toDisk:cacheOnDisk completion:nil];
                                                                     /***********************************************/
                                                                 }
                                                                 [self lw_callCompletionBlockForOperation:strongOperation completion:completedBlock image:transformedImage data:downloadedData error:nil cacheType:SDImageCacheTypeNone finished:finished url:url];
                                                             });
                                                             
                                                             
                                                         } else {
                                                             
                                                             if (downloadedImage && finished) {//下载完成
                                                                 
                                                                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                                                     /*********  缓存图片，这个方法已经被替换  **************/
                                                                     [self.imageCache storeImage:downloadedImage imageData:downloadedData forKey:key toDisk:cacheOnDisk completion:^{
                                                                         dispatch_main_async_safe(^{
                                                                             //没有取消
                                                                             if (operation && !operation.isCancelled && completedBlock) {
                                                                                 /*****  从缓存中读取经过处理的图片缓存  ****/
                                                                                 if ([key hasPrefix:[NSString stringWithFormat:@"%@",kLWImageProcessorPrefixKey]]) {
                                                                                     completedBlock([self.imageCache imageFromCacheForKey:key],
                                                                                                    downloadedData,
                                                                                                    nil,
                                                                                                    SDImageCacheTypeNone,
                                                                                                    finished,
                                                                                                    url);
                                                                                     /*******************************/
                                                                                 } else {//不需要处理的图片
                                                                                     completedBlock(downloadedImage,
                                                                                                    downloadedData,
                                                                                                    nil,
                                                                                                    SDImageCacheTypeNone,
                                                                                                    finished,
                                                                                                    url);
                                                                                 }
                                                                             }
                                                                         });
                                                                     }];
                                                                     /***********************************************/
                                                                 });
                                                             }
                                                         }
                                                         
                                                     }
                                                     if (finished) {
                                                         [self lw_safelyRemoveOperationFromRunning:strongOperation];
                                                     }
                                                 }];
                operation.cancelBlock = ^{
                    [self.imageDownloader cancel:subOperationToken];
                    __strong __typeof(weakOperation) strongOperation = weakOperation;
                    [self lw_safelyRemoveOperationFromRunning:strongOperation];
                };
                //缓存中存在图片
            } else if (cachedImage) {
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                [self lw_callCompletionBlockForOperation:strongOperation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
                [self lw_safelyRemoveOperationFromRunning:operation];
            } else {
                
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                [self lw_callCompletionBlockForOperation:strongOperation completion:completedBlock image:nil data:nil error:nil cacheType:SDImageCacheTypeNone finished:YES url:url];
                [self lw_safelyRemoveOperationFromRunning:operation];
            }
    }];
    return operation;
}


- (void)lw_callCompletionBlockForOperation:(nullable SDWebImageCombinedOperation*)operation
                                completion:(nullable SDInternalCompletionBlock)completionBlock
                                     error:(nullable NSError *)error
                                       url:(nullable NSURL *)url {
    [self lw_callCompletionBlockForOperation:operation completion:completionBlock image:nil data:nil error:error cacheType:SDImageCacheTypeNone finished:YES url:url];
}


- (void)lw_callCompletionBlockForOperation:(nullable SDWebImageCombinedOperation*)operation
                                completion:(nullable SDInternalCompletionBlock)completionBlock
                                     image:(nullable UIImage *)image
                                      data:(nullable NSData *)data
                                     error:(nullable NSError *)error
                                 cacheType:(SDImageCacheType)cacheType
                                  finished:(BOOL)finished
                                       url:(nullable NSURL *)url {
    
    dispatch_main_async_safe(^{
        if (operation && !operation.isCancelled && completionBlock) {
            completionBlock(image, data, error, cacheType, finished, url);
        }
    });
}


- (void)lw_safelyRemoveOperationFromRunning:(nullable SDWebImageCombinedOperation*)operation {
    @synchronized (self.runningOperations) {
        if (operation) {
            [self.runningOperations removeObject:operation];
        }
    }
}


@end

