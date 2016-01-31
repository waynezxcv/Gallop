//
//  LWWebImageManager.h
//  LWWebImage
//
//  Created by 刘微 on 16/1/3.
//  Copyright © 2016年 WayneInc. All rights reserved.//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LWImageCache.h"


typedef NS_OPTIONS(NSUInteger, LWWebImageOptions) {
    LWWebImageShowFade = 1 << 0,
    LWWebImageShowProgressvie = 1 << 1,
    LWWebImageCacheMemoryOnly = 1 << 2,
    LWWebImageProgressiveDownload = 1 << 3,
    LWWebImageRefreshCached = 1 << 4,
    LWWebImageContinueInBackground = 1 << 5,
    LWWebImageHandleCookies = 1 << 6,
    LWWebImageAllowInvalidSSLCertificates = 1 << 7,
    LWWebImageHighPriority = 1 << 8,
    LWWebImageDelayPlaceholder = 1 << 9,
    LWWebImageTransformAnimatedImage = 1 << 10,
    LWWebImageAvoidAutoSetImage = 1 << 11
};


typedef UIImage*(^LWWebImageDownloadTransformBlock)(UIImage* image);
typedef void(^LWWebImageDownloadProgressBlock)(NSInteger receivedSize,NSInteger expectedSize,CGFloat percent);
typedef void(^LWWebImageDownloadCompletionBlock)(UIImage* image,NSURL* url,NSError* error,BOOL isFinished);
typedef void(^LWWebImageDownloadNoParametersBlock)(void);

@interface LWWebImageManager : NSObject

+ (instancetype)sharedManager;

- (NSOperation *)requestImageWithURL:(NSURL *)requestUrl
             dowloadOptions:(LWWebImageOptions)options
                   progress:(LWWebImageDownloadProgressBlock)progress
                  transform:(LWWebImageDownloadTransformBlock)transform
                 completion:(LWWebImageDownloadCompletionBlock)completion;

@property (nonatomic,strong) LWImageCache* imageCache;
@property (nonatomic,strong) NSOperationQueue* downloadQueue;
@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic,copy) NSDictionary* headers;

- (NSInteger)currentRunningOperationCount;

@end
