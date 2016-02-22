//
//  LWTextLayout.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

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
 *  下划线式样
 */
typedef NS_ENUM(NSUInteger, LWUnderlineStyle){
    /**
     *  无下划线
     */
    LWUnderlineStyleNone,
    /**
     *  单下划线
     */
    LWUnderlineStyleSingle,
    /**
     *  加粗下划线
     */
    LWUnderlineStyleThick,
    /**
     *  双下划线
     */
    LWUnderlineStyleDouble
};



@interface LWTextLayout : NSObject

/**
 *  文本内容，默认为nil
 */
@property (nonatomic,copy) NSString* text;

/**
 *  属性文本，默认为nil
 */
@property (nonatomic,copy) NSAttributedString* attributedText;

/**
 *  文本颜色，默认为RGB(0,0,0,1)
 */
@property (nonatomic,strong) UIColor* textColor;

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
 *  换行方式，默认为NSLineBreakByWordWrapping
 */
@property (nonatomic) NSLineBreakMode lineBreakMode;

/**
 *  ctFrameSetter
 */
@property (nonatomic,assign) CTFramesetterRef frameSetter;

/**
 *  ctFrameRef
 */
@property (nonatomic,assign) CTFrameRef frame;

/**
 *  text路径
 */
@property (nonatomic,assign) CGMutablePathRef textPath;

/**
 *  文字高度
 */
@property (nonatomic,assign) CGFloat textHeight;

/**
 *
 */
@property (nonatomic,assign) CGRect boundsRect;


- (void)drawInContext:(CGContextRef)context;


@end
