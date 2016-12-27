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
#import "LWTextGlyph.h"




@class LWTextAttachment;

/**
 *  对CTLineRef的封装
 */
@interface LWTextLine : NSObject <NSCoding>

@property (nonatomic,assign,readonly) CTLineRef CTLine; //CoreText中的CTlineRef
@property (nonatomic,assign,readonly) NSRange range; //在string中的range
@property (nonatomic,assign,readonly) CGRect frame; //加上ascent和descent之后的frame,UIKit坐标系
@property (nonatomic,assign,readonly) CGSize size;  //frame.size
@property (nonatomic,assign,readonly) CGFloat width; //frame.size.width
@property (nonatomic,assign,readonly) CGFloat height; //frame.size.height
@property (nonatomic,assign,readonly) CGFloat top; //frame.origin.y
@property (nonatomic,assign,readonly) CGFloat bottom;//frame.origin.y + frame.size.height
@property (nonatomic,assign,readonly) CGFloat left;//frame.origin.x
@property (nonatomic,assign,readonly) CGFloat right;//frame.origin.x + frame.size.width
@property (nonatomic,assign,readonly) CGPoint lineOrigin;//CTLine的原点位置,UIKit坐标系
@property (nonatomic,assign,readonly) CGFloat ascent; //line ascent 上部距离
@property (nonatomic,assign,readonly) CGFloat descent;//line descent 下部距离
@property (nonatomic,assign,readonly) CGFloat leading;// line leading 行距
@property (nonatomic,assign,readonly) CGFloat lineWidth;// line width 行宽
@property (nonatomic,assign,readonly) CGFloat trailingWhitespaceWidth;//尾部空白的宽度
@property (nonatomic,copy,readonly) NSArray<LWTextGlyph *>* glyphs;//保存CGGlyph封装对象的数组
@property (nonatomic,copy,readonly) NSArray<LWTextAttachment *>* attachments;//包含文本附件的数组
@property (nonatomic,copy,readonly) NSArray<NSValue *>* attachmentRanges;//包含文本附件在文本中位置信息的数组
@property (nonatomic,copy,readonly) NSArray<NSValue *>* attachmentRects;//包含文本附件在LWAsyncDisplayView上位置CGRect信息的数组
@property (nonatomic) NSUInteger index;//ctline在CTFrameGetLines数组中的index
@property (nonatomic) NSUInteger row;//行数

/**
 *  构造方法
 *
 *  @param CTLine     CoreText中的CTLineRef对象
 *  @param lineOrigin CTLineRef对象的起始位置CGPoint对象
 *
 *  @return 一个LWTextLine对象
 */
+ (id)lw_textLineWithCTlineRef:(CTLineRef)CTLine lineOrigin:(CGPoint)lineOrigin;


@end
