//
//  CALayer+LWWebImage.h
//  LWWebImage
//
//  Created by 刘微 on 16/1/6.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LWWebImageManager.h"


@interface CALayer(LWWebImage)

@property (nonatomic,strong) NSOperation* loadOperation;
@property (nonatomic,strong) NSString* imageURL;

- (void)lw_setImageWithURL:(NSURL *)URL
                   options:(LWWebImageOptions)options
                  progress:(LWWebImageDownloadProgressBlock)progress
                 transform:(LWWebImageDownloadTransformBlock)transform
           completionBlock:(LWWebImageNoParametersBlock)completionBlock;

@end
