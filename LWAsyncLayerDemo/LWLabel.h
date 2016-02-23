//
//  LWLabel.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWTextLayout.h"

/**
 *  LWLabel 支持属性文本、图文混排、点击链接、异步绘制。
 */
@interface LWLabel : UIView

/**
 *  文本内容，默认为nil
 */
@property (nonatomic,copy) NSString* text;

/**
 *  文本颜色，默认为RGB(0,0,0,1)
 */
@property (nonatomic,strong) UIColor* textColor;

/**
 *  字体，默认为[UIFont systemFontOfSize:14.0f]
 */
@property (nonatomic,strong) UIFont* font;

/**
 *  背景颜色，默认为Clear
 */
@property (nonatomic,strong) UIColor* backgroundColor;

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
 *  换行方式，默认为NSLineBreakByWordWrapping
 */
@property (nonatomic) NSLineBreakMode lineBreakMode;

/**
 *  属性文本，默认为nil
 */
@property (nonatomic,copy) NSAttributedString* attributedText;

/**
 *  存放文字盘版的数组
 */
@property (nonatomic,copy) NSArray* layouts;

/**
 *  初始化一个LWLabel
 *
 *  @param frame LWLabe的Frame
 *
 *  @return LWLabel实例
 */
- (id)initWithFrame:(CGRect)frame;

/**
 *  在指定位置插入一个图片
 *
 */
- (void)insertImage:(UIImage *)image inRange:(NSRange)range;


/**
 *  在指定多个位置插入图片
 *
 */
- (void)inserImages:(NSArray *)images inRanges:(NSArray *)ranges;

/**
 *  用图片替换掉指定位置的文字
 *
 */
- (void)replaceTextWithImage:(UIImage *)image inRange:(NSRange)range;

/**
 *  在多个位置用图片替换掉指定位置的文字
 *
 */
- (void)replaceTextWithImages:(NSArray *)images inRanges:(NSArray *)ranges;


/**
 *  为指定位置的文本添加链接
 *
 */
- (void)addLinkWithData:(id)data inRange:(NSRange)range;



@end
