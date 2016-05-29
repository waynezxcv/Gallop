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

/***  Image模型  ***/
@interface LWImageStorage : LWStorage <NSCopying,NSCoding>

@property (nonatomic,strong) id contents;//内容（UIImage or NSURL）
@property (nonatomic,strong) UIImage* placeholder;//占位图
@property (nonatomic,assign,getter=isFadeShow) BOOL fadeShow;//加载完成是否渐隐出现
@property (nonatomic,assign, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;


/*** 绘制 ***/
- (void)lw_drawInContext:(CGContextRef)context isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld;
- (void)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

@end

@interface UIView (LWImageStorage)


@property (nonatomic,copy) NSString* identifier;

- (void)setContentWithImageStorage:(LWImageStorage *)imageStorage;
- (void)layoutWithStorage:(LWImageStorage *)imageStorage;
- (void)cleanup;

@end

