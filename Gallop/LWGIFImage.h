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


@interface LWGIFImage : UIImage

/**
 * 第一帧图片
 */
@property (nonatomic, strong, readonly) UIImage* coverImage;

/**
 * 保存了帧索引对应的时间的字典
 */
@property (nonatomic, strong, readonly) NSDictionary* timesForIndex;

/**
 * 播放循环次数
 */
@property (nonatomic, assign, readonly) NSUInteger loopCount;

/**
 * 总帧数
 */
@property (nonatomic, assign, readonly) NSUInteger frameCount;

/**
 * 构造方法
 */
- (id)initWithGIFData:(NSData *)data;

/**
 * 获取帧索引对应的图片
 */
- (UIImage *)frameImageWithIndex:(NSInteger)index;


@end

extern const NSTimeInterval kLWGIFDelayTimeIntervalMinimumValue;


/**
 * 这个代理对象有一个weak的target对象，用来实现转发消息,并避免循环引用
 */

@interface LWProxy : NSProxy

@property (nonatomic,weak) id target;
+ (instancetype)proxyWithObject:(id)object;

@end



