//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
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

#import "LWTextStorage.h"
#import "CALayer+WebCache.h"


static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat ascentCallback(void *ref){
    NSString* callback = (__bridge NSString *)(ref);
    NSData* jsonData = [callback dataUsingEncoding:NSUTF8StringEncoding];
    NSError* err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    return [[dic objectForKey:@"height"] floatValue];
}

static CGFloat widthCallback(void* ref){
    NSString* callback = (__bridge NSString *)(ref);
    NSData* jsonData = [callback dataUsingEncoding:NSUTF8StringEncoding];
    NSError* err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    return [[dic objectForKey:@"width"] floatValue];
}


@interface LWTextStorage ()

@property (nonatomic,strong) NSMutableArray* localAttachs;
@property (nonatomic,assign) NSInteger webImageCount;
@property (nonatomic,assign) CGSize suggestSize;

@end

@implementation LWTextStorage

@synthesize frame = _frame;

#pragma mark - Initialization

- (NSUInteger)hash {
    NSUInteger value = 0;
    value ^= [_attributedText hash];
    return value;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isMemberOfClass:self.class]) return NO;
    id selfValue = _attributedText;
    LWTextStorage* other = (LWTextStorage *)object;
    id modelValue = other.attributedText;
    BOOL valuesEqual = ((selfValue == nil && modelValue == nil) || [selfValue isEqual:modelValue]);
    if (!valuesEqual) return NO;
    return YES;
}

- (id)init {
    self = [super init];
    if (self) {
        self.text = nil;
        self.attributedText = nil;
        self.textColor = [UIColor blackColor];
        self.font = [UIFont systemFontOfSize:14.0f];
        self.textAlignment = NSTextAlignmentLeft;
        self.veriticalAlignment = LWVerticalAlignmentTop;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.frame = CGRectZero;
        self.linespace = 2.0f;
        self.characterSpacing = 1.0f;
        self.underlineStyle = NSUnderlineStyleNone;
        self.widthToFit = YES;
    }
    return self;
}

- (void)creatCTFrameRef {
    if (_attributedText == nil) {
        return ;
    }
    CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedText);
    if (self.isWidthToFit) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.suggestSize.width,self.suggestSize.height);
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.suggestSize.height);
    }
    CGMutablePathRef textPath = CGPathCreateMutable();
    CGPathAddRect(textPath, NULL, self.frame);
    self.CTFrame = CTFramesetterCreateFrame(ctFrameSetter, CFRangeMake(0, 0), textPath, NULL);
    CFRelease(ctFrameSetter);
    CFRelease(textPath);
}


- (CGSize)suggestSize {
    CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedText);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(ctFrameSetter,
                                                                      CFRangeMake(0, _attributedText.length),
                                                                      NULL,
                                                                      CGSizeMake(self.frame.size.width, CGFLOAT_MAX),
                                                                      NULL);
    CFRelease(ctFrameSetter);
    return suggestSize;
}



#pragma mark - Draw
- (void)drawInContext:(CGContextRef)context layer:(CALayer *)layer {
    [self _drawTextInContent:context];
    [self _drawLocalAttachsInContext:context];
    [self _drawWebAttachsInLayer:layer];
}

- (void)_drawTextInContent:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context, self.frame.origin.x, self.frame.origin.y);
    CGContextTranslateCTM(context, 0, self.frame.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, - self.frame.origin.x, -self.frame.origin.y);
    CTFrameDraw(self.CTFrame, context);
    CGContextRestoreGState(context);
}


- (void)_drawLocalAttachsInContext:(CGContextRef)context {
    if (self.localAttachs.count == 0) {
        return;
    }
    for (NSInteger i = 0; i < self.localAttachs.count; i ++) {
        @autoreleasepool {
            LWTextAttach* attach = self.localAttachs[i];
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, self.frame.origin.x, self.frame.origin.y);
            CGContextTranslateCTM(context, 0, self.frame.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextTranslateCTM(context, - self.frame.origin.x, -self.frame.origin.y);
            CGContextDrawImage(context,attach.imagePosition,attach.image.CGImage);
            CGContextRestoreGState(context);
        }
    }
}

