//
//  LWTextLayout.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWTextLayout.h"

@interface LWTextLayout ()

@property (nonatomic,readwrite,strong) NSAttributedString* text;
@property (nonatomic,readwrite) CTFramesetterRef frameSetter;
@property (nonatomic,readwrite) CTFrameRef frame;
@property (nonatomic,readwrite) CGSize boundsSize;
@property (nonatomic,readwrite) CGRect boundsRect;
@property (nonatomic,readwrite) CGMutablePathRef textPath;

@end


@implementation LWTextLayout

- (LWTextLayout *)initWithText:(NSString *)text
                          font:(UIFont *)font
                 textAlignment:(NSTextAlignment)textAlignment
                     linespace:(CGFloat)linespace
                     textColor:(UIColor *)textColor
                          rect:(CGRect)rect {
    self = [super init];
    if (self) {
        NSDictionary* attributes = [self attributesWith:font
                                          textAlignment:textAlignment
                                              linespace:linespace
                                              textColor:textColor];
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:text
                                                                               attributes:attributes];
        CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
        CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(ctFrameSetter,
                                                                          CFRangeMake(0, attributedString.length),
                                                                          (__bridge CFDictionaryRef)attributes, rect.size,
                                                                          NULL);
        CGMutablePathRef textPath = CGPathCreateMutable();
        CGPathAddRect(textPath, NULL, CGRectMake(rect.origin.x, rect.origin.y, suggestSize.width, suggestSize.height));
        CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFrameSetter, CFRangeMake(0, 0), textPath, NULL);
        self.text = attributedString;
        self.frameSetter = ctFrameSetter;
        self.frame = ctFrame;
        self.textPath = textPath;
        self.boundsSize = CGSizeMake(suggestSize.width, suggestSize.height);
        self.boundsRect =  CGRectMake(rect.origin.x, rect.origin.y, suggestSize.width, suggestSize.height);
    }
    return self;
}

- (void)dealloc {
    CFRelease(self.frame);
    CFRelease(self.frameSetter);
    CFRelease(self.textPath);
}

- (void)drawTextLayoutIncontext:(CGContextRef)context {
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


@end
