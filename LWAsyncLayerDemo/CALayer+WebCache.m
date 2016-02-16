//
//  CALayer+WebCache.m
//  SDWebImage
//
//  Created by 刘微 on 16/1/15.
//  Copyright © 2016年 Dailymotion. All rights reserved.
//

#import "CALayer+WebCache.h"
#import "objc/runtime.h"
#import "CALayer+WebCacheOperation.h"
#import "CALayer+LazySetContents.h"

static char imageURLKey;

@implementation CALayer(WebCache)

- (void)sd_setImageWithURL:(NSURL *)url {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 processing:nil progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 processing:nil progress:nil completed:nil];
}


- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 processing:nil progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 processing:nil progress:nil completed:completedBlock];
}


- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 processing:nil progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options processing:nil progress:nil completed:completedBlock];
}

- (void)sd_setImageWithPreviousCachedImageWithURL:(NSURL *)url
                                 placeholderImage:(UIImage *)placeholder
                                          options:(SDWebImageOptions)options
                                       processing:(SDWebImageDownloaderProcessingImageBlock)processingBlock
                                         progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                        completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options processing:processingBlock progress:nil completed:completedBlock];
}

#pragma mark -

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
                   options:(SDWebImageOptions)options
                processing:(SDWebImageDownloaderProcessingImageBlock)processingBlock
                  progress:(SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            [self lazySetContent:(__bridge id)placeholder.CGImage];
        });
    }
    if (url) {
        __weak __typeof(self)wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url
                                                                                           options:options
                                                                                        processing:processingBlock
                                                                                          progress:progressBlock
                                                                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                                             if (!wself) return;
                                                                                             dispatch_main_sync_safe(^{
                                                                                                 if (!wself) return;
                                                                                                 if (image && (options & SDWebImageAvoidAutoSetImage) && completedBlock) {
                                                                                                     completedBlock(image, error, cacheType, url);
                                                                                                     return;
                                                                                                 } else if (image) {
                                                                                                     [self lazySetContent:(__bridge id)image.CGImage];
                                                                                                 } else {
                                                                                                     if ((options & SDWebImageDelayPlaceholder)) {
                                                                                                         [self lazySetContent:(__bridge id)placeholder.CGImage];
                                                                                                     }
                                                                                                 }
                                                                                                 if (completedBlock && finished) {
                                                                                                     completedBlock(image, error, cacheType, url);
                                                                                                 }
                                                                                             });
                                                                                         }];
        [self sd_setImageLoadOperation:operation forKey:@"CALayerImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)sd_setImageWithPreviousCachedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    [self sd_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options processing:nil progress:progressBlock completed:completedBlock];
}

- (NSURL *)sd_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)sd_cancelCurrentImageLoad {
    [self sd_cancelImageLoadOperationWithKey:@"CALayerImageLoad"];
}

@end
