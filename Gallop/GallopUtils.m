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



#import "GallopUtils.h"

@implementation GallopUtils

+ (CGFloat)contentsScale {
    static dispatch_once_t once;
    static CGFloat contentsScale;
    dispatch_once(&once, ^{
        contentsScale = [UIScreen mainScreen].scale;
    });
    return contentsScale;
}


+ (UIImage *)screenshotFromView:(UIView *)aView {
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size,NO,[UIScreen mainScreen].scale);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshotImage;
}


/**
 *  求两个数的最大公约数
 *
 *  @param aView 一个UIView对象
 *
 *  @return 最大公约数
 */
+ (NSUInteger)greatestCommonDivisorWithNumber:(NSUInteger)a another:(NSUInteger)b {
    if (a < b) {
        return [self greatestCommonDivisorWithNumber:b another:a];
    } else if (a == b) {
        return b;
    }
    while (true) {
        NSUInteger remainder = a % b;
        if (remainder == 0) {
            return b;
        }
        a = b;
        b = remainder;
    }
}

@end



