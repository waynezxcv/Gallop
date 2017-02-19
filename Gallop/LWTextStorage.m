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
#import <objc/runtime.h>
#import "GallopDefine.h"



@interface LWTextStorage ()

@property (nonatomic,strong) LWTextLayout* textLayout;
@property (nonatomic,assign) CGSize suggestSize;//建议的绘制大小
@property (nonatomic,assign) NSInteger numberOfLines;//文本的实际行数
@property (nonatomic,assign) BOOL isTruncation;//是否折叠

@end


@implementation LWTextStorage

@synthesize frame = _frame;
@synthesize position = _position;
@synthesize text = _text;


#pragma mark - Override Hash & isEqual

- (BOOL)isEqual:(id)object {
    if (!object || ![object isMemberOfClass:[LWTextStorage class]]) {
        return NO;
    }
    if (self == object) {
        return YES;
    }
    LWTextStorage* textStorage = (LWTextStorage *)object;
    return [textStorage.text isEqualToString:self.text] && CGRectEqualToRect(textStorage.frame, self.frame);
}

- (NSUInteger)hash {
    long v1 = (long)self.text;
    long v2 = (long)[NSValue valueWithCGRect:self.frame];
    return v1 ^ v2;
}


#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.textLayout forKey:@"textLayout"];
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.attributedText forKey:@"attributedText"];
    [aCoder encodeObject:self.textColor forKey:@"textColor"];
    [aCoder encodeObject:self.textBackgroundColor forKey:@"textBackgroundColor"];
    [aCoder encodeObject:self.textBoundingStrokeColor forKey:@"textBoundingStrokeColor"];
    [aCoder encodeObject:self.font forKey:@"font"];
    [aCoder encodeFloat:self.linespacing forKey:@"linespacing"];
    [aCoder encodeInteger:self.textAlignment forKey:@"textAlignment"];
    [aCoder encodeInteger:self.vericalAlignment forKey:@"vericalAlignment"];
    [aCoder encodeInteger:self.underlineStyle forKey:@"underlineStyle"];
    [aCoder encodeObject:self.underlineColor forKey:@"underlineColor"];
    [aCoder encodeInteger:self.lineBreakMode forKey:@"lineBreakMode"];
    [aCoder encodeInteger:self.textDrawMode forKey:@"textDrawMode"];
    [aCoder encodeObject:self.strokeColor forKey:@"strokeColor"];
    [aCoder encodeFloat:self.strokeWidth forKey:@"strokeWidth"];
    [aCoder encodeCGSize:self.suggestSize forKey:@"suggestSize"];
    [aCoder encodeInteger:self.maxNumberOfLines forKey:@"maxNumberOfLines"];
    [aCoder encodeInteger:self.numberOfLines forKey:@"numberOfLines"];
    [aCoder encodeBool:self.needDebug forKey:@"needDebug"];
    [aCoder encodeBool:self.isTruncation forKey:@"isTruncation"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.textLayout = [aDecoder decodeObjectForKey:@"textLayout"];
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.attributedText = [aDecoder decodeObjectForKey:@"attributedText"];
        self.textColor = [aDecoder decodeObjectForKey:@"textColor"];
        self.textBackgroundColor = [aDecoder decodeObjectForKey:@"textBackgroundColor"];
        self.textBoundingStrokeColor = [aDecoder decodeObjectForKey:@"textBoundingStrokeColor"];
        self.font = [aDecoder decodeObjectForKey:@"font"];
        self.linespacing = [aDecoder decodeFloatForKey:@"linespacing"];
        self.textAlignment = [aDecoder decodeIntegerForKey:@"textAlignment"];
        self.vericalAlignment = [aDecoder decodeIntegerForKey:@"vericalAlignment"];
        self.underlineStyle = [aDecoder decodeIntegerForKey:@"underlineStyle"];
        self.underlineColor = [aDecoder decodeObjectForKey:@"underlineColor"];
        self.lineBreakMode = [aDecoder decodeIntegerForKey:@"lineBreakMode"];
        self.textDrawMode = [aDecoder decodeIntegerForKey:@"textDrawMode"];
        self.strokeColor = [aDecoder decodeObjectForKey:@"strokeColor"];
        self.strokeWidth = [aDecoder decodeFloatForKey:@"strokeWidth"];
        self.suggestSize = [aDecoder decodeCGSizeForKey:@"suggestSize"];
        self.maxNumberOfLines = [aDecoder decodeIntegerForKey:@"maxNumberOfLines"];
        self.numberOfLines = [aDecoder decodeIntegerForKey:@"numberOfLines"];
        self.needDebug  = [aDecoder decodeIntegerForKey:@"needDebug"];
        self.isTruncation = [aDecoder decodeIntegerForKey:@"isTruncation"];
    }
    return self;
}

