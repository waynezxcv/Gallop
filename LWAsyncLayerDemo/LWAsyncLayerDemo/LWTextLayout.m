//
//  LWTextLayout.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWTextLayout.h"

@interface LWTextLayout ()

@end

@implementation LWTextLayout

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        self.text = nil;
        self.attributedText = nil;
        self.textColor = [UIColor blackColor];
        self.font = [UIFont systemFontOfSize:14.0f];
        self.textAlignment = NSTextAlignmentLeft;
        self.veriticalAlignment = LWVerticalAlignmentCenter;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.boundsRect = CGRectZero;
        self.linespace = 2.0f;
        self.characterSpacing = 1.0f;
    }
    return self;
}

#pragma mark - Draw

- (void)drawInContext:(CGContextRef)context {
    @autoreleasepool {
        CGContextSaveGState(context);
        CGContextSetTextMatrix(context,CGAffineTransformIdentity);
        CGContextTranslateCTM(context, self.boundsRect.origin.x, self.boundsRect.origin.y);
        CGContextTranslateCTM(context, 0, self.boundsRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, -self.boundsRect.origin.x, -self.boundsRect.origin.y);
        CTFrameDraw(self.frame, context);
        CGContextRestoreGState(context);
    }
}

static void _drawImage(UIImage* image,CGRect rect,CGContextRef context) {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextRestoreGState(context);
}


#pragma mark - Getter

- (NSString *)text {
    return _attributedText.string;
}

#pragma mark - Setter

- (void)resetFrameRef {
    if (_frame) {
        CFRelease(_frame);
        _frame = nil;
    }
    _textHeight = 0;
}

- (void)setText:(NSString *)text {
    _attributedText = [self _createAttributedStringWithText:text];
    [self resetFrameRef];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (attributedText == nil) {
        _attributedText = [[NSMutableAttributedString alloc]init];
    }else if ([attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        _attributedText = (NSMutableAttributedString *)attributedText;
    }else {
        _attributedText = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    }
    [self resetFrameRef];
}

- (void)setTextColor:(UIColor *)textColor {
    if (textColor && _textColor != textColor){
        _textColor = textColor;
        [self _mutableAttributedString:_attributedText addAttributesWithTextColor:_textColor inRange:NSMakeRange(0, _attributedText.length)];
        [self resetFrameRef];
    }
}

- (void)setFont:(UIFont *)font {
    if (font && _font != font){
        _font = font;
        [self _mutableAttributedString:_attributedText addAttributesWithFont:_font inRange:NSMakeRange(0, _attributedText.length)];
        [self resetFrameRef];
    }
}

- (void)setCharacterSpacing:(unichar)characterSpacing {
    if (characterSpacing >= 0 && _characterSpacing != characterSpacing) {
        _characterSpacing = characterSpacing;
        [self _mutableAttributedString:_attributedText addAttributesWithCharacterSpacing:characterSpacing inRange:NSMakeRange(0, _attributedText.length)];
        [self resetFrameRef];
    }
}

- (void)setLinesSpacing:(CGFloat)linesSpacing {
    if (_linespace != linesSpacing) {
        _linespace = linesSpacing;
        [self _mutableAttributedString:_attributedText
          addAttributesWithLineSpacing:_linespace
                         textAlignment:_textAlignment
                         lineBreakMode:_lineBreakMode
                               inRange:NSMakeRange(0, _attributedText.length)];
        [self resetFrameRef];
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;
        [self _mutableAttributedString:_attributedText
          addAttributesWithLineSpacing:_linespace
                         textAlignment:_textAlignment
                         lineBreakMode:_lineBreakMode
                               inRange:NSMakeRange(0, _attributedText.length)];
        [self resetFrameRef];
    }
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_lineBreakMode != lineBreakMode) {
        _lineBreakMode = lineBreakMode;
        [self _mutableAttributedString:_attributedText
          addAttributesWithLineSpacing:_linespace
                         textAlignment:_textAlignment
                         lineBreakMode:_lineBreakMode
                               inRange:NSMakeRange(0, _attributedText.length)];
        [self resetFrameRef];
    }
}

