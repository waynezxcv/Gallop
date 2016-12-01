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
#import "LWTextStorage.h"

@interface LWHTMLTextConfig : NSObject <NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,strong) UIColor* textColor;//文本颜色
@property (nonatomic,strong) UIColor* textBackgroundColor;//文本背景颜色
@property (nonatomic,strong) UIFont* font;//文本字体
@property (nonatomic,assign) CGFloat linespacing;//行间距
@property (nonatomic,assign) unichar characterSpacing;//字间距
@property (nonatomic,assign) NSTextAlignment textAlignment;//文本水平对齐方式
@property (nonatomic,assign) NSUnderlineStyle underlineStyle;//下划线样式
@property (nonatomic,strong) UIColor* underlineColor;//下滑线颜色
@property (nonatomic,assign) NSLineBreakMode lineBreakMode;//换行方式
@property (nonatomic,assign) LWTextDrawMode textDrawMode;//绘制模式
@property (nonatomic,strong) UIColor* strokeColor;//描边颜色
@property (nonatomic,assign) CGFloat strokeWidth;//描边宽度
@property (nonatomic,strong) UIColor* linkColor;//链接颜色
@property (nonatomic,strong) UIColor* linkHighlightColor;//链接点击时高亮颜色
@property (nonatomic,assign) UIEdgeInsets edgeInsets;//设置该storage的edgeInsets，优先级高于paragraphEdgeInsets
@property (nonatomic,copy) NSString* extraDisplayIdentifier;//额外绘制的标记字符串

/**
 *  获取一个默认的样式设置
 *
 *  @return 一个默认样式的LWHTMTextCofing对象
 */
+ (LWHTMLTextConfig *)defaultsTextConfig;
+ (LWHTMLTextConfig *)defaultsH1TextConfig;
+ (LWHTMLTextConfig *)defaultsH2TextConfig;
+ (LWHTMLTextConfig *)defaultsH3TextConfig;
+ (LWHTMLTextConfig *)defaultsH4TextConfig;
+ (LWHTMLTextConfig *)defaultsH5TextConfig;
+ (LWHTMLTextConfig *)defaultsH6TextConfig;
+ (LWHTMLTextConfig *)defaultsParagraphTextConfig;
+ (LWHTMLTextConfig *)defaultsQuoteTextConfig;


@end
