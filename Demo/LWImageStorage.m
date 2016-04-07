//
//  LWWebImage.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWImageStorage.h"

@implementation LWImageStorage

- (id)init {
    self = [super init];
    if (self) {
        self.type = LWImageStorageLocalImage;
        self.image = nil;
        self.URL = nil;
        self.boundsRect = CGRectZero;
        self.contentMode = kCAGravityResizeAspect;
        self.masksToBounds = YES;
        self.placeholder = nil;
        self.fadeShow = NO;
    }
    return self;
}

@end
