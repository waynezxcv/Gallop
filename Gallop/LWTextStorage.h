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


#import "LWStorage.h"
#import "LWTextLayout.h"
#import "LWAsyncDisplayLayer.h"


/***  附件的对齐方式  ***/
typedef NS_ENUM(NSUInteger, LWTextAttachAlignment) {
    LWTextAttachAlignmentCenter,//attachment居中显示
    LWTextAttachAlignmentTop,//attachment的底部与baseline对齐
    LWTextAttachAlignmentBottom,//attachment的顶部与baseline对齐
};

/*** Text绘制方式  ***/
typedef NS_ENUM(NSUInteger, LWTextDrawMode) {
    LWTextDrawModeFill,//填充方式绘制
    LWTextDrawModeStroke,//描边方式绘制
};

/**
 *  文本绘制的数据模型
 */
@interface LWTextStorage : LWStorage<NSCoding>

@property (nonatomic,strong,readonly) LWTextLayout* textLayout;//文本布局模型
@property (nonatomic,copy) NSString* text;//文本
@property (nonatomic,strong) NSMutableAttributedString* attributedText;//属性文本
@property (nonatomic,strong) UIColor* textColor;//文本颜色
@property (nonatomic,strong) UIColor* textBackgroundColor;//文本的背景颜色
@property (nonatomic,strong) UIColor* textBoundingStrokeColor;//文本外边框描边
@property (nonatomic,strong) UIFont* font;//字体
@property (nonatomic,assign) CGFloat linespacing;//行间距
@property (nonatomic,assign) unichar characterSpacing;//字间距
@property (nonatomic,assign) NSTextAlignment textAlignment;//水平对齐方式，默认是NSTextAlignmentLeft
@property (nonatomic,assign) LWTextVericalAlignment vericalAlignment;//垂直对齐方式，默认是TOP
@property (nonatomic,assign) NSUnderlineStyle underlineStyle;//下划线样式
@property (nonatomic,strong) UIColor* underlineColor;//下划线颜色
@property (nonatomic,assign) NSLineBreakMode lineBreakMode;//换行模式
@property (nonatomic,assign) LWTextDrawMode textDrawMode;//绘制模式
@property (nonatomic,strong) UIColor* strokeColor;//描边颜色
@property (nonatomic,assign) CGFloat strokeWidth;//描边宽度
@property (nonatomic,assign,readonly) CGSize suggestSize;//建议的绘制大小
@property (nonatomic,assign) NSInteger maxNumberOfLines;//最大行数限制
@property (nonatomic,assign,readonly) NSInteger numberOfLines;//文本的实际行数
@property (nonatomic,assign) BOOL needDebug;//是否开启调试模式
@property (nonatomic,assign,readonly) BOOL isTruncation;//是否折叠



/**
 *  构造方法
 *
 *  @param frame 一个CGRect对象，包含位置信息
 *
 *  @return 一个 LWTextStorage对象
 */
- (id)initWithFrame:(CGRect)frame;

/**
 *  构造方法
 *
 *  @param attributedText 一个属性字符创
 *  @param frame          一个CGRect对象，包含位置信息
 *
 *  @return 一个 LWTextStorage对象
 */
+ (LWTextStorage *)lw_textStorageWithText:(NSAttributedString *)attributedText frame:(CGRect)frame;

/**
 *  构造方法
 *
 *  @param textLayout 一个LWTextLayout对象
 *  @param frame      一个CGRect对象，包含位置信息
 *
 *  @return 一个 LWTextStorage对象
 */
+ (LWTextStorage *)lw_textStorageWithTextLayout:(LWTextLayout *)textLayout frame:(CGRect)frame;


/**
 *  为整个文本添加点击事件
 *  如果两个点击事件重叠，会优先响应使用“- (void)lw_addLinkWithData:(id)data
                                                        range:(NSRange)range
                                                    linkColor:(UIColor *)linkColor
 *                                             highLightColor:(UIColor *)highLightColor;”
 *  这个方法添加的指定位置链接。
 *
 *  @param data           为点击事件附带的用户信息
 *  @param linkColor      链接的颜色
 *  @param highLightColor 点击连接时的高亮颜色
 */
