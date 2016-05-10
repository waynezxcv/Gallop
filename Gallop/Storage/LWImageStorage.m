//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWImageStorage.h"
#import "CALayer+WebCache.h"
#import "CALayer+GallopAddtions.h"
#import "LWRunLoopTransactions.h"



@implementation LWImageStorage

- (id)init {
    self = [super init];
    if (self) {
        self.type = LWImageStorageWebImage;
        self.image = nil;
        self.URL = nil;
        self.frame = CGRectZero;
        self.contentMode = kCAGravityResizeAspect;
        self.masksToBounds = YES;
        self.placeholder = nil;
        self.fadeShow = NO;
        self.cornerRadius = 0.0f;
        self.cornerBackgroundColor = [UIColor whiteColor];
        self.cornerBorderWidth = 0.0f;
        self.cornerBorderColor = [UIColor whiteColor];
    }
    return self;
}


- (void)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(NSInteger)topCapHeight {
    self.image = [self.image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
}

@end

@implementation LWImageContainer

- (void)setContentWithImageStorage:(LWImageStorage *)imageStorage {
    if (imageStorage.type == LWImageStorageWebImage) {
        if (imageStorage.image) {
            if (imageStorage.cornerRadius == 0) {
                [self setContents:(__bridge id _Nullable)imageStorage.image.CGImage];
            }
            else {
                [self lw_setImage:imageStorage.image
                    containerSize:imageStorage.frame.size
                     cornerRadius:imageStorage.cornerRadius
            cornerBackgroundColor:imageStorage.cornerBackgroundColor
                cornerBorderColor:imageStorage.cornerBorderColor
                      borderWidth:imageStorage.cornerBorderWidth];
            }
        } else {
            [self sd_setImageWithURL:imageStorage.URL
                    placeholderImage:imageStorage.placeholder
                             options:0
                       containerSize:imageStorage.frame.size
                        cornerRadius:imageStorage.cornerRadius
               cornerBackgroundColor:imageStorage.cornerBackgroundColor
                   cornerBorderColor:imageStorage.cornerBorderColor
                         borderWidth:imageStorage.cornerBorderWidth
                           completed:^(UIImage *image, NSError *error,
                                       SDImageCacheType cacheType,
                                       NSURL *imageURL) {
                               if (imageStorage.fadeShow) {
                                   CATransition* transition = [CATransition animation];
                                   transition.duration = 0.2;
                                   transition.timingFunction = [CAMediaTimingFunction
                                                                functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                   transition.type = kCATransitionFade;
                                   [self addAnimation:transition forKey:@"LWImageFadeShowAnimationKey"];
                               }
                           }];
        }
    } else {
        if (imageStorage.cornerRadius == 0) {
            [self setContents:(__bridge id _Nullable)imageStorage.image.CGImage];
        }
        else {
            [self lw_setImage:imageStorage.image
                containerSize:imageStorage.frame.size
                 cornerRadius:imageStorage.cornerRadius
        cornerBackgroundColor:imageStorage.cornerBackgroundColor
            cornerBorderColor:imageStorage.cornerBorderColor borderWidth:imageStorage.cornerBorderWidth];
        }
    }
}

- (void)delayLayoutImageStorage:(LWImageStorage *)imageStorage {
    [[LWRunLoopTransactions transactionsWithTarget:self
                                          selector:@selector(layoutImageStorage:)
                                            object:imageStorage] commit];}

- (void)delayCleanup {
    [[LWRunLoopTransactions transactionsWithTarget:self
                                          selector:@selector(cleanup)
                                            object:nil] commit];
}

- (void)layoutImageStorage:(LWImageStorage *)imageStorage {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.frame = imageStorage.frame;
    [CATransaction commit];
    self.contentsGravity = imageStorage.contentMode;
    self.masksToBounds = imageStorage.masksToBounds;
}


- (void)cleanup {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.frame = CGRectZero;
    [CATransaction commit];
}

@end