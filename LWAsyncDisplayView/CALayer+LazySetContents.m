//
//  CALayer+LazySetContents.m
//  SDWebImage
//
//  Created by 刘微 on 16/2/2.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import "CALayer+LazySetContents.h"
#import "LWRunLoopObserver.h"


@implementation CALayer(LazySetContents)

- (void)lazySetContent:(id)contents {
    LWRunLoopObserver* obeserver = [LWRunLoopObserver observerWithTarget:self
                                                                selector:@selector(setContents:)
                                                                  object:contents];
    [obeserver commit];
}


@end
