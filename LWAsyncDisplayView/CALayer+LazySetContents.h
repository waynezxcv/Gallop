//
//  CALayer+LazySetContents.h
//  SDWebImage
//
//  Created by 刘微 on 16/2/2.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//


#import <QuartzCore/QuartzCore.h>



@interface CALayer(LazySetContents)


/**
 *  在MainRunLoop足够空闲的情况下set内容
 */
- (void)lazySetContent:(id)contents;

@end
