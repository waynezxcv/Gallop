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


/**
 *  Gallop对NSMutableAttributedString的扩展
 */

@interface NSMutableAttributedString(Gallop)


/**
 *  设置文本颜色
 *
 *  @param textColor 文本颜色
 *  @param range     范围
 */
- (void)setTextColor:(UIColor *)textColor range:(NSRange)range;

/**
 *  设置文本背景颜色
 *
 *  @param backgroundColor 背景颜色
 *  @param range           范围
 */
- (void)setTextBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range;


/**
 *  设置文本边框描边颜色
 *
 *  @param boundingStrokeColor 文本边框描边颜色
 *  @param range               范围
 */
- (void)setTextBoundingStrokeColor:(UIColor *)boundingStrokeColor range:(NSRange)range;

/**
 *  设置文本字体
 *
 *  @param font  字体
 *  @param range 范围
 */
- (void)setFont:(UIFont *)font range:(NSRange)range;

/**
 *  设置字间距
 *
 *  @param characterSpacing 字间距
 *  @param range            范围
 */
- (void)setCharacterSpacing:(unichar)characterSpacing range:(NSRange)range;

/**
 *  设置下划线样式和颜色
 *
 *  @param underlineStyle 下划线样式
 *  @param underlineColor 下划线颜色
 *  @param range          范围
 */
- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle
           underlineColor:(UIColor *)underlineColor
                    range:(NSRange)range;

/**
 *  设置描边
 *
 *  @param strokeColor 描边颜色
 *  @param strokeWidth 描边宽度
 *  @param range       范围
 */
- (void)setStrokeColor:(UIColor *)strokeColor strokeWidth:(CGFloat)strokeWidth range:(NSRange)range;


#pragma mark - ParagraphStyle

/**
 *  设置行间距
 *
 *  @param lineSpacing 行间距
 *  @param range       范围
 */
- (void)setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range;

/**
 *  设置文本水平对齐方式
 *
 *  @param textAlignment 文本对齐方式
 *  @param range         范围
 */
- (void)setTextAlignment:(NSTextAlignment)textAlignment range:(NSRange)range;

/**
 *  设置文本换行方式
 *
 *  @param lineBreakMode 换行方式
 *  @param range         范围
 */
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range;



#pragma mark - Link & Attachment
/**
 *  添加一个点击链接事件
 *
 *  @param data           链接包含的数据
 *  @param range          范围
 *  @param linkColor      链接颜色
 *  @param highLightColor 链接点击时的高亮颜色
 */
- (void)addLinkWithData:(id)data
                   range:(NSRange)range
              linkColor:(UIColor *)linkColor
         highLightColor:(UIColor *)highLightColor;

/**
 *  为整个文本添加一个点击链接事件
 *
 *  @param data           链接包含的数据
 *  @param linkColor      链接颜色
 *  @param highLightColor 链接点击时的高亮颜色
 */
- (void)addLinkForWholeTextWithData:(id)data
                          linkColor:(UIColor *)linkColor
                     highLightColor:(UIColor *)highLightColor;


/**
 *  为整个文本添加一个长按事件
 *
 *  @param data           链接包含的数据
 *  @param highLightColor 链接点击时的高亮颜色
 */
- (void)addLongPressActionWithData:(id)data
                    highLightColor:(UIColor *)highLightColor;

/**
 *
 *
 *  @param content     把一个文本附件转换成属性字符串
 *  @param contentMode 附件的内容模式
 *  @param ascent      上间距
 *  @param descent     下间距
 *  @param width       宽度
 *
 *  @return 属性字符串
 */
+ (NSMutableAttributedString *)lw_textAttachmentStringWithContent:(id)content
                                                      contentMode:(UIViewContentMode)contentMode
                                                           ascent:(CGFloat)ascent
                                                          descent:(CGFloat)descent
                                                            width:(CGFloat)width;


/**
 *
 *
 *  @param content     把一个文本附件转换成属性字符串
 *  @param userInfo    一些附加信息
 *  @param contentMode 附件的内容模式
 *  @param ascent      上间距
 *  @param descent     下间距
 *  @param width       宽度
 *
 *  @return 属性字符串
 */
+ (NSMutableAttributedString *)lw_textAttachmentStringWithContent:(id)content
                                                         userInfo:(NSDictionary *)userInfo
                                                      contentMode:(UIViewContentMode)contentMode
                                                           ascent:(CGFloat)ascent
                                                          descent:(CGFloat)descent
                                                            width:(CGFloat)width;


@end
