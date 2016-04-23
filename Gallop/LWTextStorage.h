//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//  LWTextLayout.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//


#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "LWStorage.h"


/**
 *  垂直方向对齐方式
 */
typedef NS_ENUM(NSUInteger, LWVerticalAlignment){
    /**
     *  顶部对齐
     */
    LWVerticalAlignmentTop,
    /**
     *  居中
     */
    LWVerticalAlignmentCenter,
    /**
     *  底部对齐
     */
    LWVerticalAlignmentBottom,
};


@interface LWTextStorage : LWStorage

/**
 *  文本内容，默认为nil
 */
@property (nonatomic,copy) NSString* text;

/**
 *  属性文本，默认为nil
 */
@property (nonatomic,strong) NSMutableAttributedString* attributedText;

/**
 *  文本颜色，默认为RGB(0,0,0,1)
 */
@property (nonatomic,strong) UIColor* textColor;

/**
 *  文本背景颜色
 *
 */
@property (nonatomic,strong) UIColor* textBackgroundColor;


/**
 *  字体，默认为[UIFont systemFontOfSize:14.0f]
 */
@property (nonatomic,strong) UIFont* font;

/**
 *  行间距
 */
@property (nonatomic,assign) CGFloat linespace;

/**
 *  字间距
 */
@property (nonatomic, assign) unichar characterSpacing;

/**
 *  文本行数
 */
@property (nonatomic,assign) NSInteger numberOfLines;

/**
 *  水平方向对齐方式
 */
@property (nonatomic,assign) NSTextAlignment textAlignment;

/**
 *  垂直方向对齐方式
 */
@property (nonatomic,assign) LWVerticalAlignment veriticalAlignment;

/**
 *  下划线式样
 */
@property (nonatomic,assign) NSUnderlineStyle underlineStyle;

/**
 *  换行方式，默认为NSLineBreakByWordWrapping
 */
@property (nonatomic) NSLineBreakMode lineBreakMode;

/**
 *  ctFrameRef
 */
@property (nonatomic,assign) CTFrameRef CTFrame;

/**
 *  附件中网络图片的个数
 */
@property (nonatomic,assign,readonly) NSInteger webImageCount;

/**
 *  存放网络图片的附件
 */
@property (nonatomic,strong) NSMutableArray* webAttachs;

/**
 *  是否自动适配宽度
 */
@property (nonatomic,assign,getter=isWidthToFit) BOOL widthToFit;

/**
 *
 */
@property (nonatomic,strong) NSMutableArray* hightlights;

/**
 *  创建CTFrameRef
 *
 */
- (void)creatCTFrameRef;


/**
 *  清除附件
 */
- (void)removeAttachFromViewAndLayer;

/**
 *  绘制
 *
 */
- (void)drawInContext:(CGContextRef)context layer:(CALayer *)layer;

/**
 *  为指定位置的文本添加链接
 *
 */
- (void)addLinkWithData:(id)data
                inRange:(NSRange)range
              linkColor:(UIColor *)linkColor
         highLightColor:(UIColor *)highLightColor
         UnderLineStyle:(NSUnderlineStyle)underlineStyle;

/**
 *  为这个TextStorage添加链接
 *
 */
- (void)addLinkWithData:(id)data
         highLightColor:(UIColor *)highLightColor;

/**
 *  用本地图片替换掉指定位置的文字
 *
 */
- (NSMutableAttributedString *)replaceTextWithImage:(UIImage *)image imageSize:(CGSize)size inRange:(NSRange)range;

/**
 *  用网络图片替换掉指定位置的文字
 *
 */
- (void)replaceTextWithImageURL:(NSURL *)URL imageSize:(CGSize)size inRange:(NSRange)range;



#define kLWTextLinkAttributedName @"LWTextLinkAttributedName"

@end


typedef NS_ENUM(NSUInteger, LWTextAttachType) {
    LWTextAttachWebImage = 0,
    LWTextAttachLocalImage = 1,
};


@interface LWTextAttach : NSObject

@property (nonatomic,assign) LWTextAttachType type;
@property (nonatomic,strong) UIImage* image;
@property (nonatomic,assign) NSRange range;
@property (nonatomic,assign) CGRect imagePosition;
@property (nonatomic,strong) NSURL* URL;
@property (nonatomic,strong) id content;

@end


@interface LWTextHightlight : NSObject

@property (nonatomic,strong) UIColor* hightlightColor;
@property (nonatomic,copy) NSArray* positions;
@property (nonatomic,strong) id linkAttributes;

@end


