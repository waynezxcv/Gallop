/*
 https://github.com/waynezxcv/Gallop
 
 Copyright (c) 2016 waynezxcv <liuweiself@126.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */




#import <UIKit/UIKit.h>
#import "GallopDefine.h"


@class LWFlag;
@protocol LWAsyncDisplayLayerDelegate;


@interface LWAsyncDisplayLayer : CALayer

@property (nonatomic,assign) BOOL displaysAsynchronously;//是否异步绘制，默认是YES
@property (nonatomic,strong,readonly) LWFlag* displayFlag;//一个自增的标识类，用于取消绘制。


/**
 *  立即绘制，在主线程
 */
- (void)displayImmediately;
/**
 *  取消异步绘制
 */
- (void)cancelAsyncDisplay;
/**
 *  LWAsyncDisplayLayer异步绘制时都会指定一个dispatch_queue_t，这个方法可以获取那个dispatch_queue_t
 *
 *  @return  LWAsyncDisplayLayer对象异步绘制所在的那个dispatch_queue_t
 */
+ (dispatch_queue_t)displayQueue;

@end

/**
 *  异步绘制任务的抽象，它包含的属性是三个Block可以分别在将要开始绘制时，绘制时，和绘制完成时都收到回调。
 */
@interface LWAsyncDisplayTransaction : NSObject

@property (nonatomic,copy) LWAsyncDisplayWillDisplayBlock willDisplayBlock;//即将要开始绘制
@property (nonatomic,copy) LWAsyncDisplayBlock displayBlock;//绘制的具体实现
@property (nonatomic,copy) LWAsyncDisplayDidDisplayBlock didDisplayBlock;//绘制已经完成

@end


@protocol LWAsyncDisplayLayerDelegate <NSObject>

/**
 *  异步绘制协议的协议方法
 *  @return 返回一个异步绘制任务的抽象LWAsyncDisplayTransaction对象，可以通过这个对象的属性来得到将要开始绘制时，绘制时，和绘制完成时的回调。
 */
- (LWAsyncDisplayTransaction *)asyncDisplayTransaction;

@end



