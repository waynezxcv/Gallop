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
        [self _setupCTFrame];
    }
    return self;
}

#pragma mark - Getter
//
//- (NSDictionary *)attributes {
//    NSDictionary* attributes = [self _attributesWithFont:self.font
//                                           lineBreakMode:self.lineBreakMode
//                                           textAlignment:self.textAlignment
//                                               linespace:self.linespace
//                                               textColor:self.textColor];
//    _attributes = [attributes copy];
//    return _attributes;
//}
//
//- (NSAttributedString *)attributedText {
//    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:self.text attributes:self.attributes];
//    _attributedText = [attributedString copy];
//    return _attributedText;
//}
//

#pragma mark - Setter
- (void)_resetAllAttributed {
    [self _resetRectDictionary];
}

- (void)_resetRectDictionary {
    //    _drawRectDictionary = nil;
    //    _linkRectDictionary = nil;
    //    _runRectDictionary = nil;
}

- (void)resetFrameRef {
    if (_frame) {
        CFRelease(_frame);
        _frame = nil;
    }
}

- (void)setText:(NSString *)text
{
    _attString = [self createTextAttibuteStringWithText:text];
    [self resetAllAttributed];
    [self resetFrameRef];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (attributedText == nil) {
        _attString = [[NSMutableAttributedString alloc]init];
    }else if ([attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        _attString = (NSMutableAttributedString *)attributedText;
    }else {
        _attString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    }
    [self resetAllAttributed];
    [self resetFrameRef];
}

- (void)setTextColor:(UIColor *)textColor
{
    if (textColor && _textColor != textColor){
        _textColor = textColor;

        [_attString addAttributeTextColor:textColor];
        [self resetFrameRef];
    }
}

- (void)setFont:(UIFont *)font
{
    if (font && _font != font){
        _font = font;

        [_attString addAttributeFont:font];
        [self resetFrameRef];
    }
}

- (void)setCharacterSpacing:(unichar)characterSpacing
{
    if (characterSpacing >= 0 && _characterSpacing != characterSpacing) {
        _characterSpacing = characterSpacing;

        [_attString addAttributeCharacterSpacing:characterSpacing];
        [self resetFrameRef];
    }
}

- (void)setLinesSpacing:(CGFloat)linesSpacing
{
    if (_linesSpacing != linesSpacing) {
        _linesSpacing = linesSpacing;

        [_attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFrameRef];
    }
}

- (void)setTextAlignment:(CTTextAlignment)textAlignment
{
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;

        [_attString addAttributeAlignmentStyle:textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:_lineBreakMode];
        [self resetFrameRef];
    }
}

- (void)setLineBreakMode:(CTLineBreakMode)lineBreakMode
{
    if (_lineBreakMode != lineBreakMode) {
        _lineBreakMode = lineBreakMode;
        if (_lineBreakMode == kCTLineBreakByTruncatingTail)
        {
            lineBreakMode = _numberOfLines == 1 ? kCTLineBreakByCharWrapping : kCTLineBreakByWordWrapping;
        }

        [_attString addAttributeAlignmentStyle:_textAlignment lineSpaceStyle:_linesSpacing lineBreakStyle:lineBreakMode];
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


- (void)_setupCTFrame {
    CGRect rect = self.boundsRect;
    CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedText);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(ctFrameSetter,CFRangeMake(0, _attributedText.length),(__bridge CFDictionaryRef)_attributes, rect.size,NULL);
    CGMutablePathRef textPath = CGPathCreateMutable();
    CGPathAddRect(textPath, NULL, CGRectMake(rect.origin.x, rect.origin.y, suggestSize.width, suggestSize.height));
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFrameSetter, CFRangeMake(0, 0), textPath, NULL);
    self.frameSetter = ctFrameSetter;
    self.frame = ctFrame;
    self.textPath = textPath;
    self.boundsRect =  CGRectMake(rect.origin.x, rect.origin.y, suggestSize.width, suggestSize.height);
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



//
//static void YYTextDrawText(LWTextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
//    CGContextSaveGState(context); {
//
//        CGContextTranslateCTM(context, point.x, point.y);
//        CGContextTranslateCTM(context, 0, size.height);
//        CGContextScaleCTM(context, 1, -1);
//        CGContextSetShadow(context, CGSizeZero, 0);
//
//        BOOL isVertical = layout.container.verticalForm;
//        CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
//
//        NSArray *lines = layout.lines;
//        for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
//            YYTextLine *line = lines[l];
//            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
//            NSArray *lineRunRanges = line.verticalRotateRange;
//            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//            CGContextSetTextPosition(context, line.position.x + verticalOffset, size.height - line.position.y);
//            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
//            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
//                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
//                YYTextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
//            }
//            if (cancel && cancel()) break;
//        }
//
//        // Use this to draw frame for test/debug.
//        // CGContextTranslateCTM(context, verticalOffset, size.height);
//        // CTFrameDraw(layout.frame, context);
//
//    } CGContextRestoreGState(context);
//}
//
//

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


/**
 *  生成AttributesDictionary
 *
 */
- (NSMutableDictionary *)_attributesWithFont:(UIFont *)font
                                   textColor:(UIColor *)textColor
                               lineBreakMode:(NSLineBreakMode)lineBreakMode
                               textAlignment:(NSTextAlignment)textAlignment
                                   linespace:(CGFloat)linespace
                            characterSpacing:(unichar)characterSpacing {
    const CFIndex kNumberOfSettings = 6;
    //文字对齐方式
    CTTextAlignment ctTextAlignment = _coreTextAlignmentFromNSTextAlignment(textAlignment);
    //换行方式
    CTLineBreakMode ctLineBreakMode = _coreTextLineBreakModeFromNSLineBreakModel(lineBreakMode);
    //段落式样
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &linespace},
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &linespace },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &linespace },
        { kCTParagraphStyleSpecifierLineSpacing,sizeof(CGFloat),&linespace },
        { kCTParagraphStyleSpecifierAlignment, sizeof(ctTextAlignment), &ctTextAlignment },
        { kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&ctLineBreakMode }
    };
    CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName,font.pointSize,NULL);
    //字间距
    CFNumberRef charSpacing =  CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&characterSpacing);
    //生成属性字典
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)paragraphRef;
    dict[(id)kCTKernAttributeName] = (__bridge id)charSpacing;
    CFRelease(paragraphRef);
    CFRelease(fontRef);
    return dict;
}