- (void)setFrameSetter:(CTFramesetterRef)frameSetter {
    if (_frameSetter != frameSetter) {
        if (frameSetter) CFRetain(frameSetter);
        if (_frameSetter) CFRelease(_frameSetter);
        _frameSetter = frameSetter;
    }
}

- (void)setFrame:(CTFrameRef)frame {
    if (_frame != frame) {
        if (frame) CFRetain(frame);
        if (_frame) CFRelease(_frame);
        _frame = frame;
    }
}

- (void)dealloc {
    if (self.frame) {
        CFRelease(self.frame);
    }
    if (self.frameSetter) {
        CFRelease(self.frameSetter);
    }
    if (self.textPath) {
        CFRelease(self.textPath);
    }
}

#pragma mark - Attributes

/**
 *  创建属性字符串
 *
 */
- (NSMutableAttributedString *)_createAttributedStringWithText:(NSString *)text {
    if (text.length <= 0) {
        return [[NSMutableAttributedString alloc]init];
    }
    // 创建属性文本
    NSMutableAttributedString* attbutedString = [[NSMutableAttributedString alloc]initWithString:text];
    // 添加颜色属性
    [self _mutableAttributedString:attbutedString addAttributesWithTextColor:_textColor inRange:NSMakeRange(0, text.length)];
    // 添加字体属性
    [self _mutableAttributedString:attbutedString addAttributesWithFont:_font inRange:NSMakeRange(0, text.length)];
    // 添加文本段落样式
    [self _mutableAttributedString:attbutedString addAttributesWithLineSpacing:_linespace textAlignment:_textAlignment lineBreakMode:_lineBreakMode inRange:NSMakeRange(0, text.length)];
    return attbutedString;
}


/**
 * 添加段落相关属性
 *
 */
- (void)_mutableAttributedString:(NSMutableAttributedString *)attributedString
    addAttributesWithLineSpacing:(CGFloat)linespacing
                   textAlignment:(NSTextAlignment)textAlignment
                   lineBreakMode:(NSLineBreakMode)lineBreakMode
                         inRange:(NSRange)range {
    if (attributedString == nil) {
        return;
    }
    [attributedString removeAttribute:(NSString *)kCTParagraphStyleAttributeName range:range];
    //文字对齐方式
    CTTextAlignment ctTextAlignment = _coreTextAlignmentFromNSTextAlignment(textAlignment);
    //换行方式
    CTLineBreakMode ctLineBreakMode = _coreTextLineBreakModeFromNSLineBreakModel(lineBreakMode);
    //段落式样
    CTParagraphStyleSetting theSettings[] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &linespacing},
        { kCTParagraphStyleSpecifierAlignment, sizeof(ctTextAlignment), &ctTextAlignment },
        { kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&ctLineBreakMode }
    };
    CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(theSettings, sizeof(theSettings) / sizeof(theSettings[0]));
    if (paragraphRef != nil) {
        [attributedString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)paragraphRef range:range];
        CFRelease(paragraphRef);
    }
}

/**
 * 添加字体属性
 *
 */
- (void)_mutableAttributedString:(NSMutableAttributedString *)attributedString
           addAttributesWithFont:(UIFont *)font
                         inRange:(NSRange)range {
    if (attributedString == nil || font == nil) {
        return;
    }
    [attributedString removeAttribute:(NSString *)kCTFontAttributeName range:range];
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
    if (fontRef != nil) {
        [attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
        CFRelease(fontRef);
    }
}

/**
 *  添加文字颜色属性
 *
 */
- (void)_mutableAttributedString:(NSMutableAttributedString *)attributedString
      addAttributesWithTextColor:(UIColor *)textColor
                         inRange:(NSRange)range {
    if (attributedString == nil || textColor == nil) {
        return;
    }
    [attributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)textColor.CGColor range:range];
}


/**
 *  添加字间距属性
 *
 */
- (void)_mutableAttributedString:(NSMutableAttributedString *)attributedString
addAttributesWithCharacterSpacing:(unichar)characterSpacing
                         inRange:(NSRange)range {
    if (attributedString == nil) {
        return;
    }
    [attributedString removeAttribute:(NSString *)kCTKernAttributeName range:range];

    CFNumberRef charSpacingNum =  CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&characterSpacing);
    if (charSpacingNum != nil) {
        [attributedString addAttribute:(NSString *)kCTKernAttributeName value:(__bridge id)charSpacingNum range:range];
        CFRelease(charSpacingNum);
    }
}

