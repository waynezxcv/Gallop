//
//  AsyncDisplayHelper.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/21.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "AsyncDisplayHelper.h"
#import <CoreText/CoreText.h>

@implementation AsyncDisplayHelper

#pragma mark - DrawHelper

+ (AsyncDisplayHelper *)sharedDisplayHelper {
    static AsyncDisplayHelper* helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[AsyncDisplayHelper alloc] init];
    });
    return helper;
}

- (void)draText:(NSString *)text
         inRect:(CGRect)rect
           font:(UIFont *)font
  textAlignment:(NSTextAlignment)textAlignmet
      lineSpace:(CGFloat)lineSpace
      textColor:(UIColor *)textColor
        context:(CGContextRef)context {
    [self drawText:text
            inRect:rect
        attributes:[self attributesWith:font
                          textAlignment:textAlignmet
                              linespace:lineSpace
                              textColor:textColor]
           context:context];
}

- (void)drawText:(NSString *)text
          inRect:(CGRect)rect
      attributes:(NSDictionary *)attributesDict
         context:(CGContextRef)context {
    if ([text isEqual:[NSNull null]]) {
        return;
    }
    if (text == nil ) {
        return;
    }
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:text attributes:attributesDict];
    CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGMutablePathRef textPath = CGPathCreateMutable();
    CGPathAddRect(textPath, NULL, rect);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFrameSetter, CFRangeMake(0, 0), textPath, NULL);
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CTFrameDraw(ctFrame, context);
    CGContextRestoreGState(context);

    CFRelease(ctFrameSetter);
    CFRelease(ctFrame);
    CFRelease(textPath);
}

- (NSMutableDictionary *)attributesWith:(UIFont *)font
                          textAlignment:(NSTextAlignment)textAlignment
                              linespace:(CGFloat)linespace
                              textColor:(UIColor *)textColor {
    const CFIndex kNumberOfSettings = 5;
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
    CTTextAlignment alignment = [self coreTextAlignmentFromUITextAlignment:textAlignment];
    CTParagraphStyleSetting theSettings[5] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &linespace},
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &linespace },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &linespace },
        { kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment },
        { kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode }
    };
    CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName,font.pointSize,NULL);

    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)paragraphRef;
    CFRelease(paragraphRef);
    CFRelease(fontRef);
    return dict;
}

- (CTTextAlignment)coreTextAlignmentFromUITextAlignment:(NSTextAlignment)alignment {
    switch (alignment) {
        case NSTextAlignmentLeft: return kCTTextAlignmentLeft;
        case NSTextAlignmentCenter: return kCTTextAlignmentCenter;
        case NSTextAlignmentRight: return kCTTextAlignmentRight;
        default: return kCTTextAlignmentNatural;
    }
}

- (void)drawImage:(UIImage *)image rect:(CGRect)rect context:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextRestoreGState(context);
}

@end
