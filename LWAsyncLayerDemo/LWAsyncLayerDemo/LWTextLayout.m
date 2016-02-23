//
//  LWTextLayout.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWTextLayout.h"

static inline CGSize CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(CTFramesetterRef framesetter, NSAttributedString *attributedString, CGSize size, NSUInteger numberOfLines) {
    CFRange rangeToSize = CFRangeMake(0, (CFIndex)[attributedString length]);
    CGSize constraints = CGSizeMake(size.width, MAXFLOAT);
    if (numberOfLines > 0) {
        // If the line count of the label more than 1, limit the range to size to the number of lines that have been set
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, MAXFLOAT));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);

        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex)numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);

            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frame);
        CFRelease(path);
    }
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, NULL, constraints, NULL);
    return CGSizeMake(ceil(suggestedSize.width), ceil(suggestedSize.height));
}


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

/**
 *  创建CTFrameRef
 *
 */
- (void)creatCTFrameRef {
    if (_attributedText == nil || self.boundsRect.size.width <= 0) {
        return ;
    }
    if (_textHeight > 0) {
        return ;
    }
    CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedText);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(ctFrameSetter, CFRangeMake(0, _attributedText.length),NULL, CGSizeMake(self.boundsRect.size.width, CGFLOAT_MAX), NULL);
    self.boundsRect = CGRectMake(self.boundsRect.origin.x, self.boundsRect.origin.y, suggestSize.width, suggestSize.height);
    _textHeight = suggestSize.height;
    CGMutablePathRef textPath = CGPathCreateMutable();
    CGPathAddRect(textPath, NULL, self.boundsRect);
    _frame = CTFramesetterCreateFrame(ctFrameSetter, CFRangeMake(0, 0), textPath, NULL);
    CFRelease(ctFrameSetter);
    CFRelease(textPath);
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


#pragma mark - Link

- (void)addLinkWithData:(id)data inRange:(NSRange)range linkColor:(UIColor *)linkColor {
    if (_attributedText == nil || _attributedText.length == 0) {
        return;
    }
    [self resetFrameRef];
    [self _mutableAttributedString:_attributedText addAttributesWithTextColor:linkColor inRange:range];
    [self creatCTFrameRef];
    CFArrayRef lines = CTFrameGetLines(_frame);
    CFIndex numbersOfLines = CFArrayGetCount(lines);
    if (!lines || numbersOfLines == 0) {
        return;
    }
    CGPoint origins[numbersOfLines];
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), origins);
    for (NSInteger i = 0; i < numbersOfLines; i ++) {
        CGPoint lineOrigin = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary* attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
            if (CGColorEqualToColor((__bridge CGColorRef)([attributes valueForKey:@"CTForegroundColor"]),linkColor.CGColor)) {
                CFRange range = CTRunGetStringRange(run);
                CGRect runRect;
                runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
                float offset = CTLineGetOffsetForStringIndex(line, range.location, NULL);
                float height = runAscent;
                runRect=CGRectMake(lineOrigin.x + offset, (self.boundsRect.size.height) - lineOrigin.y - height + runDescent/2, runRect.size.width, height);
                NSRange nRange = NSMakeRange(range.location, range.length);

                LWTextAttach* attach = [[LWTextAttach alloc] init];
                attach.position = runRect;
                attach.data = data;
                [self.attachs addObject:attach];
            }
        }
    }
}



#pragma mark - Getter

- (NSMutableArray *)attachs {
    if (!_attachs) {
        _attachs = [[NSMutableArray alloc] init];
    }
    return _attachs;
}

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
    [_attachs removeAllObjects];
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
        [self _mutableAttributedString:_attributedText
            addAttributesWithTextColor:_textColor
                               inRange:NSMakeRange(0, _attributedText.length)];
        [self resetFrameRef];
    }
}

- (void)setFont:(UIFont *)font {
    if (font && _font != font){
        _font = font;
        [self _mutableAttributedString:_attributedText
                 addAttributesWithFont:_font
                               inRange:NSMakeRange(0, _attributedText.length)];
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

- (void)setLinespace:(CGFloat)linespace {
    if (_linespace != linespace) {
        _linespace = linespace;
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

- (void)dealloc {
    if (self.frame) {
        CFRelease(self.frame);
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
    [self _mutableAttributedString:attbutedString
        addAttributesWithTextColor:_textColor
                           inRange:NSMakeRange(0, text.length)];
    // 添加字体属性
    [self _mutableAttributedString:attbutedString
             addAttributesWithFont:_font
                           inRange:NSMakeRange(0, text.length)];
    // 添加文本段落样式
    [self _mutableAttributedString:attbutedString addAttributesWithLineSpacing:_linespace
                     textAlignment:_textAlignment
                     lineBreakMode:_lineBreakMode
                           inRange:NSMakeRange(0, text.length)];
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
