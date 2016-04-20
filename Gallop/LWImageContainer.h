//
//  LWImageContanier.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


@class LWImageStorage;


@interface LWImageContainer : CALayer

@property (nonatomic,copy) NSString* containerIdentifier;

- (void)setContentWithImageStorage:(LWImageStorage *)imageStorage;
- (void)layoutImageStorage:(LWImageStorage *)imageStorage;
- (void)cleanup;



- (void)delayLayoutImageStorage:(LWImageStorage *)imageStorage;
- (void)delayCleanup;


@end
