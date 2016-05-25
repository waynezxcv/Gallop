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
#import "GallopUtils.h"


@class LWTextLine;



@interface LWTextLayout : NSObject<NSCopying,NSCoding>

@property (nonatomic,strong,readonly) LWTextContainer* container;
@property (nonatomic,strong,readonly) NSAttributedString* text;
@property (nonatomic,assign,readonly) CTFrameRef ctFrame;
@property (nonatomic,assign,readonly) CTFramesetterRef ctFrameSetter;
@property (nonatomic,assign,readonly) CGRect cgPathBox;
@property (nonatomic,assign,readonly) CGPathRef cgPath;
@property (nonatomic,assign,readonly) CGSize suggestSize;
@property (nonatomic,assign,readonly) CGRect textBoundingRect;
@property (nonatomic,assign,readonly) CGSize textBoundingSize;
@property (nonatomic,assign) BOOL sizeToFit;
@property (nonatomic,strong,readonly) NSArray<LWTextLine *>* linesArray;
@property (nonatomic,strong,readonly) NSMutableArray<LWTextAttachment *>* attachments;
@property (nonatomic,strong,readonly) NSMutableArray<NSValue *>* attachmentRanges;
@property (nonatomic,strong,readonly) NSMutableArray<NSValue *>* attachmentRects;
@property (nonatomic,strong,readonly) NSMutableSet<id>* attachmentContentsSet;
@property (nonatomic,strong,readonly) NSMutableArray<LWTextHighlight *>* textHighlights;
@property (nonatomic,strong,readonly) NSMutableArray<LWTextBackgroundColor *>* backgroundColors;
@property (nonatomic,assign,getter = isNeedDebugDraw) BOOL needDebugDraw;
@property (nonatomic,assign,getter = isNeedAttachmentDraw) BOOL needAttachmentDraw;
@property (nonatomic,assign,getter = isNeedTextBackgroundColorDraw) BOOL needTextBackgroundColorDraw;

/**
 *  构造方法
 *
 *  @param container LWTextContainer
 *  @param text      NSAttributedString
 *
 *  @return LWTextLayout实例
 */
+ (LWTextLayout *)lw_layoutWithContainer:(LWTextContainer *)container text:(NSAttributedString *)text sizeToFit:(BOOL)sizeToFit;



//****  绘制  ****//
- (void)drawIncontext:(CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
        containerView:(UIView *)containerView
       containerLayer:(CALayer *)containerLayer
          isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld;


//****  将Attachment移除  ****//
- (void)removeAttachmentFromSuperViewOrLayer;

@end
