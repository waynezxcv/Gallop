//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//  LWTextLayout.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import "LWTextLayout.h"


static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat ascentCallback(void *ref){
    NSString* callback = (__bridge NSString *)(ref);
    NSData* jsonData = [callback dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    return [[dic objectForKey:@"height"] floatValue];
}

static CGFloat widthCallback(void* ref){
    NSString* callback = (__bridge NSString *)(ref);
    NSData* jsonData = [callback dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    return [[dic objectForKey:@"width"] floatValue];
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
        self.underlineStyle = NSUnderlineStyleNone;
        self.widthToFit = YES;
    }
    return self;
}

- (void)creatCTFrameRef {
    if (_attributedText == nil || self.boundsRect.size.width <= 0) {
        return ;
    }
    if (_textHeight > 0) {
        return ;
    }
    CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedText);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(ctFrameSetter,
                                                                      CFRangeMake(0, _attributedText.length),
                                                                      NULL,
                                                                      CGSizeMake(self.boundsRect.size.width, CGFLOAT_MAX),
                                                                      NULL);
    if (self.isWidthToFit) {
        self.boundsRect = CGRectMake(self.boundsRect.origin.x, self.boundsRect.origin.y, suggestSize.width, suggestSize.height);
    }
    else {
        self.boundsRect = CGRectMake(self.boundsRect.origin.x, self.boundsRect.origin.y, self.boundsRect.size.width, suggestSize.height);
    }
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
        CGContextTranslateCTM(context, - self.boundsRect.origin.x, -self.boundsRect.origin.y);
        CTFrameDraw(self.frame, context);
        CGContextRestoreGState(context);
        if (self.attachs.count == 0) {
            return;
        }
        for (NSInteger i = 0; i < self.attachs.count; i ++) {
            LWTextAttach* attach = self.attachs[i];
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, self.boundsRect.origin.x, self.boundsRect.origin.y);
            CGContextTranslateCTM(context, 0, self.boundsRect.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextTranslateCTM(context, - self.boundsRect.origin.x, -self.boundsRect.origin.y);
            CGContextDrawImage(context,attach.imagePosition,attach.image.CGImage);
            CGContextRestoreGState(context);
        }
    }
}

#pragma mark - Add Link

- (void)addLinkWithData:(id)data
                inRange:(NSRange)range
              linkColor:(UIColor *)linkColor
         highLightColor:(UIColor *)highLightColor
         UnderLineStyle:(NSUnderlineStyle)underlineStyle {
    if (_attributedText == nil || _attributedText.length == 0) {
        return;
    }
    [self _resetFrameRef];
    if (linkColor != nil) {
        [self _mutableAttributedString:_attributedText addAttributesWithTextColor:linkColor
                               inRange:range];
    }
    if (underlineStyle != NSUnderlineStyleNone) {
        [self _mutableAttributedString:_attributedText addAttributesWithUnderlineStyle:underlineStyle
                               inRange:range];
    }
    if (data != nil) {
        [self _mutableAttributedString:_attributedText addLinkAttributesNameWithValue:data inRange:range];
    }
    [self creatCTFrameRef];
}

#pragma mark - Add Image

- (void)replaceTextWithImage:(UIImage *)image
                     inRange:(NSRange)range {
    if (_attributedText == nil || _attributedText.length == 0) {
        return;
    }
    [self _resetFrameRef];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSAttributedString* placeholder = [self _placeHolderStringWithJson:[self _jsonWithImageWith:width
                                                                                    imageHeight:height]];
    [_attributedText replaceCharactersInRange:range withAttributedString:placeholder];
    [self creatCTFrameRef];
    LWTextAttach* attach = [[LWTextAttach alloc] init];
    attach.image = image;
    [self _setupImageAttachPositionWithAttach:attach];
    [self.attachs addObject:attach];
}

- (void)replaceTextWithImageURL:(NSURL *)URL inRange:(NSRange)range {

}

- (void)_setupImageAttachPositionWithAttach:(LWTextAttach *)attach {
    NSArray* lines = (NSArray *)CTFrameGetLines(_frame);
    NSUInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), lineOrigins);
    for (int i = 0; i < lineCount; i++) {
        if (attach == nil) {
            break;
        }
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray* runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        for (id runObj in runObjArray) {
            //遍历每一行中的每一个CTRun
            CTRunRef run = (__bridge CTRunRef)runObj;
            //获取CTRun的属性
            NSDictionary* runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            //获取Key为kCTRunDelegateAttributeName的属性值
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                continue;
            }
            //若kCTRunDelegateAttributeName的值不为空，获取CTRun的bounds
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            //获取CTRun在每一行中的偏移量
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y - descent;
            //获取CTRun在CTFrame中的位置
            CGPathRef pathRef = CTFrameGetPath(_frame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            CGRect delegateRect = CGRectMake(runBounds.origin.x + colRect.origin.x,
                                             runBounds.origin.y + colRect.origin.y,
                                             runBounds.size.width,
                                             runBounds.size.height);
            attach.imagePosition = delegateRect;
        }
    }
}

- (NSString *)_jsonWithImageWith:(CGFloat)width
                     imageHeight:(CGFloat)height {
    NSString* jsonString = [NSString stringWithFormat:@"{\"width\":\"%f\",\"height\":\"%f\"}",width,height];
    return jsonString;
}

- (NSAttributedString *)_placeHolderStringWithJson:(NSString *)json {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(json));
    unichar objectReplacementChar = 0xFFFC;
    NSString* content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString* space = [[NSMutableAttributedString alloc] initWithString:content];
    //为NSAttributedString设置key为kCTRunDelegateAttributeName值为delegate的属性
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, content.length),
                                   kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}


#pragma mark - Reset
- (void)_resetAttachs {
    [self.attachs removeAllObjects];
}

