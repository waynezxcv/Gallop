//
//  CALayer+LWWebImage.m
//  LWWebImage
//
//  Created by 刘微 on 16/1/6.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "CALayer+LWWebImage.h"
#import "LWWebImageManager.h"
#import "UIImage+LWWebImage.h"
#import <objc/runtime.h>
#import "CALayer+AsyncDisplay.h"

@implementation CALayer(LWWebImage)

const void* imageURLKey = (void *)@"imageURLKey";

- (void)lw_setImageWithURL:(NSURL *)URL
                   options:(LWWebImageOptions)options
                  progress:(LWWebImageDownloadProgressBlock)progress
                 transform:(LWWebImageDownloadTransformBlock)transform
           completionBlock:(LWWebImageNoParametersBlock)completionBlock {

    if (![self.imageURL isEqualToString:URL.absoluteString]) {
        //取消之前的下载
        [self cancelCurrentOperation];
        //对imageURL重新赋值
        [self setImageURL:URL.absoluteString];
    }
    BOOL isFade = ((options & LWWebImageShowFade));
    BOOL isProgressive = (options & LWWebImageShowProgressvie);
    __weak typeof(self) weakSelf = self;
    //开始读取图片
    LWWebImageManager* manager = [LWWebImageManager sharedManager];
    NSOperation* operation = [manager requestImageWithURL:URL
                                           dowloadOptions:0
                                                 progress:progress
                                                transform:transform
                                               completion:^(UIImage *image, NSURL *url, NSError *error, BOOL isFinished) {
                                                   if (isProgressive) {
                                                       [weakSelf lazySetContent:(__bridge id)image.CGImage];
                                                   }
                                                   if (isFinished) {
                                                       [weakSelf lazySetContent:(__bridge id)image.CGImage];
                                                       if (isFade) {
                                                           CATransition*transition = [CATransition animation];
                                                           transition.duration = 0.3f;
                                                           transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                                           transition.type = kCATransitionFade;
                                                           [weakSelf addAnimation:transition forKey:@"LWWebImageFadeAnimation"];
                                                       }
                                                       completionBlock();
                                                   }
                                               }];
    if (operation) {
        [self setLoadOperationKey:operation forKey:URL.absoluteString];
    }
}

- (void)cancelCurrentOperation {
    NSOperation* lastOperation = [self getLoadOperationForKey:self.imageURL];
    if (!lastOperation) {
        return;
    }
    [lastOperation cancel];
    lastOperation = nil;
}

- (void)setImageURL:(NSString *)imageURL {
    objc_setAssociatedObject(self, imageURLKey, imageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)imageURL {
    return objc_getAssociatedObject(self, imageURLKey);
}



- (void)setLoadOperationKey:(NSOperation *)loadOperation forKey:(NSString *)urlKey{
    const void* key = (__bridge void*)urlKey;
    objc_setAssociatedObject(self, key, loadOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSOperation *)getLoadOperationForKey:(NSString *)urlKey {
    const void* key = (__bridge void*)urlKey;
    return objc_getAssociatedObject(self, key);
}



@end