#pragma mark - Init

+ (LWTextStorage *)lw_textStorageWithTextLayout:(LWTextLayout *)textLayout
                                          frame:(CGRect)frame {
    LWTextStorage* textStorage = [[LWTextStorage alloc] initWithFrame:frame];
    textStorage.textLayout = textLayout;
    return textStorage;
}

+ (LWTextStorage *)lw_textStorageWithText:(NSAttributedString *)attributedText
                                    frame:(CGRect)frame {
    LWTextStorage* textStorage = [[LWTextStorage alloc] initWithFrame:frame];
    LWTextContainer* textContainer = [LWTextContainer lw_textContainerWithSize:frame.size];
    textStorage.textLayout = [LWTextLayout lw_layoutWithContainer:textContainer
                                                             text:attributedText];
    textStorage.attributedText = [attributedText mutableCopy];
    return textStorage;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        [self setup];
        self.frame = frame;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.frame = CGRectZero;
    self.position = CGPointZero;
    self.text = nil;
    self.attributedText = nil;
    self.textColor = [UIColor blackColor];
    self.textBackgroundColor = [UIColor clearColor];
    self.font = [UIFont systemFontOfSize:14.0f];
    self.textAlignment = NSTextAlignmentLeft;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.underlineStyle = NSUnderlineStyleNone;
    self.linespacing = 1.0f;
    self.characterSpacing = 0.0f;
    self.textDrawMode = LWTextDrawModeFill;
    self.strokeColor = [UIColor blackColor];
    self.strokeWidth = 1.0f;
    self.textBoundingStrokeColor = nil;
    self.maxNumberOfLine = 0;
    self.needDebug = NO;
    self.vericalAlignment = LWTextVericalAlignmentTop;
}

#pragma mark - Methods

- (void)lw_addLinkForWholeTextStorageWithData:(id)data
                                    linkColor:(UIColor *)linkColor
                               highLightColor:(UIColor *)highLightColor {
    [self.attributedText addLinkForWholeTextWithData:data
                                           linkColor:linkColor
                                      highLightColor:highLightColor];
    [self _creatTextLayout];
}

- (void)lw_addLinkForWholeTextStorageWithData:(id)data
                               highLightColor:(UIColor *)highLightColor {
    [self.attributedText addLinkForWholeTextWithData:data
                                           linkColor:nil
                                      highLightColor:highLightColor];
    [self _creatTextLayout];
}


- (void)lw_addLinkWithData:(id)data range:(NSRange)range
                 linkColor:(UIColor *)linkColor
            highLightColor:(UIColor *)highLightColor {
    [self.attributedText addLinkWithData:data
                                   range:range
                               linkColor:linkColor
                          highLightColor:highLightColor];
    [self _creatTextLayout];
}


- (void)lw_addLongPressActionWithData:(id)data
                       highLightColor:(UIColor *)highLightColor {
    
    [self.attributedText addLongPressActionWithData:data
                                     highLightColor:highLightColor];
    [self _creatTextLayout];
}

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
    NSMutableAttributedString* attachString =
    [NSMutableAttributedString lw_textAttachmentStringWithContent:image
                                                      contentMode:contentMode
                                                           ascent:ascent
                                                          descent:descent
                                                            width:size.width];
    [self.attributedText replaceCharactersInRange:range
                             withAttributedString:attachString];
    [self _creatTextLayout];
}


