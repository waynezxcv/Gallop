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
#import "LWTextRunDelegate.h"

@implementation NSMutableAttributedString(Gallop)


#pragma mark -
- (void)setTextColor:(UIColor *)textColor range:(NSRange)range {
    [self setAttribute:NSForegroundColorAttributeName value:textColor range:range];
}

- (void)setTextBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range {
    LWTextBackgroundColor* textBackground = [[LWTextBackgroundColor alloc] init];
    textBackground.backgroundColor = backgroundColor;
    textBackground.range = range;
    [self setAttribute:LWTextBackgroundColorAttributedName value:textBackground range:range];
}

- (void)setFont:(UIFont *)font range:(NSRange)range {
    [self setAttribute:NSFontAttributeName value:font range:range];
}

- (void)setCharacterSpacing:(unichar)characterSpacing range:(NSRange)range {
    CFNumberRef charSpacingNum =  CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&characterSpacing);
    if (charSpacingNum != nil) {
        [self setAttribute:(NSString *)kCTKernAttributeName value:(__bridge id)charSpacingNum range:range];
        CFRelease(charSpacingNum);
    }
}

- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle underlineColor:(UIColor *)underlineColor range:(NSRange)range {
    [self setAttribute:NSUnderlineColorAttributeName value:underlineColor range:range];
    [self setAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:(underlineStyle)] range:range];
}

#pragma mark - ParagraphStyle
- (void)setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock: ^(NSParagraphStyle* value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle* style = value.mutableCopy;
                          [style setLineSpacing:lineSpacing];
                          [self setParagraphStyle:style range:subRange];
                      }
                      else {
                          NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
                          [style setLineSpacing:lineSpacing];
                          [self setParagraphStyle:style range:subRange];
                      }
                  }];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment range:(NSRange)range {
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock: ^(NSParagraphStyle* value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle* style = value.mutableCopy;
                          [style setAlignment:textAlignment];
                          [self setParagraphStyle:style range:subRange];
                      }
                      else {
                          NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
                          [style setAlignment:textAlignment];
                          [self setParagraphStyle:style range:subRange];
                      }
                  }];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
    [self enumerateAttribute:NSParagraphStyleAttributeName
                     inRange:range
                     options:kNilOptions
                  usingBlock: ^(NSParagraphStyle* value, NSRange subRange, BOOL *stop) {
                      if (value) {
                          NSMutableParagraphStyle* style = value.mutableCopy;
                          [style setLineBreakMode:lineBreakMode];
                          [self setParagraphStyle:style range:subRange];
                      }
                      else {
                          NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
                          [style setLineBreakMode:lineBreakMode];
                          [self setParagraphStyle:style range:subRange];
                      }
                  }];
}

- (void)setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    [self setAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

#pragma mark - Link & Attachment

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

+ (NSMutableAttributedString *)lw_textAttachmentStringWithContent:(id)content
                                                         userInfo:(NSDictionary *)userInfo
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
    attachment.userInfo = userInfo;
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

#pragma mark -

- (void)setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]){
        return;
    }
    if (value && ![NSNull isEqual:value]) {
        [self addAttribute:name value:value range:range];
    }else {
        [self removeAttribute:name range:range];
    }
}

- (void)removeAttributesInRange:(NSRange)range {
    [self setAttributes:nil range:range];
}

@end
