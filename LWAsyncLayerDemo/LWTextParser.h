//
//  LWTextParser.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/3/7.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWTextLayout.h"

@interface LWTextParser : NSObject


/**
 *  解析表情替代为相应的图片
 *  格式：text：@“hello,world~![微笑]”  ----> @"hello，world~！（[UIImage imageNamed：@“[微笑]”]）"
 *
 */
+ (void)parseEmojiWithTextLayout:(LWTextLayout *)textLayout;


/**
 *  解析HTTP(s):// 并添加链接
 *
 */
+ (void)parseHttpURLWithTextLayout:(LWTextLayout *)textLayout
                         linkColor:(UIColor *)linkColor
                    highlightColor:(UIColor *)higlightColor
                    underlineStyle:(NSUnderlineStyle)underlineStyle;

/**
 *  解析 @用户 并添加链接
 *
 */

+ (void)parseAccountWithTextLayout:(LWTextLayout *)textLayout
                         linkColor:(UIColor *)linkColor
                    highlightColor:(UIColor *)higlightColor
                    underlineStyle:(NSUnderlineStyle)underlineStyle;


/**
 *  解析 #主题# 并添加链接
 *
 */
+ (void)parseTopicWithTextLayout:(LWTextLayout *)textLayout
                       linkColor:(UIColor *)linkColor
                  highlightColor:(UIColor *)higlightColor
                  underlineStyle:(NSUnderlineStyle)underlineStyle;
@end
