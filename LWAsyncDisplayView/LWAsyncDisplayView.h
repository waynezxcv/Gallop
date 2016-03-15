//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//  LWLabel.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//


#import <Foundation/Foundation.h>
#import "LWTextLayout.h"


@class LWAsyncDisplayView;

@protocol LWAsyncDisplayViewDelegate <NSObject>

@optional
/**
 *  点击链接回调
 *
 */
- (void)lwAsyncDicsPlayView:(LWAsyncDisplayView *)lwLabel didCilickedLinkWithfData:(id)data;

/**
 *  额外的绘制任务在这里实现
 *
 */
- (void)extraAsyncDisplayIncontext:(CGContextRef)context size:(CGSize)size;

@end

/**
 *  LWLabel 支持属性文本、图文混排、点击链接、异步绘制。
 */
@interface LWAsyncDisplayView : UIView

@property (nonatomic,weak) id <LWAsyncDisplayViewDelegate> delegate;

/**
 *  存放文字排版的数组
 */
@property (nonatomic,copy) NSArray* layouts;

@end
