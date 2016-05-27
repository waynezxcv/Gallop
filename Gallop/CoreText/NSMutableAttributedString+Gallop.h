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


#import <UIKit/UIKit.h>

@interface NSMutableAttributedString(Gallop)

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range;
- (void)setTextBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range;
- (void)setFont:(UIFont *)font range:(NSRange)range;
- (void)setCharacterSpacing:(unichar)characterSpacing range:(NSRange)range;
- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle underlineColor:(UIColor *)underlineColor range:(NSRange)range;
#pragma mark - ParagraphStyle
- (void)setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range;
- (void)setTextAlignment:(NSTextAlignment)textAlignment range:(NSRange)range;
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range;

#pragma mark - Link & Attachment
- (void)addLinkWithData:(id)data range:(NSRange)range linkColor:(UIColor *)linkColor highLightColor:(UIColor *)highLightColor;
- (void)addLinkForWholeTextWithData:(id)data linkColor:(UIColor *)linkColor highLightColor:(UIColor *)highLightColor;
+ (NSMutableAttributedString *)lw_textAttachmentStringWithContent:(id)content
                                                      contentMode:(UIViewContentMode)contentMode
                                                           ascent:(CGFloat)ascent
                                                          descent:(CGFloat)descent
                                                            width:(CGFloat)width;
+ (NSMutableAttributedString *)lw_textAttachmentStringWithContent:(id)content
                                                         userInfo:(NSDictionary *)userInfo
                                                      contentMode:(UIViewContentMode)contentMode
                                                           ascent:(CGFloat)ascent
                                                          descent:(CGFloat)descent
                                                            width:(CGFloat)width;



@end
