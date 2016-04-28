/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/




#import <Foundation/Foundation.h>
#import "LWTextStorage.h"

@interface LWTextParser : NSObject


/**
 *  解析表情替代为相应的图片
 *  格式：text：@“hello,world~![微笑]”  ----> @"hello，world~！（[UIImage imageNamed：@“[微笑]”]）"
 *
 */
+ (void)parseEmojiWithTextStorage:(LWTextStorage *)textStorage;


/**
 *  解析HTTP(s):// 并添加链接
 *
 */
+ (void)parseHttpURLWithTextStorage:(LWTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor
                     underlineStyle:(NSUnderlineStyle)underlineStyle;

/**
 *  解析 @用户 并添加链接
 *
 */

+ (void)parseAccountWithTextStorage:(LWTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor
                     underlineStyle:(NSUnderlineStyle)underlineStyle;


/**
 *  解析 #主题# 并添加链接
 *
 */
+ (void)parseTopicWithLWTextStorage:(LWTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor
                     underlineStyle:(NSUnderlineStyle)underlineStyle;
@end