- (void)lw_replaceTextWithImageURL:(NSURL *)URL
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
    NSDictionary* userInfo;
    
    if (URL) {
        userInfo = @{@"URL":URL};
    }
    
    NSMutableAttributedString* attachString =
    [NSMutableAttributedString
     lw_textAttachmentStringWithContent:[[UIImageView alloc]
                                         initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  size.width,
                                                                  size.height)]
     userInfo:userInfo
     contentMode:contentMode
     ascent:ascent
     descent:descent
     width:size.width];
    [self.attributedText replaceCharactersInRange:range
                             withAttributedString:attachString];
    [self _creatTextLayout];
}


- (void)lw_replaceTextWithView:(UIView *)view
                   contentMode:(UIViewContentMode)contentMode
                          size:(CGSize)size
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
    NSMutableAttributedString* attachString =
    [NSMutableAttributedString lw_textAttachmentStringWithContent:view
                                                      contentMode:contentMode
                                                           ascent:ascent
                                                          descent:descent
                                                            width:size.width];
    [self.attributedText replaceCharactersInRange:range withAttributedString:attachString];
    [self _creatTextLayout];
}


- (void)lw_appendTextStorage:(LWTextStorage *)aTextStorage {
    if (!aTextStorage) {
        return;
    }
    NSMutableAttributedString* attributedString = [aTextStorage attributedText];
    if (!attributedString) {
        return;
    }
    [self.attributedText appendAttributedString:attributedString];
    [self _creatTextLayout];
}

#pragma mark - Setter

- (void)setText:(NSString *)text {
    if (!text || _text == text) {
        return;
    }
    _text = [text copy];
    
    _attributedText = [[NSMutableAttributedString alloc] initWithString:_text attributes:nil];
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [_attributedText setTextColor:self.textColor range:range];
    [_attributedText setTextBackgroundColor:self.textBackgroundColor range:range];
    [_attributedText setFont:self.font range:range];
    [_attributedText setCharacterSpacing:self.characterSpacing range:range];
    [_attributedText setUnderlineStyle:self.underlineStyle underlineColor:self.underlineColor range:range];
    [_attributedText setTextAlignment:self.textAlignment range:range];
    [_attributedText setLineSpacing:self.linespacing range:range];
    [_attributedText setLineBreakMode:self.lineBreakMode range:range];
    [self _creatTextLayout];
}

- (void)setTextDrawMode:(LWTextDrawMode)textDrawMode {
    if (_textDrawMode != textDrawMode) {
        _textDrawMode = textDrawMode;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    if (self.textDrawMode == LWTextDrawModeStroke) {
        [_attributedText setStrokeColor:self.strokeColor strokeWidth:self.strokeWidth range:range];
    }
    [self _creatTextLayout];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    if (_strokeColor != strokeColor) {
        _strokeColor = strokeColor;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    if (self.textDrawMode == LWTextDrawModeStroke) {
        [_attributedText setStrokeColor:self.strokeColor strokeWidth:self.strokeWidth range:range];
    }
    [self _creatTextLayout];
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    if (_strokeWidth != strokeWidth) {
        _strokeWidth = strokeWidth;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    if (self.textDrawMode == LWTextDrawModeStroke) {
        [_attributedText setStrokeColor:self.strokeColor strokeWidth:self.strokeWidth range:range];
    }
    [self _creatTextLayout];
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        _textColor = textColor;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setTextColor:self.textColor range:range];
    [self _creatTextLayout];
}

- (void)setTextBackgroundColor:(UIColor *)textBackgroundColor {
    if (_textBackgroundColor != textBackgroundColor) {
        _textBackgroundColor = textBackgroundColor;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setTextBackgroundColor:self.textBackgroundColor range:range];
    [self _creatTextLayout];
}

- (void)setTextBoundingStrokeColor:(UIColor *)textBoundingStrokeColor {
    if (_textBoundingStrokeColor != textBoundingStrokeColor) {
        _textBoundingStrokeColor = textBoundingStrokeColor;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setTextBoundingStrokeColor:self.textBoundingStrokeColor range:range];
    [self _creatTextLayout];
}

- (void)setFont:(UIFont *)font {
    if (_font != font) {
        _font = font;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setFont:self.font range:range];
    [self _creatTextLayout];
}

- (void)setCharacterSpacing:(unichar)characterSpacing {
    if (_characterSpacing != characterSpacing) {
        _characterSpacing = characterSpacing;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setCharacterSpacing:self.characterSpacing range:range];
    [self _creatTextLayout];
}

- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle {
    if (_underlineStyle != underlineStyle) {
        _underlineStyle = underlineStyle;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setUnderlineStyle:self.underlineStyle
                            underlineColor:self.underlineColor
                                     range:range];
    [self _creatTextLayout];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setTextAlignment:self.textAlignment range:range];
    [self _creatTextLayout];
}

- (void)setLinespacing:(CGFloat)linespacing {
    if (_linespacing != linespacing) {
        _linespacing = linespacing;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setLineSpacing:self.linespacing range:range];
    [self _creatTextLayout];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_lineBreakMode != lineBreakMode) {
        _lineBreakMode = lineBreakMode;
    }
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText setLineBreakMode:self.lineBreakMode range:range];
    [self _creatTextLayout];
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
    _position = _frame.origin;
    [self _creatTextLayout];
}

