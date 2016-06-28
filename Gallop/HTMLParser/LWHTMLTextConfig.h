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

@interface LWHTMLTextConfig : NSObject

@property (nonatomic,strong) UIColor* textColor;
@property (nonatomic,strong) UIColor* textBackgroundColor;
@property (nonatomic,strong) UIFont* font;
@property (nonatomic,assign) CGFloat linespacing;
@property (nonatomic,assign) unichar characterSpacing;
@property (nonatomic,assign) NSTextAlignment textAlignment;
@property (nonatomic,assign) NSUnderlineStyle underlineStyle;
@property (nonatomic,strong) UIColor* underlineColor;
@property (nonatomic,assign) NSLineBreakMode lineBreakMode;
@property (nonatomic,assign) LWTextDrawMode textDrawMode;
@property (nonatomic,strong) UIColor* strokeColor;
@property (nonatomic,assign) CGFloat strokeWidth;
@property (nonatomic,strong) UIColor* linkColor;
@property (nonatomic,strong) UIColor* linkHighlightColor;
@property (nonatomic,assign) CGFloat paragraphSpacing;

+ (LWHTMLTextConfig *)defaultsTextConfig;

@end
