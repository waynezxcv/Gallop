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


#define LWTextAttachmentAttributeName @"LWTextAttachmentKey"
#define LWTextLinkAttributedName @"LWTextLinkAttributedName"
#define LWTextLongPressAttributedName @"LWTextLongPressAttributedName"
#define LWTextBackgroundColorAttributedName @"LWTextBackgroundColorAttributedName"
#define LWTextStrokeAttributedName @"LWTextStrokeAttributedName"
#define LWTextBoundingStrokeAttributedName @"LWTextBoundingStrokeAttributedName"


typedef NS_ENUM(NSUInteger, LWTextHighLightType) {
    LWTextHighLightTypeNormal,
    LWTextHighLightTypeWholeText,
    LWTextHighLightTypeLongPress,
};

/**
 *  文本的附件的封装，可以是图片或是UIView对象、CALayer对象
 */
@interface LWTextAttachment : NSObject<NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,strong) id content;//内容
@property (nonatomic,assign) NSRange range;//在string中的range
@property (nonatomic,assign) CGRect frame;//frame
@property (nonatomic,strong) NSURL* URL;//URL
@property (nonatomic,assign) UIViewContentMode contentMode;//内容模式
@property (nonatomic,assign) UIEdgeInsets contentEdgeInsets;//边缘内嵌大小
@property (nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息

/**
 *  构造方法
 *
 *  @param object 可以是UIImage对象、UIView对象、CALayer对象。
 *  如果是UIImage对象，会使用CoreGraphics方法来绘制
 *
 *  @return LWTextAttachment实例对象
 */
+ (id)lw_textAttachmentWithContent:(id)content;

@end


/**
 *  文本链接的封装
 */
@interface LWTextHighlight : NSObject <NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,assign) NSRange range;//在字符串的range
@property (nonatomic,strong) UIColor* linkColor;//链接的颜色
@property (nonatomic,strong) UIColor* hightlightColor;//高亮颜色
@property (nonatomic,copy) NSArray<NSValue *>* positions;//位置数组
@property (nonatomic,strong) id content;//内容
@property (nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息
@property (nonatomic,assign) LWTextHighLightType type;//高亮类型

@end



/**
 *  文本背景颜色的封装
 */
@interface LWTextBackgroundColor : NSObject  <NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,assign) NSRange range;//在字符串的range
@property (nonatomic,strong) UIColor* backgroundColor;//背景颜色
@property (nonatomic,copy) NSArray<NSValue *>* positions;//位置数组
@property (nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息

@end


/**
 *  文本描边的封装（空心字）
 */
@interface LWTextStroke : NSObject  <NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,assign) NSRange range;//在字符串的range
@property (nonatomic,strong) UIColor* strokeColor;//描边颜色
@property (nonatomic,assign) CGFloat strokeWidth;//描边的宽度
@property (nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息

@end

/**
 *  文本边框
 */

@interface LWTextBoundingStroke : NSObject<NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,assign) NSRange range;//在字符串的range
@property (nonatomic,strong) UIColor* strokeColor;//描边颜色
@property (nonatomic,copy) NSArray<NSValue *>* positions;//位置数组
@property (nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息


@end