- (void)setMaxNumberOfLine:(NSInteger)maxNumberOfLine {
    _maxNumberOfLines = maxNumberOfLine;
    [self _creatTextLayout];
}

- (void)setNeedDebug:(BOOL)needDebug {
    _needDebug = needDebug;
    [self _creatTextLayout];
}

- (void)setVericalAlignment:(LWTextVericalAlignment)vericalAlignment {
    _vericalAlignment = vericalAlignment;
    [self _creatTextLayout];
}

- (void)_creatTextLayout {
    if (!self.attributedText) {
        return;
    }
    LWTextContainer* textContainer = [LWTextContainer lw_textContainerWithSize:self.frame.size];
    textContainer.maxNumberOfLines = self.maxNumberOfLines;
    textContainer.vericalAlignment = self.vericalAlignment;
    self.textLayout = [LWTextLayout lw_layoutWithContainer:textContainer
                                                      text:self.attributedText];
    self.textLayout.needDebugDraw = self.needDebug;
}

#pragma mark - Getter
- (BOOL)isTruncation {
    return self.textLayout.needTruncation;
}

- (NSInteger)numberOfLines {
    return self.textLayout.numberOfLines;
}

- (CGFloat)left {
    return self.textLayout.cgPathBox.origin.x + self.position.x;
}

- (CGFloat)right {
    return  self.textLayout.cgPathBox.origin.x + self.position.x + self.width;
}

- (CGFloat)top {
    return self.textLayout.cgPathBox.origin.y + self.position.y;
}

- (CGFloat)bottom {
    return self.textLayout.cgPathBox.origin.y + self.position.y + self.height;
}

- (CGFloat)height {
    return self.textLayout.suggestSize.height;
}

- (CGFloat)width {
    return self.textLayout.suggestSize.width;
}

- (void)setCenter:(CGPoint)center {
    CGRect frame = self.frame;
    frame.origin.x = center.x - frame.size.width * 0.5f;
    frame.origin.y = center.y - frame.size.height * 0.5f;
    self.frame = frame;
}

- (CGPoint)center {
    return CGPointMake(self.textLayout.cgPathBox.origin.x  + self.position.x + self.textLayout.cgPathBox.size.width * 0.5f,
                       
                       self.textLayout.cgPathBox.origin.y + self.position.y + self.textLayout.cgPathBox.size.height * 0.5f);
}

- (CGSize)suggestSize {
    return self.textLayout.suggestSize;
}

- (NSString *)text {
    return self.attributedText.string;
}

@end
