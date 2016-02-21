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
 *  文字排版属性
 */
@property (nonatomic,strong) LWTextLayout* textLayout;

/**
 *  初始化一个LWLabel
 *
 *  @param frame LWLabe的Frame
 *
 *  @return LWLabel实例
 */
- (id)initWithFrame:(CGRect)frame;



@end
