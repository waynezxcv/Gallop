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


@class LWImageStorage;
@class LWGIFImage;


@interface LWAsyncImageView : UIImageView

/**
 *  一个标示符字符串，跟LWImageStorage中的同名属性对应.
 *  当LWAsyncImageView不需要时，会放入LWAsyncDisplayView的reusePool当中
 *  需要用到时，通过这个identifier为key去reusePool中取
 */
@property (nonatomic,copy) NSString* identifier;


/**
 *  是否启动异步绘制
 *  YES时，会把对layer.conents，setFrame等赋值任务加入到LWTransactionGroup队列中
 *  然后通过观察主线程RunLoop的状态为 kCFRunLoopBeforeWaiting | kCFRunLoopExit 时才执行
 */
@property (nonatomic,assign) BOOL displayAsynchronously;


/**
 *  GIF动画图片模型
 *
 *
 */
@property (nonatomic,strong) LWGIFImage* gifImage;

/**
 *  如果图片是gif，可以指定动画播放模式。
 *  NSDefaultRunLoopMode:当UIScrollView及其子类对象滚动式，将暂停播放
 *  NSRunLoopCommonModes：当UIScrollView及其子类对象滚动式，不会暂停播放
 *
 */
@property (nonatomic,copy) NSString* animationRunLoopMode;



@end
