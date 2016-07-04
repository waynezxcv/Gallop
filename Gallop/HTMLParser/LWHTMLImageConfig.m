//
//  LWHTMLImageConfig.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/6/27.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWHTMLImageConfig.h"
#import "GallopUtils.h"

@implementation LWHTMLImageConfig

- (id)init {
    self = [super init];
    if (self) {
        self.autolayoutHeight = NO;
        self.placeholder = nil;
        self.userInteractionEnabled = YES;
        self.size = CGSizeMake(SCREEN_WIDTH, 100.0f);
        self.paragraphSpacing = 10.0f;
        self.needAddToImageBrowser = NO;
    }
    return self;
}

+ (LWHTMLImageConfig *)defaultsConfig {
    static LWHTMLImageConfig* config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[LWHTMLImageConfig alloc] init];
    });
    return config;
}

@end
