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


#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "LWTextContainer.h"
#import "LWTextAttachment.h"
#import "GallopDefine.h"



@class LWTextLine;

/**
 *  文本布局模型，对CoreText的封装
 */
@interface LWTextLayout : NSObject <NSCoding>

@property (nonatomic,strong,readonly) LWTextContainer* container;//文本容器
@property (nonatomic,strong,readonly) NSAttributedString* text;//文本
@property (nonatomic,assign,readonly) CTFrameRef ctFrame;//Coretext中的CTFrameRef对象
@property (nonatomic,assign,readonly) CTFramesetterRef ctFrameSetter;///Coretext中的CTFramesetterRef对象
@property (nonatomic,assign,readonly) NSInteger numberOfLines;//实际行数
@property (nonatomic,assign) NSInteger maxNumberOfLines;//行数限制，如果是0，则不限制行数，默认是0
@property (nonatomic,assign,readonly) CGPathRef cgPath;//文本绘制的路径
@property (nonatomic,assign,readonly) CGRect cgPathBox;//文本容器的边框
@property (nonatomic,assign,readonly) CGSize suggestSize;//建议的绘制大小
@property (nonatomic,assign,readonly) CGRect textBoundingRect;//文本边框
@property (nonatomic,assign,readonly) CGSize textBoundingSize;//文本边框的大小
@property (nonatomic,strong,readonly) NSArray<LWTextLine *>* linesArray;//包含LWTextLine的数组
@property (nonatomic,strong,readonly) NSArray<LWTextAttachment *>* attachments;//包含文本附件的数组
@property (nonatomic,strong,readonly) NSArray<NSValue *>* attachmentRanges;//包含文本附件在文本中位置信息的数组
@property (nonatomic,strong,readonly) NSArray<NSValue *>* attachmentRects;//包含文本附件在LWAsyncDisplayView上位置CGRect信息的数组
@property (nonatomic,strong,readonly) NSSet<id>* attachmentContentsSet;//附件内容的集合
@property (nonatomic,strong,readonly) NSArray<LWTextHighlight *>* textHighlights;//一个包含文本链接的信息的数组
@property (nonatomic,strong,readonly) NSArray<LWTextBackgroundColor *>* backgroundColors;//一个包含文本背景颜色的信息的数组
@property (nonatomic,strong,readonly) NSArray<LWTextBoundingStroke *>* boudingStrokes;//一个包含文本边框描边信息的数组
@property (nonatomic,assign,getter = isNeedDebugDraw) BOOL needDebugDraw;//是否开启调试绘制模式,默认是NO
@property (nonatomic,assign,getter = isNeedAttachmentDraw) BOOL needAttachmentDraw;//是否需要绘制附件
@property (nonatomic,assign,getter = isNeedTextBackgroundColorDraw) BOOL needTextBackgroundColorDraw;//是否需要绘制文本背景颜色
@property (nonatomic,assign,getter = isNeedStrokeDraw) BOOL needStrokeDraw;//是否需要描边绘制
@property (nonatomic,assign,getter = isNeedBoudingStrokeDraw) BOOL needBoudingStrokeDraw;//是否需要绘制文本边框描边
@property (nonatomic,assign,readonly) BOOL needTruncation;//是否折叠

/**
 *  构造方法
 *
 *  @param container LWTextContainer
 *  @param text      NSAttributedString
 *
 *  @return LWTextLayout实例
 */
+ (LWTextLayout *)lw_layoutWithContainer:(LWTextContainer *)container text:(NSAttributedString *)text;


/**
 *  绘制文本
 *
 *  @param context        CGContextRef对象，绘制上下文
 *  @param size           绘制范围的大小
 *  @param point          在LWAsyncDisplayView中的绘制起始点CGPoint
 *  @param containerView  绘制文本的容器UIView对象
 *  @param containerLayer 绘制文本的容器UIView对象的CALayer对象(.layer)
 *  @param isCancelld     是否取消绘制
 */

- (void)drawIncontext:(CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
        containerView:(UIView *)containerView
       containerLayer:(CALayer *)containerLayer
          isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld;


/**
 *  将文本附件从UIView或CALayer上移除，在即将开始绘制时调用
 */
- (void)removeAttachmentFromSuperViewOrLayer;

@end
