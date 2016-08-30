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
#import "LWCornerRadiusHelper.h"
#import "SDImageCache+Gallop.h"



@interface SDWebImageCombinedOperation : NSObject <SDWebImageOperation>

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (copy, nonatomic) SDWebImageNoParamsBlock cancelBlock;
@property (strong, nonatomic) NSOperation* cacheOperation;

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
                                             isBlur:(BOOL)isBlur
                                            options:(SDWebImageOptions)options
                                           progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                          completed:(SDWebImageCompletionWithFinishedBlock)completedBlock {

    // Invoking this method without a completedBlock is pointless
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");

    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, XCode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }

    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

    __block SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
    __weak SDWebImageCombinedOperation *weakOperation = operation;

    BOOL isFailedUrl = NO;
    @synchronized (self.failedURLs) {
        isFailedUrl = [self.failedURLs containsObject:url];
    }

    if (url.absoluteString.length == 0 || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        dispatch_main_sync_safe(^{
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            completedBlock(nil, error, SDImageCacheTypeNone, YES, url);
        });
        return operation;
    }

    @synchronized (self.runningOperations) {
        [self.runningOperations addObject:operation];
    }
    /**
     *  将绘制信息保存到key中
     */
    NSString* key;
    if (cornerRadius != 0 || isBlur) {
        key = [LWCornerRadiusHelper lw_imageTransformCacheKeyForURL:url
                                                       cornerRadius:cornerRadius
                                                               size:size
                                              cornerBackgroundColor:cornerBackgroundColor
                                                        borderColor:borderColor
                                                        borderWidth:borderWidth
                                                             isBlur:isBlur];
    } else {
        key = [self cacheKeyForURL:url];
    }

    operation.cacheOperation = [self.imageCache
                                queryDiskCacheForKey:key
                                done:^(UIImage *image, SDImageCacheType cacheType) {
                                    if (operation.isCancelled) {
                                        @synchronized (self.runningOperations) {
                                            [self.runningOperations removeObject:operation];
                                        }

                                        return;
                                    }
                                    if ((!image || options & SDWebImageRefreshCached) && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url])) {
                                        if (image && options & SDWebImageRefreshCached) {
                                            dispatch_main_sync_safe(^{
                                                // If image was found in the cache but SDWebImageRefreshCached is provided, notify about the cached image
                                                // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
                                                completedBlock(image, nil, cacheType, YES, url);
                                            });
                                        }

                                        // download if no image or requested to refresh anyway, and download allowed by delegate
                                        SDWebImageDownloaderOptions downloaderOptions = 0;
                                        if (options & SDWebImageLowPriority) downloaderOptions |= SDWebImageDownloaderLowPriority;
                                        if (options & SDWebImageProgressiveDownload) downloaderOptions |= SDWebImageDownloaderProgressiveDownload;
                                        if (options & SDWebImageRefreshCached) downloaderOptions |= SDWebImageDownloaderUseNSURLCache;
                                        if (options & SDWebImageContinueInBackground) downloaderOptions |= SDWebImageDownloaderContinueInBackground;
                                        if (options & SDWebImageHandleCookies) downloaderOptions |= SDWebImageDownloaderHandleCookies;
                                        if (options & SDWebImageAllowInvalidSSLCertificates) downloaderOptions |= SDWebImageDownloaderAllowInvalidSSLCertificates;
                                        if (options & SDWebImageHighPriority) downloaderOptions |= SDWebImageDownloaderHighPriority;
                                        if (image && options & SDWebImageRefreshCached) {
                                            // force progressive off if image already cached but forced refreshing
                                            downloaderOptions &= ~SDWebImageDownloaderProgressiveDownload;
                                            // ignore image read from NSURLCache if image if cached but force refreshing
                                            downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
                                        }
                                        id <SDWebImageOperation> subOperation = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage *downloadedImage, NSData *data, NSError *error, BOOL finished) {
                                            __strong __typeof(weakOperation) strongOperation = weakOperation;
                                            if (!strongOperation || strongOperation.isCancelled) {
                                                // Do nothing if the operation was cancelled
                                                // See #699 for more details
                                                // if we would call the completedBlock, there could be a race condition between this block and another completedBlock for the same object, so if this one is called second, we will overwrite the new data
                                            }
                                            else if (error) {
                                                dispatch_main_sync_safe(^{
                                                    if (strongOperation && !strongOperation.isCancelled) {
                                                        completedBlock(nil, error, SDImageCacheTypeNone, finished, url);
                                                    }
                                                });

                                                if (   error.code != NSURLErrorNotConnectedToInternet
                                                    && error.code != NSURLErrorCancelled
                                                    && error.code != NSURLErrorTimedOut
                                                    && error.code != NSURLErrorInternationalRoamingOff
                                                    && error.code != NSURLErrorDataNotAllowed
                                                    && error.code != NSURLErrorCannotFindHost
                                                    && error.code != NSURLErrorCannotConnectToHost) {
                                                    @synchronized (self.failedURLs) {
                                                        [self.failedURLs addObject:url];
                                                    }
                                                }
                                            }
                                            else {
                                                if ((options & SDWebImageRetryFailed)) {
                                                    @synchronized (self.failedURLs) {
                                                        [self.failedURLs removeObject:url];
                                                    }
                                                }
                                                BOOL cacheOnDisk = !(options & SDWebImageCacheMemoryOnly);
                                                if (options & SDWebImageRefreshCached && image && !downloadedImage) {
                                                    // Image refresh hit the NSURLCache cache, do not call the completion block
                                                }
                                                else if (downloadedImage && (!downloadedImage.images || (options & SDWebImageTransformAnimatedImage)) && [self.delegate respondsToSelector:@selector(imageManager:transformDownloadedImage:withURL:)]) {
                                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                                        UIImage *transformedImage = [self.delegate imageManager:self transformDownloadedImage:downloadedImage withURL:url];

                                                        if (transformedImage && finished) {
                                                            BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                                            [self.imageCache storeImage:transformedImage recalculateFromImage:imageWasTransformed imageData:(imageWasTransformed ? nil : data) forKey:key toDisk:cacheOnDisk];
                                                        }

                                                        dispatch_main_sync_safe(^{
                                                            if (strongOperation && !strongOperation.isCancelled) {
                                                                completedBlock(transformedImage, nil, SDImageCacheTypeNone, finished, url);
                                                            }
                                                        });
                                                    });
                                                }
                                                else {
                                                    if (downloadedImage && finished) {
                                                        [self.imageCache storeImage:downloadedImage recalculateFromImage:NO imageData:data forKey:key toDisk:cacheOnDisk];
                                                    }
                                                    dispatch_main_sync_safe(^{
                                                        if (strongOperation && !strongOperation.isCancelled) {
                                                            /**
                                                             *  读取指定的绘制的缓存
                                                             */
                                                            if ([key hasPrefix:[NSString stringWithFormat:@"%@",LWCornerRadiusPrefixKey]]) {
                                                                completedBlock([self.imageCache imageFromDiskCacheForKey:key], nil, SDImageCacheTypeNone, finished, url);
                                                            }else{
                                                                completedBlock(downloadedImage, nil, SDImageCacheTypeNone, finished, url);
                                                            }
                                                        }
                                                    });
                                                }
                                            }

                                            if (finished) {
                                                @synchronized (self.runningOperations) {
                                                    if (strongOperation) {
                                                        [self.runningOperations removeObject:strongOperation];
                                                    }
                                                }
                                            }
                                        }];
                                        operation.cancelBlock = ^{
                                            [subOperation cancel];

                                            @synchronized (self.runningOperations) {
                                                __strong __typeof(weakOperation) strongOperation = weakOperation;
                                                if (strongOperation) {
                                                    [self.runningOperations removeObject:strongOperation];
                                                }
                                            }
                                        };
                                    }

                                    else if (image) {

                                        dispatch_main_sync_safe(^{

                                            __strong __typeof(weakOperation) strongOperation = weakOperation;
                                            if (strongOperation && !strongOperation.isCancelled) {
                                                completedBlock(image, nil, cacheType, YES, url);
                                            }
                                        });
                                        @synchronized (self.runningOperations) {
                                            [self.runningOperations removeObject:operation];
                                        }
                                    }
                                    else {
                                        // Image not in cache and download disallowed by delegate
                                        dispatch_main_sync_safe(^{
                                            __strong __typeof(weakOperation) strongOperation = weakOperation;
                                            if (strongOperation && !weakOperation.isCancelled) {
                                                completedBlock(nil, nil, SDImageCacheTypeNone, YES, url);
                                            }
                                        });
                                        @synchronized (self.runningOperations) {
                                            [self.runningOperations removeObject:operation];
                                        }
                                    }
                                }];
    
    return operation;
}

@end

