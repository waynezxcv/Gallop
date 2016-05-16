//
//  GallopUtils.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/5/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "GallopUtils.h"

@implementation GallopUtils

+ (CGFloat)contentsScale {
    static dispatch_once_t once;
    static CGFloat contentsScale;
    dispatch_once(&once, ^{
        contentsScale = [UIScreen mainScreen].scale;
    });
    return contentsScale;
}

@end
