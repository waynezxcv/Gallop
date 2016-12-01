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
 *  垂直方向对齐方式
 */
typedef NS_ENUM(NSUInteger, LWTextVericalAlignment) {
    /**
     *  顶部对齐
     */
    LWTextVericalAlignmentTop,
    /**
     *  居中对齐
     */
    LWTextVericalAlignmentCenter,
    /**
     *  底部对齐
     */
    LWTextVericalAlignmentBottom
};




/**
 *  文本容器，包含文本绘制的范围大小、路径、会edgeInsets等信息
 */
@interface LWTextContainer : NSObject <NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,assign) LWTextVericalAlignment vericalAlignment;//垂直对齐方式，默认是TOP
@property (nonatomic,assign,readonly) CGSize size;//容器的大小
@property (nonatomic,strong,readonly) UIBezierPath* path;//容器的路径
@property (nonatomic,assign,readonly) UIEdgeInsets edgeInsets;//边缘内嵌大小
@property (nonatomic,assign) NSInteger maxNumberOfLines;//最大行数限制

/**
 *  构造方法
 *
 *  @param size 容器大小
 *
 *  @return 一个LWTextContrainer对象
 */
+ (id)lw_textContainerWithSize:(CGSize)size;

/**
 *  构造方法
 *
 *  @param size       容器大小
 *  @param edgeInsets 边缘内嵌大小
 *
 *  @return 一个LWTextContrainer对象
 */
+ (id)lw_textContainerWithSize:(CGSize)size edgeInsets:(UIEdgeInsets)edgeInsets;

/**
 *  容器路径的行宽
 *
 *  @return 路径的行宽
 */
- (CGFloat)pathLineWidth;


@end
