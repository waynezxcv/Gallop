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

/**
 * UIView的绘制扩展
 *
 */
@interface UIView (DisplayAddtions)



@property (nonatomic,copy) NSString* identifier;//一个标示符字符串，跟LWImageStorage中的同名属性对应

/**
 * 设置一个LWImageStorage对象给UIView对象，从而完成图片的渲染
 *
 *  @param imageStorage 一个LWImageStorage对象
 *  @param resizeBlock  重新调整图片大小回调Block
 */
- (void)setContentWithImageStorage:(LWImageStorage *)imageStorage
            displaysAsynchronously:(BOOL)displaysAsynchronously
                       resizeBlock:(void(^)(LWImageStorage*imageStorage, CGFloat delta))resizeBlock;


/**
 *  设置一个LWImageStorage对象给UIView对象，从而完成位置布局
 *
 *  @param imageStorage 一个LWImageStorage对象
 */
- (void)layoutWithStorage:(LWImageStorage *)imageStorage;


/**
 *  清除UIView对象上的内容，并隐藏
 */
- (void)cleanup;


- (void)fadeShowAnimation;

@end
