//
//  LWAsyncDisplayLayer.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/2.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWAsyncDisplayLayer.h"
#import <UIKit/UIKit.h>
#import "CALayer+AsyncDisplay.h"


@interface LWAsyncDisplayLayer ()

@property (nonatomic,strong,readwrite) LWFlag* flag;

@end

@implementation LWAsyncDisplayLayer

#pragma mark - Override


- (id)init {
    self = [super init];
    if (self) {
        static CGFloat scale;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            scale = [UIScreen mainScreen].scale;
        });
        self.contentsScale = scale;
        self.flag = [[LWFlag alloc] init];
    }
    return self;
}

- (void)setNeedsDisplay {
    [self _cancelDisplay];
    [super setNeedsDisplay];
}

- (void)display {
    super.contents = super.contents;
    [self _asyncDisplay];
}

#pragma mark - Private
- (void)_asyncDisplay {
    [self lazySetContent:nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CGSize size = self.bounds.size;
        BOOL opaque = self.opaque;
        CGFloat scale = self.contentsScale;
        LWFlag* flag = self.flag;
        int32_t value = flag.value;
        BOOL isCancled = (value != flag.value);
        if (isCancled) {
            return ;
        }
        BOOL isWillDisplay = [self.asyncDisplayDelegate willBeginAsyncDisplay:self];
        if (!isWillDisplay) {
            return;
        }
        UIGraphicsBeginImageContextWithOptions(size,opaque, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == NULL) {
            NSLog(@"context is NULL");
            return;
        }
        if (isCancled) {
            UIGraphicsEndImageContext();
            return;
        }
        [self.asyncDisplayDelegate didAsyncDisplay:self context:context size:self.bounds.size isCancled:isCancled];
        UIImage* screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
        if (isCancled) {
            UIGraphicsEndImageContext();
            return;
        }
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            [self lazySetContent:(__bridge id)screenshotImage.CGImage];
            if ([self.asyncDisplayDelegate respondsToSelector:@selector(didFinishAsyncDisplay:isFiniedsh:)]) {
                [self.asyncDisplayDelegate didFinishAsyncDisplay:self isFiniedsh:YES];
            }
        });
    });
}


- (void)_cancelDisplay {
    [self.flag increase];
}


@end
