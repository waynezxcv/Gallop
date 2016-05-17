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
#import "LWStorage.h"
#import "LWTextLayout.h"

@interface LWTextStorage : LWStorage

@property (nonatomic,strong,readonly) LWTextLayout* textLayout;
@property (nonatomic,copy) NSString* text;
@property (nonatomic,strong) NSMutableAttributedString* attributedText;
@property (nonatomic,strong) UIColor* textColor;
@property (nonatomic,strong) UIColor* textBackgroundColor;
@property (nonatomic,strong) UIFont* font;
@property (nonatomic,assign) CGFloat linespace;
@property (nonatomic,assign) unichar characterSpacing;
@property (nonatomic,assign) NSInteger numberOfLines;
@property (nonatomic,assign) NSTextAlignment textAlignment;
@property (nonatomic,assign) NSUnderlineStyle underlineStyle;
@property (nonatomic,assign) NSLineBreakMode lineBreakMode;
@property (nonatomic,assign) CTFrameRef CTFrame;
@property (nonatomic,assign,readonly) NSInteger webImageCount;
@property (nonatomic,strong) NSMutableArray* webAttachs;
@property (nonatomic,assign,getter=isWidthToFit) BOOL widthToFit;
@property (nonatomic,strong) NSMutableArray* hightlights;


/***  构造方法  ***/
- (id)initWithFrame:(CGRect)frame;
+ (LWTextStorage *)LW_textStrageWithText:(NSAttributedString *)text frame:(CGRect)frame;
+ (LWTextStorage *)lw_textStorageWithTextLayout:(LWTextLayout *)textLayout frame:(CGRect)frame;

/*** 绘制 ***/
- (void)lw_drawInContext:(CGContextRef)context;

/***  为指定位置的文本添加链接  ***/
- (void)lw_addLinkWithData:(id)data
                   inRange:(NSRange)range
                 linkColor:(UIColor *)linkColor
            highLightColor:(UIColor *)highLightColor
            UnderLineStyle:(NSUnderlineStyle)underlineStyle;

/***  用本地图片替换掉指定位置的文字  ***/
- (void)lw_replaceTextWithImage:(UIImage *)image imageSize:(CGSize)size inRange:(NSRange)range;

/***  用网络图片替换掉指定位置的文字  ***/
- (void)lw_replaceTextWithImageURL:(NSURL *)URL imageSize:(CGSize)size inRange:(NSRange)range;


@end