- (NSMutableAttributedString *)_attributedStringWithText:(NSString *)text {
    if (text.length <= 0 || text == nil) {
        return [[NSMutableAttributedString alloc] init];
    }
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:text attributes:self.at]];

}



//NSArray* lines = (NSArray *)CTFrameGetLines(ctFrame);
//NSUInteger lineCount = [lines count];
//CGPoint lineOrigins[lineCount];
//CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
//int imgIndex = 0;
//ImageContainer* imageData = self.container.imageArray[0];
//for (int i = 0; i < lineCount; i++) {
//    if (imageData == nil) {
//        break;
//    }
//
//
//    CTLineRef line = (__bridge CTLineRef)lines[i];
//    NSArray* runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
//    for (id runObj in runObjArray) {
//        //遍历每一行中的每一个CTRun
//        CTRunRef run = (__bridge CTRunRef)runObj;
//        //获取CTRun的属性
//        NSDictionary* runAttributes = (NSDictionary *)CTRunGetAttributes(run);
//        //获取Key为kCTRunDelegateAttributeName的属性值
//        CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
//
//        if (delegate == nil) {
//            continue;
//        }
//        //若kCTRunDelegateAttributeName的值不为空，获取CTRun的bounds
//        CGRect runBounds;
//        CGFloat ascent;
//        CGFloat descent;
//
//        runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
//        runBounds.size.height = ascent + descent;
//
//        //获取CTRun在每一行中的偏移量
//        CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
//        runBounds.origin.x = lineOrigins[i].x + xOffset;
//        runBounds.origin.y = lineOrigins[i].y;
//        runBounds.origin.y -= descent;
//
//        //获取CTRun在CTFrame中的位置
//        CGPathRef pathRef = CTFrameGetPath(ctFrame);
//        CGRect colRect = CGPathGetBoundingBox(pathRef);
//        CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x , colRect.origin.y);
//        imageData.imageFrame = delegateBounds;
//
//        //根据图片大小调整位置
//        if (imageData.imageFrame.size.width < rect.size.width) {
//            CGRect adjustRect = CGRectMake((rect.size.width - imageData.imageFrame.size.width)/2 + imageData.imageFrame.origin.x, imageData.imageFrame.origin.y, imageData.imageFrame.size.width, imageData.imageFrame.size.height);
//            imageData.imageFrame = adjustRect;
//        }
//        if (imgIndex == self.container.imageArray.count) {
//            imageData = nil;
//            break;
//        } else {
//            imageData = self.container.imageArray[imgIndex];
//        }
//        imgIndex++;
//    }
//}
//for (ImageContainer* imageData in self.container.imageArray) {
//    UIImage* image = [UIImage imageNamed:imageData.imageName];
//    CGContextDrawImage(context, imageData.imageFrame, image.CGImage);
//}

@end
