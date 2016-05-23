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
#import "LWConstraint.h"



/***  约束管理 ***/
@interface LWConstraintManager : NSObject


/**
 *  设置Constraint。例如：[LWConstraintManager lw_makeConstraint:avatarStorage.constraint.leftMargin(10).topMargin(20).widthLength(40.0f).heightLength(40.0f)];
 */
+ (void)lw_makeConstraint:(LWConstraint* )constraint;


/**
 *  设置Constraint。并设置Cotainer（装载这个LWStorage的LWAsyncDisplayView的Size，这个Size默认宽度为屏幕宽度，高度动态计算，初始化值为CGFLOAT_MAX）
 */
+ (void)lw_makeConstraint:(LWConstraint* )constraint containerSize:(CGSize)size;


@end
