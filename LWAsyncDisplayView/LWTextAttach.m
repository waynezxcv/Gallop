//
//  LWTextAttach.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/23.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//


#import "LWTextAttach.h"

@implementation LWTextAttach

- (id)init {
    self = [super init];
    if (self) {
        self.range = NSMakeRange(0, 0);
        self.imagePosition = CGRectZero;
        self.image = nil;
    }
    return self;
}

@end
