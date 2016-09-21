
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
#import "LWStorage.h"
#import "GallopUtils.h"

/**
 *  如果是本地图片，可以选择是直接绘制在LWAsyncDisplayView上还是新建一个UIView并add到LWAsyncDisplayView上
 */
typedef NS_ENUM(NSUInteger, LWLocalImageType){
    /**
     *  直接绘制在LWAsyncDisplayView上
     */
    LWLocalImageDrawInLWAsyncDisplayView,
    /**
     *  新建一个UIView并add到LWAsyncDisplayView上
     */
    LWLocalImageTypeDrawInSubView,
};

/**
 *   图片绘制的数据模型
 */
@interface LWImageStorage : LWStorage

@property (nonatomic,strong) id contents;//内容（UIImage or NSURL）
@property (nonatomic,assign) LWLocalImageType localImageType;//本地图片的种类，默认是LWLocalImageDrawInLWAsyncDisplayView
@property (nonatomic,strong) UIImage* placeholder;//占位图
@property (nonatomic,assign,getter=isFadeShow) BOOL fadeShow;//加载完成是否渐隐出现
@property (nonatomic,assign, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;//是否响应用户事件，默认是YES
@property (nonatomic,assign,readonly) BOOL needRerendering;//是否需要重新绘制
@property (nonatomic,assign) BOOL needResize;//是否需要重新设置大小,不要去设置这个值，这个用于LWHTMLDisplayView重新调整图片大小比例
@property (nonatomic,assign) BOOL isBlur;//是否模糊处理

/**
 *  绘制图片
 *
 *  @param context    一个CGContextRef对象，绘制上下文
 *  @param isCancelld 是否取消绘制
 */
- (void)lw_drawInContext:(CGContextRef)context isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld;

/**
 *  伸缩绘制
 *
 *  @param leftCapWidth 图片左边伸缩点
 *  @param topCapHeight 图片的上边伸缩点
 */
- (void)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

@end


/**
 *  LWImageStorage对UIView的扩展
 */
@interface UIView (LWImageStorage)


@property (nonatomic,copy) NSString* identifier;//一个标示符字符串，跟LWImageStorage中的同名属性对应

/**
 * 设置一个LWImageStorage对象给UIView对象，从而完成图片的渲染
 *
 *  @param imageStorage 一个LWImageStorage对象
 *  @param resizeBlock  重新调整图片大小回调Block
 */
- (void)setContentWithImageStorage:(LWImageStorage *)imageStorage
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

@end


