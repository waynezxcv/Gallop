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
#import "LWAsyncDisplayLayer.h"


/***  附件的对齐方式  ***/
typedef NS_ENUM(NSUInteger, LWTextAttachAlignment) {
    LWTextAttachAlignmentCenter,//attachment居中显示
    LWTextAttachAlignmentTop,//attachment的底部与baseline对齐
    LWTextAttachAlignmentBottom,//attachment的顶部与baseline对齐
};


/***  Text模型  ***/

@interface LWTextStorage : LWStorage<NSCopying,NSCoding>

@property (nonatomic,strong,readonly) LWTextLayout* textLayout;

@property (nonatomic,copy) NSString* text;
@property (nonatomic,strong) UIColor* textColor;
@property (nonatomic,strong) UIColor* textBackgroundColor;
@property (nonatomic,strong) UIFont* font;
@property (nonatomic,assign) CGFloat linespacing;
@property (nonatomic,assign) unichar characterSpacing;
@property (nonatomic,assign) NSTextAlignment textAlignment;
@property (nonatomic,assign) NSUnderlineStyle underlineStyle;
@property (nonatomic,strong) UIColor* underlineColor;
@property (nonatomic,assign) NSLineBreakMode lineBreakMode;
@property (nonatomic,assign) BOOL sizeToFit;

/***  构造方法  ***/
- (id)initWithFrame:(CGRect)frame;
+ (LWTextStorage *)lw_textStrageWithText:(NSAttributedString *)attributedText frame:(CGRect)frame;
+ (LWTextStorage *)lw_textStorageWithTextLayout:(LWTextLayout *)textLayout frame:(CGRect)frame;

/***  为整个文本添加链接  ***/
/* 如果两个点击事件重叠，会优先响应使用
 “- (void)lw_addLinkWithData:(id)data
 range:(NSRange)range
 linkColor:(UIColor *)linkColor
 highLightColor:(UIColor *)highLightColor;”这个方法添加的指定位置链接。
 */
- (void)lw_addLinkForWholeTextStorageWithData:(id)data
                                    linkColor:(UIColor *)linkColor
                               highLightColor:(UIColor *)highLightColor;

/***  为指定位置的文本添加链接  ***/
- (void)lw_addLinkWithData:(id)data
                     range:(NSRange)range
                 linkColor:(UIColor *)linkColor
            highLightColor:(UIColor *)highLightColor;

/***  用本地图片替换掉指定位置的文字  ***/
- (void)lw_replaceTextWithImage:(UIImage *)image
                    contentMode:(UIViewContentMode)contentMode
                      imageSize:(CGSize)size
                      alignment:(LWTextAttachAlignment)attachAlignment
                          range:(NSRange)range;

/***  用网络图片替换掉指定位置的文字  ***/
- (void)lw_replaceTextWithImageURL:(NSURL *)URL
                       contentMode:(UIViewContentMode)contentMode
                         imageSize:(CGSize)size
                         alignment:(LWTextAttachAlignment)attachAlignment
                             range:(NSRange)range;

/***  用UIView替换掉指定位置的文字  ***/
- (void)lw_replaceTextWithView:(UIView *)view
                   contentMode:(UIViewContentMode)contentMode
                          size:(CGSize)size
                     alignment:(LWTextAttachAlignment)attachAlignment
                         range:(NSRange)range;

@end
