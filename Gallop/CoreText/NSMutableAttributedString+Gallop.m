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


#import "NSMutableAttributedString+Gallop.h"
#import "LWTextAttachment.h"
#import "LWTextHighlight.h"
#import "LWTextRunDelegate.h"

@implementation NSMutableAttributedString(Gallop)


- (void)setTextColor:(UIColor *)textColor range:(NSRange)range {
    [self setAttribute:NSFontAttributeName value:textColor range:range];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range {
    [self setAttribute:NSBackgroundColorAttributeName value:backgroundColor range:range];
}

- (void)setFont:(UIFont *)font range:(NSRange)range {
    [self setAttribute:NSFontAttributeName value:font range:range];
}

//- (void)setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
//    [self setAttribute:NSFontAttributeName value:font range:range];
//}
//
//- (void)setCharacterSpacing:(unichar)characterSpacing range:(NSRange)range {
//    [self setAttribute:NSFontAttributeName value:font range:range];
//}
//
//- (void)setTextAlignment:(NSTextAlignment)textAlignment range:(NSRange)range {
//    [self setAttribute:NSFontAttributeName value:font range:range];
//}
//
//- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle range:(NSRange)range {
//    [self setAttribute:NSFontAttributeName value:font range:range];
//}
//
//- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
//    [self setAttribute:NSFontAttributeName value:font range:range];
//}

- (void)addLinkWithData:(id)data range:(NSRange)range linkColor:(UIColor *)linkColor highLightColor:(UIColor *)highLightColor {
    LWTextHighlight* highlight = [[LWTextHighlight alloc] init];
    highlight.hightlightColor = highLightColor;
    highlight.linkColor = linkColor;
    highlight.content = data;
    highlight.range = NSMakeRange(range.location, range.length);
    
    [self setAttribute:LWTextLinkAttributedName value:highlight range:range];
    [self setAttribute:NSForegroundColorAttributeName value:linkColor range:range];
    
}

+ (NSMutableAttributedString *)lw_textAttachmentStringWithContent:(id)content
                                                      contentMode:(UIViewContentMode)contentMode
                                                           ascent:(CGFloat)ascent
                                                          descent:(CGFloat)descent
                                                            width:(CGFloat)width {
    unichar objectReplacementChar = 0xFFFC;
    NSString* contentString = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString* space = [[NSMutableAttributedString alloc] initWithString:contentString];
    
    LWTextAttachment* attachment = [[LWTextAttachment alloc] init];
    attachment.content = content;
    attachment.contentMode = contentMode;
    [space addAttribute:LWTextAttachmentAttributeName value:attachment range:NSMakeRange(0, space.length)];
    
    LWTextRunDelegate* delegate = [[LWTextRunDelegate alloc] init];
    delegate.width = width;
    delegate.ascent = ascent;
    delegate.descent = descent;
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, space.length),
                                   kCTRunDelegateAttributeName, delegateRef);
    if (delegate) {
        CFRelease(delegateRef);
    }
    return space;
}

- (void)setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]) return;
    if (value && ![NSNull isEqual:value]) [self addAttribute:name value:value range:range];
    else [self removeAttribute:name range:range];
}

- (void)removeAttributesInRange:(NSRange)range {
    [self setAttributes:nil range:range];
}


#define ParagraphStyleSet(_attr_) \
[self enumerateAttribute:NSParagraphStyleAttributeName \
inRange:range \
options:kNilOptions \
usingBlock: ^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) { \
NSMutableParagraphStyle *style = nil; \
if (value) { \
if (CFGetTypeID((__bridge CFTypeRef)(value)) == CTParagraphStyleGetTypeID()) { \
value = [NSParagraphStyle styleWithCTStyle:(__bridge CTParagraphStyleRef)(value)]; \
} \
if (value. _attr_ == _attr_) return; \
if ([value isKindOfClass:[NSMutableParagraphStyle class]]) { \
style = (id)value; \
} else { \
style = value.mutableCopy; \
} \
} else { \
if ([NSParagraphStyle defaultParagraphStyle]. _attr_ == _attr_) return; \
style = [NSParagraphStyle defaultParagraphStyle].mutableCopy; \
} \
style. _attr_ = _attr_; \
[self setParagraphStyle:style range:subRange]; \
}];

@end
