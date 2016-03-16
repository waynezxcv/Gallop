//
//  LWAsyncDisplayLayer.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/2.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LWFlag.h"

@class LWAsyncDisplayLayer;

@protocol LWAsyncDisplayLayerDelegate <NSObject>

@required

/**
 *  将要开始绘制之前回调函数
 */
- (BOOL)willBeginAsyncDisplay:(LWAsyncDisplayLayer *)layer;


/**
 *  异步绘制回调函数
 */
- (void)didAsyncDisplay:(LWAsyncDisplayLayer *)layer context:(CGContextRef)context size:(CGSize)size;


@optional

/**
 *  绘制结束回调函数
 */
- (void)didFinishAsyncDisplay:(LWAsyncDisplayLayer *)layer isFiniedsh:(BOOL) isFinished;


@end


/**
 *  LWAsyncDisplayLayer
 */
@interface LWAsyncDisplayLayer : CALayer

/**
 *  异步绘制Delegate
 */
@property (nonatomic,weak) id <LWAsyncDisplayLayerDelegate>asyncDisplayDelegate;

/**
 *  Flag
 */
@property (nonatomic,strong,readonly) LWFlag* flag;


- (void)drawContent;

- (void)cleanUp;
@end
