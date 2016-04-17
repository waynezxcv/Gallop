//
//  LWImageContanier.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWImageContainer.h"
#import "LWImageStorage.h"
#import "CALayer+WebCache.h"
#import "CALayer+GallopAddtions.h"
#import "LWRunLoopTransactions.h"

@implementation LWImageContainer

- (void)setContentWithImageStorage:(LWImageStorage *)imageStorage {
    self.contentsGravity = imageStorage.contentMode;
    self.masksToBounds = imageStorage.masksToBounds;
    if (imageStorage.type == LWImageStorageWebImage) {
        [self sd_setImageWithURL:imageStorage.URL
                placeholderImage:imageStorage.placeholder
                         options:0
                   containerSize:imageStorage.frame.size
                    cornerRadius:imageStorage.cornerRadius
           cornerBackgroundColor:imageStorage.cornerBackgroundColor
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
    } else {
        [self lw_setImage:imageStorage.image
            containerSize:imageStorage.frame.size
             cornerRadius:imageStorage.cornerRadius
    cornerBackgroundColor:imageStorage.cornerBackgroundColor];
    }
}

- (void)layoutImageStorage:(LWImageStorage *)imageStorage {
    [[LWRunLoopTransactions transactionsWithTarget:self
                                          selector:@selector(_delayLayoutImageStorage:)
                                            object:imageStorage] commit];}

- (void)cleanup {
    [[LWRunLoopTransactions transactionsWithTarget:self
                                          selector:@selector(_delayClenup)
                                            object:nil] commit];
}

- (void)_delayLayoutImageStorage:(LWImageStorage *)imageStorage {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.frame = imageStorage.frame;
    [CATransaction commit];
}

- (void)_delayClenup {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.frame = CGRectZero;
    [CATransaction commit];
}

@end
