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

/**
 *  包含各种布局数据和其他数据的抽象模型，本身并不能直接拿来使用。
 *  它的子类LWTextStorage、LWImageStorage、LWVideoStorage可以分别用于存储文字、图片。
 */
@interface LWStorage : NSObject <NSCoding>

@property (nullable,nonatomic,copy) NSString* identifier;//一个标示字符串，可以用于复用时取到属性相同的UIView对象
@property (nonatomic,assign) NSInteger tag;//一个标示符，跟UIView对象的tag属性作用一样
@property (nonatomic,assign) BOOL clipsToBounds;//是否在边缘剪切，跟UIView对象的clipsToBounds属性作用一样
@property (nonatomic,getter = isOpaque) BOOL opaque;//跟UIView对象的同名属性作用一样
@property (nonatomic,getter = isHidden) BOOL hidden;//跟UIView对象的同名属性作用一样
@property (nonatomic,assign) CGFloat alpha;//跟UIView对象的同名属性作用一样
@property (nonatomic,assign) CGRect frame;//跟UIView对象的同名属性作用一样
@property (nonatomic,assign) CGRect bounds;//跟UIView对象的同名属性作用一样


@property (nonatomic,assign,readonly) CGFloat height;//跟UIView对象的frame.size.height作用一样
@property (nonatomic,assign,readonly) CGFloat width;//跟UIView对象的frame.size.width作用一样
@property (nonatomic,assign,readonly) CGFloat left;//跟UIView对象的frame.origin.x作用一样
@property (nonatomic,assign,readonly) CGFloat right;//跟UIView对象的frame.origin.x+frame.size.width作用一样
@property (nonatomic,assign,readonly) CGFloat top;//跟UIView对象的frame.origin.y作用一样
@property (nonatomic,assign,readonly) CGFloat bottom;//跟UIView对象的frame.origin.y+frame.size.height作用一样


@property (nonatomic,assign) CGPoint center;//跟UIView对象的同名属性作用一样
@property (nonatomic,assign) CGPoint position;//跟UIView对象的同名属性作用一样
@property (nonatomic,assign) CGFloat cornerRadius;//跟CALayer对象的同名属性作用一样
@property (nonatomic,strong,nullable) UIColor* cornerBackgroundColor;//圆角半径部分的背景颜色
@property (nonatomic,strong,nullable) UIColor* cornerBorderColor;//圆角半径的描边颜色
@property (nonatomic,assign) CGFloat cornerBorderWidth;//圆角半径的描边宽度
@property (nonatomic,assign,nullable) UIColor* shadowColor;//跟CALayer对象的同名属性作用一样
@property (nonatomic,assign) CGFloat shadowOpacity;//跟CALayer对象的同名属性作用一样
@property (nonatomic,assign) CGSize shadowOffset;//跟CALayer对象的同名属性作用一样
@property (nonatomic,assign) CGFloat shadowRadius;//跟CALayer对象的同名属性作用一样
@property (nonatomic,assign) CGFloat contentsScale;//跟CALayer对象的同名属性作用一样
@property (nonatomic,strong,nullable) UIColor* backgroundColor;//跟UIView对象的同名属性作用一样
@property (nonatomic,assign) UIViewContentMode contentMode;//跟UIView对象的同名属性作用一样

#pragma mark - HTMLDisplayView
@property (nonatomic,assign) UIEdgeInsets htmlLayoutEdgeInsets;//私有属性，用于LWHTMLDisplayView设置内容的UIEdgeInsets
@property (nonatomic,copy,nullable) NSString* extraDisplayIdentifier;//额外绘制的标记字符串

/**
 *  设置一个标示字符串并初始化一个LWStorage对象
 *
 *  @param identifier 一个标示字符串
 *
 *  @return 一个LWStorage对象
 */
- (_Nonnull id)initWithIdentifier:(NSString * _Nullable )identifier;

@end