- (void)_drawWebAttachsInLayer:(CALayer *)layer {
    if (self.webAttachs.count == 0) {
        return;
    }
    for (NSInteger i = 0; i < self.webAttachs.count; i ++) {
        @autoreleasepool {
            LWTextAttach* attach = self.webAttachs[i];
            id content = attach.content;
            if (!content) {
                return;
            }
            if ([content isKindOfClass:[CALayer class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CALayer* subLayer = (CALayer *)content;
                    subLayer.frame = attach.imagePosition;
                    [layer addSublayer:subLayer];
                    [subLayer sd_setImageWithURL:attach.URL];
                });
            }
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
    UIColor* color = [UIColor grayColor];
    if (highLightColor) {
        color = highLightColor;
    }
    [self.hightlights addObject:[self _textHightlightWithCTframe:self.CTFrame
                                                         InRange:range
                                                 backgroundColor:color
                                                  linkAttributes:data]];
}


/**
 *  为这个TextStorage添加链接
 *
 */
- (void)addLinkWithData:(id)data
         highLightColor:(UIColor *)highLightColor {
    if (!data) {
        return;
    }
    [self _mutableAttributedString:_attributedText
    addLinkAttributesNameWithValue:data
                           inRange:NSMakeRange(0, self.attributedText.length)];
    [self creatCTFrameRef];
    UIColor* color = [UIColor grayColor];
    if (highLightColor) {
        color = highLightColor;
    }
    LWTextHightlight* highlight = [[LWTextHightlight alloc] init];
    highlight.hightlightColor = color;
    highlight.linkAttributes = data;
    CGPathRef path = CTFrameGetPath(self.CTFrame);
    CGRect boundsRect = CGPathGetBoundingBox(path);
    highlight.positions = @[NSStringFromCGRect(boundsRect)];
    [self.hightlights addObject:highlight];
}

/**
 *  获取LWTextHightlight
 *
 */
- (LWTextHightlight *)_textHightlightWithCTframe:(CTFrameRef)frameRef
                                         InRange:(NSRange)selectRange
                                 backgroundColor:(UIColor *)bgColor
                                  linkAttributes:(id)linkAttributes {

    LWTextHightlight* highlight = [[LWTextHightlight alloc] init];
    highlight.hightlightColor = bgColor;
    highlight.linkAttributes = linkAttributes;

    CGPathRef path = CTFrameGetPath(self.CTFrame);
    CGRect boundsRect = CGPathGetBoundingBox(path);

    NSMutableArray* positions = [[NSMutableArray alloc] init];
    NSInteger selectionStartPosition = selectRange.location;
    NSInteger selectionEndPosition = NSMaxRange(selectRange);
    CFArrayRef lines = CTFrameGetLines(frameRef);
    if (!lines) {
        return nil;
    }
    CFIndex count = CFArrayGetCount(lines);
    CGPoint origins[count];

    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeTranslation(0, boundsRect.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);

    CTFrameGetLineOrigins(frameRef, CFRangeMake(0,0), origins);
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        //*** 在同一行 ***//
        if ([self _isPosition:selectionStartPosition inRange:range] && [self _isPosition:selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, offset2 - offset, ascent + descent);
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                           rect.origin.y + boundsRect.origin.y,
                                           rect.size.width,
                                           rect.size.height);
            [positions addObject:NSStringFromCGRect(adjustRect)];
            break;
        }
        //*** 不在在同一行 ***//
        if ([self _isPosition:selectionStartPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, width - offset, ascent + descent);
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                           rect.origin.y + boundsRect.origin.y,
                                           rect.size.width,
                                           rect.size.height);
            [positions addObject:NSStringFromCGRect(adjustRect)];
        }
        else if (selectionStartPosition < range.location && selectionEndPosition >= range.location + range.length) {
            CGFloat ascent, descent, leading, width;
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, width, ascent + descent);
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                           rect.origin.y + boundsRect.origin.y,
                                           rect.size.width,
                                           rect.size.height);
            [positions addObject:NSStringFromCGRect(adjustRect)];
        }
        else if (selectionStartPosition < range.location && [self _isPosition:selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, offset, ascent + descent);
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                           rect.origin.y + boundsRect.origin.y,
                                           rect.size.width,
                                           rect.size.height);
            [positions addObject:NSStringFromCGRect(adjustRect)];
        }
    }
    highlight.positions = positions;
    return highlight;
}


- (BOOL)_isPosition:(NSInteger)position inRange:(CFRange)range {
    return (position >= range.location && position < range.location + range.length);
}