- (void)_resetFrameRef {
    if (_frame) {
        CFRelease(_frame);
        _frame = nil;
    }
    _textHeight = 0;
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

- (void)setText:(NSString *)text {
    _attributedText = [self _createAttributedStringWithText:text];
    [self _resetAttachs];
    [self _resetFrameRef];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (attributedText == nil) {
        _attributedText = [[NSMutableAttributedString alloc]init];
    }else if ([attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        _attributedText = (NSMutableAttributedString *)attributedText;
    }else {
        _attributedText = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    }
    [self _resetAttachs];
    [self _resetFrameRef];
}

- (void)setTextColor:(UIColor *)textColor {
    if (textColor && _textColor != textColor){
        _textColor = textColor;
        [self _mutableAttributedString:_attributedText
            addAttributesWithTextColor:_textColor
                               inRange:NSMakeRange(0, _attributedText.length)];
        [self _resetFrameRef];
    }
}

- (void)setFont:(UIFont *)font {
    if (font && _font != font){
        _font = font;
        [self _mutableAttributedString:_attributedText
                 addAttributesWithFont:_font
                               inRange:NSMakeRange(0, _attributedText.length)];
        [self _resetFrameRef];
    }
}

- (void)setCharacterSpacing:(unichar)characterSpacing {
    if (characterSpacing >= 0 && _characterSpacing != characterSpacing) {
        _characterSpacing = characterSpacing;
        [self _mutableAttributedString:_attributedText
     addAttributesWithCharacterSpacing:characterSpacing
                               inRange:NSMakeRange(0, _attributedText.length)];
        [self _resetFrameRef];
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
        [self _resetFrameRef];
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;
        self.widthToFit = NO;
        [self _mutableAttributedString:_attributedText
          addAttributesWithLineSpacing:_linespace
                         textAlignment:_textAlignment
                         lineBreakMode:_lineBreakMode
                               inRange:NSMakeRange(0, _attributedText.length)];
        [self _resetFrameRef];
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
        [self _resetFrameRef];
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
    //添加下划线式样
    [self _mutableAttributedString:attbutedString addAttributesWithUnderlineStyle:_underlineStyle
                           inRange:NSMakeRange(0, text.length)];
    return attbutedString;
}


/**
 *  添加Link属性
 *
 */

- (void)_mutableAttributedString:(NSMutableAttributedString *)attributedString
  addLinkAttributesNameWithValue:(id)value
                         inRange:(NSRange)range {

    if (attributedString == nil) {
        return;
    }
    if (value != nil) {
        [attributedString addAttribute:kLWTextLinkAttributedName
                                 value:value
                                 range:range];
    }
}

/**
 *  添加下划线式样
 *
 */
- (void)_mutableAttributedString:(NSMutableAttributedString *)attributedString
 addAttributesWithUnderlineStyle:(NSUnderlineStyle)underlineStyle
                         inRange:(NSRange)range {
    if (attributedString == nil) {
        return;
    }
    [attributedString removeAttribute:(NSString *)kCTUnderlineStyleAttributeName range:range];
    CTUnderlineStyle ctUnderlineStyle = _coreTextUnderlineStyleFromNSUnderlineStyle(underlineStyle);
    if (ctUnderlineStyle != kCTUnderlineStyleNone) {
        [attributedString addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                                 value:[NSNumber numberWithInt:(ctUnderlineStyle)]
                                 range:range];
    }
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
    [attributedString removeAttribute:(NSString *)kCTParagraphStyleAttributeName
                                range:range];
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
 kCTParagraphStyleSpecifierParagraphSpacing = 11,         //段落间距在段的未尾（Bottom）加上间隔，这个值为负数。
 kCTParagraphStyleSpecifierParagraphSpacingBefore = 12,   //段落前间距 在一个段落的前面加上间隔。TOP
 kCTParagraphStyleSpecifierBaseWritingDirection = 13,     //基本书写方向
 kCTParagraphStyleSpecifierMaximumLineSpacing = 14,       //最大行距
 kCTParagraphStyleSpecifierMinimumLineSpacing = 15,       //最小行距
 kCTParagraphStyleSpecifierLineSpacingAdjustment = 16,    //行距调整
 kCTParagraphStyleSpecifierCount = 17,
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

//NSUnderlineStyleNone = 0x00,
//NSUnderlineStyleSingle = 0x01,
//NSUnderlineStyleThick NS_ENUM_AVAILABLE(10_0, 7_0) = 0x02,
//NSUnderlineStyleDouble NS_ENUM_AVAILABLE(10_0, 7_0) = 0x09,
//NSUnderlinePatternSolid NS_ENUM_AVAILABLE(10_0, 7_0) = 0x0000,
//NSUnderlinePatternDot NS_ENUM_AVAILABLE(10_0, 7_0) = 0x0100,
//NSUnderlinePatternDash NS_ENUM_AVAILABLE(10_0, 7_0) = 0x0200,
//NSUnderlinePatternDashDot NS_ENUM_AVAILABLE(10_0, 7_0) = 0x0300,
//NSUnderlinePatternDashDotDot NS_ENUM_AVAILABLE(10_0, 7_0) = 0x0400,
//NSUnderlineByWord NS_ENUM_AVAILABLE(10_0, 7_0) = 0x8000

static CTUnderlineStyle _coreTextUnderlineStyleFromNSUnderlineStyle(NSUnderlineStyle underlineStyle) {
    switch (underlineStyle) {
        case NSUnderlineStyleNone: return kCTUnderlineStyleNone;
        case NSUnderlineStyleSingle: return kCTUnderlineStyleSingle;
        case NSUnderlineStyleThick: return kCTUnderlineStyleThick;
        default:return kCTUnderlineStyleNone;
    }
}

@end
