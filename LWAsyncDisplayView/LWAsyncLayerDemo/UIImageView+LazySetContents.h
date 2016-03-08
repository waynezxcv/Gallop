//
//  UIImageView+LazySetContents.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageView(LazySetContents)

/**
 *  在MainRunLoop足够空闲的情况下set内容
 */
- (void)lazySetContent:(id)contents;

@end


