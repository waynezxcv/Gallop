//
//  UIImageView+LazySetContents.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import "UIImageView+LazySetContents.h"
#import "LWRunLoopObserver.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>


@implementation UIImageView(LazySetContents)

- (void)lazySetContent:(id)contents {
    LWRunLoopObserver* obeserver = [LWRunLoopObserver observerWithTarget:self
                                                                selector:@selector(setImage:)
                                                                  object:contents];
    [obeserver commit];
}

@end