#pragma mark - Add Image
- (NSMutableAttributedString *)replaceTextWithImage:(UIImage *)image imageSize:(CGSize)size inRange:(NSRange)range {
    if (_attributedText == nil || _attributedText.length == 0) {
        return nil;
    }
    [self _resetFrameRef];
    CGFloat width = size.width;
    CGFloat height = size.height;
    NSAttributedString* placeholder = [self _placeHolderStringWithJson:[self _jsonWithImageWith:width
                                                                                    imageHeight:height]];
    [_attributedText replaceCharactersInRange:range withAttributedString:placeholder];
    [self creatCTFrameRef];
    LWTextAttach* attach = [[LWTextAttach alloc] init];
    attach.image = image;
    attach.type = LWTextAttachLocalImage;
    [self _setLocalImageAttachPositionWithAttach:attach];
    [self.localAttachs addObject:attach];
    return _attributedText;
}

- (void)replaceTextWithImageURL:(NSURL *)URL imageSize:(CGSize)size inRange:(NSRange)range {
    if (_attributedText == nil || _attributedText.length == 0) {
        return;
    }
    [self _resetFrameRef];
    CGFloat width = size.width;
    CGFloat height = size.height;
    NSAttributedString* placeholder = [self _placeHolderStringWithJson:[self _jsonWithImageWith:width
                                                                                    imageHeight:height]];
    [_attributedText replaceCharactersInRange:range withAttributedString:placeholder];
    [self creatCTFrameRef];
    LWTextAttach* attach = [[LWTextAttach alloc] init];
    attach.content = [CALayer layer];
    attach.type = LWTextAttachWebImage;
    attach.URL = URL;
    [self _setWebImageAttachPositionWithAttach:attach
                                       ctFrame:self.CTFrame
                                         range:NSMakeRange(range.location, 1)];
    [self.webAttachs addObject:attach];
}

- (void)_setLocalImageAttachPositionWithAttach:(LWTextAttach *)attach {
    NSArray* lines = (NSArray *)CTFrameGetLines(self.CTFrame);
    NSUInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.CTFrame, CFRangeMake(0, 0), lineOrigins);
    for (int i = 0; i < lineCount; i++) {
        if (attach == nil) {
            break;
        }
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray* runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        for (id runObj in runObjArray) {
            CTRunRef run = (__bridge CTRunRef)runObj;
            NSDictionary* runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes
                                                                    valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                continue;
            }
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;

            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y - descent;

            CGPathRef pathRef = CTFrameGetPath(self.CTFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            CGRect delegateRect = CGRectMake(runBounds.origin.x + colRect.origin.x,
                                             runBounds.origin.y + colRect.origin.y,
                                             runBounds.size.width,
                                             runBounds.size.height);
            if (attach.type == LWTextAttachLocalImage) {
                attach.imagePosition = delegateRect;
                break;
            }
        }
    }
}

- (void)_setWebImageAttachPositionWithAttach:(LWTextAttach *)attach
                                     ctFrame:(CTFrameRef)frameRef
                                       range:(NSRange)selectRange {
    CGPathRef path = CTFrameGetPath(self.CTFrame);
    CGRect boundsRect = CGPathGetBoundingBox(path);

    NSInteger selectionStartPosition = selectRange.location;
    NSInteger selectionEndPosition = NSMaxRange(selectRange);
    CFArrayRef lines = CTFrameGetLines(frameRef);
    if (!lines) {
        return;
    }
    CFIndex count = CFArrayGetCount(lines);
    CGPoint origins[count];
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeTranslation(0, boundsRect.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0,0), origins);
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat ascent, descent, leading, offset, offset2;
        offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
        offset2 = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, offset2 - offset, ascent + descent);
        CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
        CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                       rect.origin.y + boundsRect.origin.y,
                                       rect.size.width,
                                       rect.size.height);
        if (attach.type == LWTextAttachWebImage) {
            attach.imagePosition = adjustRect;
            break;
        }
    }
}

- (CGRect)_getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
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
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, content.length),
                                   kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}



- (void)removeAttachFromViewAndLayer {
    if (self.webAttachs.count == 0) {
        return;
    }
    for (LWTextAttach* attach in self.webAttachs) {
        if (attach.type == LWTextAttachWebImage) {
            id content = attach.content;
            if ([content isKindOfClass:[CALayer class]]) {
                CALayer* layer = (CALayer *)content;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [layer removeFromSuperlayer];
                });
            }
            else if ([content isKindOfClass:[UIView class]]) {
                UIView* view = (UIView *)content;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [view removeFromSuperview];
                });
            }
        }
    }
}


