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

#import "LWTextStorage.h"
#import "NSMutableAttributedString+Gallop.h"




@interface LWTextStorage ()

@property (nonatomic,strong) LWTextLayout* textLayout;

@end

#pragma mark - Init

@implementation LWTextStorage


#pragma mark - Init

+ (LWTextStorage *)lw_textStorageWithTextLayout:(LWTextLayout *)textLayout frame:(CGRect)frame {
    LWTextStorage* textStorage = [[LWTextStorage alloc] initWithFrame:frame];
    textStorage.textLayout = textLayout;
    return textStorage;
}

+ (LWTextStorage *)lw_textStrageWithText:(NSAttributedString *)text frame:(CGRect)frame {
    LWTextStorage* textStorage = [[LWTextStorage alloc] initWithFrame:frame];
    textStorage.attributedText = [text mutableCopy];
    textStorage.textLayout = [textStorage _creatTextLayout];
    return textStorage;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.frame = frame;
        self.text = nil;
        self.attributedText = nil;
        self.textColor = [UIColor blackColor];
        self.font = [UIFont systemFontOfSize:14.0f];
        self.textAlignment = NSTextAlignmentLeft;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.linespacing = 2.0f;
        self.characterSpacing = 1.0f;
        self.underlineStyle = NSUnderlineStyleNone;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.text = nil;
        self.attributedText = nil;
        self.textColor = [UIColor blackColor];
        self.font = [UIFont systemFontOfSize:14.0f];
        self.textAlignment = NSTextAlignmentLeft;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.frame = CGRectZero;
        self.linespacing = 2.0f;
        self.characterSpacing = 1.0f;
        self.underlineStyle = NSUnderlineStyleNone;
    }
    return self;
}

#pragma mark - Methods

/***  为指定位置的文本添加链接  ***/
- (void)lw_addLinkWithData:(id)data range:(NSRange)range linkColor:(UIColor *)linkColor highLightColor:(UIColor *)highLightColor {
    [self.attributedText addLinkWithData:data range:range linkColor:linkColor highLightColor:highLightColor];
}

/***  用本地图片替换掉指定位置的文字  ***/
- (void)lw_replaceTextWithImage:(UIImage *)image
                    contentMode:(UIViewContentMode)contentMode
                      imageSize:(CGSize)size
                      alignment:(LWTextAttachAlignment)attachAlignment
                          range:(NSRange)range {
    if (!self.attributedText) {
        return;
    }
    CGFloat ascent,descent = 0.0f;
    switch (attachAlignment) {
        case LWTextAttachAlignmentTop: {
            ascent = size.height;
            descent = 0.0f;
        }
            break;
        case LWTextAttachAlignmentCenter:{
            ascent = size.height/2;
            descent = size.height/2;
        }
            break;
        case LWTextAttachAlignmentBottom:{
            ascent = 0.0f;
            descent = size.height;
        }
            break;
    }
    NSMutableAttributedString* attachString = [NSMutableAttributedString lw_textAttachmentStringWithContent:image
                                                                                                contentMode:contentMode
                                                                                                     ascent:ascent
                                                                                                    descent:descent
                                                                                                      width:size.width];

    [self.attributedText replaceCharactersInRange:range withAttributedString:attachString];
}

/***  用网络图片替换掉指定位置的文字  ***/
- (void)lw_replaceTextWithImageURL:(NSURL *)URL
                       contentMode:(UIViewContentMode)contentMode
                         imageSize:(CGSize)size
                         alignment:(LWTextAttachAlignment)attachAlignment
                             range:(NSRange)range {

}

/***  用UIView替换掉指定位置的文字  ***/
- (void)lw_replaceTextWithView:(UIView *)view
                     imageSize:(CGSize)size
                     alignment:(LWTextAttachAlignment)attachAlignment
                         range:(NSRange)range {

}


- (void)lw_drawInContext:(CGContextRef)context {

}


#pragma mark - Setter

- (void)setText:(NSString *)text {
    if (!text) {
        return;
    }
    if (_text != text) {
        _text = [text copy];
    }
    [self _creatTextLayout];
}

- (void)setAttributedText:(NSMutableAttributedString *)attributedText {
    if (!attributedText) {
        return;
    }
    if (_attributedText != attributedText) {
        _attributedText = attributedText;
    }
    self.text = [_attributedText.string copy];
    [self _creatTextLayout];
}

- (void)setTextColor:(UIColor *)textColor {
    if (!textColor) {
        return;
    }
    if (_textColor != textColor) {
        _textColor = textColor;
    }
    [self _creatTextLayout];
}

- (void)setTextBackgroundColor:(UIColor *)textBackgroundColor {
    if (!textBackgroundColor) {
        return;
    }
    if (_textBackgroundColor != textBackgroundColor) {
        _textBackgroundColor = textBackgroundColor;
    }
    [self _creatTextLayout];
}

- (void)setFont:(UIFont *)font {
    if (!font) {
        return;
    }
    if (_font != font) {
        _font = font;
    }
    [self _creatTextLayout];
}

- (void)setCharacterSpacing:(unichar)characterSpacing {
    if (!characterSpacing) {
        return;
    }
    if (_characterSpacing != characterSpacing) {
        _characterSpacing = characterSpacing;
    }
    [self _creatTextLayout];
}

- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle {
    if (!underlineStyle) {
        return;
    }
    if (_underlineStyle != underlineStyle) {
        _underlineStyle = underlineStyle;
    }
    [self _creatTextLayout];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (!textAlignment) {
        return;
    }
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;
    }
    [self _creatTextLayout];
}

- (void)setLinespacing:(CGFloat)linespacing {
    if (!linespacing) {
        return;
    }
    if (_linespacing != linespacing) {
        _linespacing = linespacing;
    }
    [self _creatTextLayout];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (!lineBreakMode) {
        return;
    }
    if (_lineBreakMode != lineBreakMode) {
        _lineBreakMode = lineBreakMode;
    }
    [self _creatTextLayout];
}

- (LWTextLayout *)_creatTextLayout {
    NSMutableAttributedString* mutableAttributedString = nil;
    if (!self.text) {
        return nil;
    }
    if (!self.attributedText) {
        mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:nil];
    }
    else {
        mutableAttributedString = [self.attributedText mutableCopy];
    }
    LWTextContainer* textContainer = [LWTextContainer lw_textContainerWithSize:self.frame.size];
    LWTextLayout* textLayout = [LWTextLayout lw_layoutWithContainer:textContainer text:mutableAttributedString];
    return textLayout;
}


@end
