//
//  LWImageDownloadeOpertion.h
//  LWWebImage
//
//  Created by 刘微 on 16/1/3.
//  Copyright © 2016年 WayneInc. All rights reserved.//
//

#import <Foundation/Foundation.h>
#import "LWWebImageManager.h"

@interface LWImageDownloadeOperation : NSOperation

- (id)initWithRequest:(NSURLRequest *)request
              options:(LWWebImageOptions)options
             progress:(LWWebImageDownloadProgressBlock)progress
            transform:(LWWebImageDownloadTransformBlock)transform
           completion:(LWWebImageDownloadCompletionBlock)completion;

@end