#pragma mark - Reset
- (void)_resetAttachs {
    for (LWTextAttach* attach in self.webAttachs) {
        if (attach.type == LWTextAttachWebImage) {
            id content = attach.content;
            if ([content isKindOfClass:[CALayer class]]) {
                CALayer* layer = (CALayer *)content;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [layer removeFromSuperlayer];
                });
            }
            else if ([content isKindOfClass:[UIView class]]) {
                UIView* view = (UIView *)content;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [view removeFromSuperview];
                });
            }
        }
    }
    [self.webAttachs removeAllObjects];
    [self.localAttachs removeAllObjects];
}


- (void)_resetFrameRef {
    if (self.CTFrame) {
        CFRelease(self.CTFrame);
        self.CTFrame = nil;
    }
}

#pragma mark - Getter

- (NSMutableArray *)webAttachs {
    if (!_webAttachs) {
        _webAttachs = [[NSMutableArray alloc] init];
    }
    return _webAttachs;
}

- (NSMutableArray *)localAttachs {
    if (!_localAttachs) {
        _localAttachs = [[NSMutableArray alloc] init];
    }
    return _localAttachs;
}

- (NSString *)text {
    return _attributedText.string;
}

- (NSMutableArray *)hightlights {
    if (_hightlights) {
        return _hightlights;
    }
    _hightlights = [[NSMutableArray alloc] init];
    return _hightlights;
}

#pragma mark - Setter

- (NSInteger)webImageCount {
    return self.webAttachs.count;
}

- (void)setText:(NSString *)text {
    [self _resetAttachs];
    [self _resetFrameRef];
    _attributedText = [self _createAttributedStringWithText:text];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [self _resetAttachs];
    [self _resetFrameRef];
    if (attributedText == nil) {
        _attributedText = [[NSMutableAttributedString alloc]init];
    }else if ([attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        _attributedText = (NSMutableAttributedString *)attributedText;
    }else {
        _attributedText = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    }
    [self creatCTFrameRef];
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
    [self _resetFrameRef];
}

#pragma mark - Attributes

- (NSMutableAttributedString *)_createAttributedStringWithText:(NSString *)text {
    if (text.length <= 0) {
        return [[NSMutableAttributedString alloc]init];
    }
    NSMutableAttributedString* attbutedString = [[NSMutableAttributedString alloc]
                                                 initWithString:text];

    [self _mutableAttributedString:attbutedString
        addAttributesWithTextColor:_textColor
                           inRange:NSMakeRange(0, text.length)];

    [self _mutableAttributedString:attbutedString
             addAttributesWithFont:_font
                           inRange:NSMakeRange(0, text.length)];

    [self _mutableAttributedString:attbutedString addAttributesWithLineSpacing:_linespace
                     textAlignment:_textAlignment
                     lineBreakMode:_lineBreakMode
                           inRange:NSMakeRange(0, text.length)];

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
    CTTextAlignment ctTextAlignment = _coreTextAlignmentFromNSTextAlignment(textAlignment);
    CTLineBreakMode ctLineBreakMode = _coreTextLineBreakModeFromNSLineBreakModel(lineBreakMode);
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
 *  添加背景颜色属性
 *
 */
- (void)_mutableAttributedString:(NSMutableAttributedString *)attributedString
          addTextBackgroundColor:(UIColor *)backgroundColor
                         inRange:(NSRange)range {
    if (attributedString == nil || backgroundColor == nil) {
        return;
    }
    NSDictionary* backgroundColorAttirs = @{NSBackgroundColorAttributeName:backgroundColor};
    [attributedString addAttributes:backgroundColorAttirs range:range];
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



@implementation LWTextAttach

- (id)init {
    self = [super init];
    if (self) {
        self.type = LWTextAttachLocalImage;
        self.range = NSMakeRange(0, 0);
        self.imagePosition = CGRectZero;
        self.image = nil;
        self.URL = nil;
    }
    return self;
}

@end


@implementation LWTextHightlight

- (id)init {
    self = [super init];
    if (self) {
        const CGFloat* components = CGColorGetComponents([UIColor grayColor].CGColor);
        self.hightlightColor = [UIColor colorWithRed:components[0]/255.0f
                                               green:components[1]/255.0f
                                                blue:components[2]/255.0f
                                               alpha:0.2f];
    }
    return self;
}


@end

