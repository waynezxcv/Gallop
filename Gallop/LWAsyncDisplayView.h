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
#import "GallopUtils.h"
#import "LWLayout.h"


@class LWAsyncDisplayLayer;
@class LWAsyncDisplayView;
@class LWTextStorage;
@class LWImageStorage;
@class LWAsyncImageView;


@protocol LWAsyncDisplayViewDelegate <NSObject>

@optional

/**
 *  通过LWTextStorage的“- (void)lw_addLinkForWholeTextStorageWithData:(id)data linkColor:(UIColor *)linkColor highLightColor:(UIColor *)highLightColor;”方法添加的文字链接，点击时可以在这个代理方法里收到回调。
 *
 *  @param asyncDisplayView LWTextStorage所处的LWAsyncDisplayView
 *  @param textStorage      点击的那个LWTextStorage对象
 *  @param data             添加点击链接时所附带的信息。
 */
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedTextStorage:(LWTextStorage *)textStorage linkdata:(id)data;

/**
 *  通过LWTextStorage添加的文字长按事件，长按时可以在这个代理方法里收到回调。
 *
 *  @param asyncDisplayView LWTextStorage所处的LWAsyncDisplayView
 *  @param textStorage      点击的那个LWTextStorage对象
 *  @param data             添加点击链接时所附带的信息。
 */
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didLongpressedTextStorage:(LWTextStorage *)textStorage linkdata:(id)data;


/**
 *  点击LWImageStorage时，可以在这个代理方法里收到回调
 *
 *  @param asyncDisplayView LWImageStorage所处的LWAsyncDisplayView
 *  @param imageStorage     点击的那个LWImageStorage对象
 *  @param touch            点击事件的UITouch对象
 */
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedImageStorage:(LWImageStorage *)imageStorage touch:(UITouch *)touch;

/**
 *  可以在这个代理方法里完成额外的绘制任务，相当于UIView的“drawRect:”方法。但是在这里绘制任务的都是在子线程完成的。
 *
 *  @param context     CGContextRef对象
 *  @param size        绘制空间的大小，需要在这个size的范围内绘制
 *  @param isCancelled 是否取消
 */
- (void)extraAsyncDisplayIncontext:(CGContextRef)context size:(CGSize)size isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelled;

@end

/**
 *  在使用LWHTMLView时，因为解析HTML取得图片时，并不知道图片的大小比例，这个回调用于获取下载完图片后调整UIView的大小。
 *
 *  @param imageStorage LWImageStorage对象
 *  @param delta        下载完的图片高度与预填充图片高度的差
 */
typedef void(^LWAsyncDisplayViewAutoLayoutCallback)(LWImageStorage* imageStorage ,CGFloat delta);


@interface LWAsyncDisplayView : UIView

@property (nonatomic,strong) id <LWLayoutProtocol> layout;//布局模型,需要遵循LWLayoutProtocol协议
@property (nonatomic,weak) id <LWAsyncDisplayViewDelegate> delegate;//代理对象
@property (nonatomic,assign) BOOL displaysAsynchronously;//是否异步绘制，默认是YES
@property (nonatomic,copy) LWAsyncDisplayViewAutoLayoutCallback auotoLayoutCallback;//自动布局回调Block
@property (nonatomic,strong,readonly) UILongPressGestureRecognizer* longPressGesture;//长按手势


/**
 *  移除高亮显示
 *
 */
- (void)removeHighlightIfNeed;

@end