- (void)lw_addLinkForWholeTextStorageWithData:(id)data
                                    linkColor:(UIColor *)linkColor
                               highLightColor:(UIColor *)highLightColor
__deprecated_msg("Please use 'lw_addLinkForWholeTextStorageWithData:highLightColor:' instead");

/**
 *  为整个文本添加点击事件
 *  如果两个点击事件重叠，会优先响应使用“- (void)lw_addLinkWithData:(id)data
                                                    range:(NSRange)range
                                                    linkColor:(UIColor *)linkColor
 *                                             highLightColor:(UIColor *)highLightColor;”
 *  这个方法添加的指定位置链接。
 *
 *  @param data           为点击事件附带的用户信息
 *  @param highLightColor 点击连接时的高亮颜色
 */
- (void)lw_addLinkForWholeTextStorageWithData:(id)data
                               highLightColor:(UIColor *)highLightColor;



/**
 *  为指定位置的文本添加点击事件
 *
 *  @param data           为点击事件附带的用户信息
 *  @param range          需要添加链接的文本在LWTextStorage对象的text中所处的位置，一个NSRange型的结构体对象
 *  @param linkColor      链接的颜色
 *  @param highLightColor 点击连接时的高亮颜色
 */
- (void)lw_addLinkWithData:(id)data
                     range:(NSRange)range
                 linkColor:(UIColor *)linkColor
            highLightColor:(UIColor *)highLightColor;


/**
 *  为整个文本添加长按事件
 *
 *  @param data           为点击事件附带的用户信息
 *  @param highLightColor 点击连接时的高亮颜色
 */
- (void)lw_addLongPressActionWithData:(id)data
                       highLightColor:(UIColor *)highLightColor;


/**
 *  用本地图片替换掉指定位置的文字
 *
 *  @param image           一个UIImage对象
 *  @param contentMode     图片对象的contentMode
 *  @param size            图像的大小
 *  @param attachAlignment 对齐方式
 *  @param range           需要被替换的文本所处的位置
 */
- (void)lw_replaceTextWithImage:(UIImage *)image
                    contentMode:(UIViewContentMode)contentMode
                      imageSize:(CGSize)size
                      alignment:(LWTextAttachAlignment)attachAlignment
                          range:(NSRange)range;

/**
 *  用网络图片替换掉指定位置的文字
 *
 *  @param URL             一个NSURL对象，这个图片的URL
 *  @param contentMode     图片对象的contentMode
 *  @param size            图片的大小
 *  @param attachAlignment 对齐方式
 *  @param range           需要被替换的文本所处的位置
 */
- (void)lw_replaceTextWithImageURL:(NSURL *)URL
                       contentMode:(UIViewContentMode)contentMode
                         imageSize:(CGSize)size
                         alignment:(LWTextAttachAlignment)attachAlignment
                             range:(NSRange)range;



/**
 *  用UIView及其子类对象替换掉指定位置的文字
 *
 *  @param view            一个UIView对象
 *  @param contentMode     UIView对象的contentMode
 *  @param size            UIView对象的大小
 *  @param attachAlignment UIView对象的对齐方式
 *  @param range           需要被替换的文本所处的位置
 */
- (void)lw_replaceTextWithView:(UIView *)view
                   contentMode:(UIViewContentMode)contentMode
                          size:(CGSize)size
                     alignment:(LWTextAttachAlignment)attachAlignment
                         range:(NSRange)range;

/**
 *  在这个LWTextStorage对象的尾部拼接一个LWTextStorage对象
 *
 *  @param aTextStorage 一个LWTextStorage对象
 */
- (void)lw_appendTextStorage:(LWTextStorage *)aTextStorage;

@end
