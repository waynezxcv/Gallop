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


@interface GallopUtils : NSObject

/**
 *  获取当前屏幕的contentScale
 *
 *  @return [UIScreen mainScreen].contentsScale
 */
+ (CGFloat)contentsScale;


/**
 *  获取UIView的截图
 *
 *  @param aView 一个UIView对象
 *
 *  @return 截图的UIImage
 */
+ (UIImage *)screenshotFromView:(UIView *)aView;

/**
 *  求两个数的最大公约数
 *
 *  @param aView 一个UIView对象
 *
 *  @return 最大公约数
 */
+ (NSUInteger)greatestCommonDivisorWithNumber:(NSUInteger)numb1 another:(NSUInteger)numb2;




@end