#pragma mark - Private

/*
 kCTParagraphStyleSpecifierAlignment = 0,                 //对齐属性*
 kCTParagraphStyleSpecifierFirstLineHeadIndent = 1,       //首行缩进
 kCTParagraphStyleSpecifierHeadIndent = 2,                //段头缩进
 kCTParagraphStyleSpecifierTailIndent = 3,                //段尾缩进
 kCTParagraphStyleSpecifierTabStops = 4,                  //制表符模式
 kCTParagraphStyleSpecifierDefaultTabInterval = 5,        //默认tab间隔
 kCTParagraphStyleSpecifierLineBreakMode = 6,             //换行模式*
 kCTParagraphStyleSpecifierLineHeightMultiple = 7,        //多行高
 kCTParagraphStyleSpecifierMaximumLineHeight = 8,         //最大行高
 kCTParagraphStyleSpecifierMinimumLineHeight = 9,         //最小行高
 kCTParagraphStyleSpecifierLineSpacing = 10,              //行距*
 kCTParagraphStyleSpecifierParagraphSpacing = 11,         //段落间距  在段的未尾（Bottom）加上间隔，这个值为负数。
 kCTParagraphStyleSpecifierParagraphSpacingBefore = 12,   //段落前间距 在一个段落的前面加上间隔。TOP
 kCTParagraphStyleSpecifierBaseWritingDirection = 13,     //基本书写方向
 kCTParagraphStyleSpecifierMaximumLineSpacing = 14,       //最大行距
 kCTParagraphStyleSpecifierMinimumLineSpacing = 15,       //最小行距
 kCTParagraphStyleSpecifierLineSpacingAdjustment = 16,    //行距调整
 kCTParagraphStyleSpecifierCount = 17,        //
 */


/********************************* ParagraphStyle *********************************************/

/**
 *  将NSTextAlignment转换成CTTextAlignment
 *
 */
static CTTextAlignment _coreTextAlignmentFromNSTextAlignment(NSTextAlignment alignment) {
    switch (alignment) {
        case NSTextAlignmentLeft: return kCTTextAlignmentLeft;
        case NSTextAlignmentCenter: return kCTTextAlignmentCenter;
        case NSTextAlignmentRight: return kCTTextAlignmentRight;
        case NSTextAlignmentJustified : return kCTTextAlignmentJustified;
        case NSTextAlignmentNatural: return kCTTextAlignmentNatural;
        default: return kCTTextAlignmentLeft;
    }
}

/*
 kCTLineBreakByWordWrapping = 0,        //出现在单词边界时起作用，如果该单词不在能在一行里显示时，整体换行。此为段的默认值。
 kCTLineBreakByCharWrapping = 1,        //当一行中最后一个位置的大小不能容纳一个字符时，才进行换行。
 kCTLineBreakByClipping = 2,            //超出画布边缘部份将被截除。
 kCTLineBreakByTruncatingHead = 3,      //截除前面部份，只保留后面一行的数据。前部份以...代替。
 kCTLineBreakByTruncatingTail = 4,      //截除后面部份，只保留前面一行的数据，后部份以...代替。
 kCTLineBreakByTruncatingMiddle = 5     //在一行中显示段文字的前面和后面文字，中间文字使用...代替。
 */


/**
 *  将NSLineBreakMode转换成CTLineBreakMode
 *
 */
static CTLineBreakMode _coreTextLineBreakModeFromNSLineBreakModel(NSLineBreakMode lineBreakMode) {
    switch (lineBreakMode) {
        case NSLineBreakByWordWrapping: return kCTLineBreakByWordWrapping;
        case NSLineBreakByCharWrapping: return kCTLineBreakByCharWrapping;
        case NSLineBreakByClipping: return kCTLineBreakByClipping;
        case NSLineBreakByTruncatingHead: return kCTLineBreakByTruncatingHead;
        case NSLineBreakByTruncatingTail: return kCTLineBreakByTruncatingTail;
        case NSLineBreakByTruncatingMiddle: return kCTLineBreakByTruncatingMiddle;
    }
}

@end
