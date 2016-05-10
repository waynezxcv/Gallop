//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//  Created by 刘微 on 16/3/7.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import "CALayer+GallopAddtions.h"
#import "LWRunLoopTransactions.h"


@implementation CALayer(GallopAddtions)

#pragma mark - CornerRadius

- (void)lw_delaySetContents:(id)contents {
    [[LWRunLoopTransactions transactionsWithTarget:self
                                          selector:@selector(setContents:)
                                            object:contents] commit];
}



- (void)lw_setImage:(UIImage *)image
      containerSize:(CGSize)size
       cornerRadius:(CGFloat)cornerRadius
cornerBackgroundColor:(UIColor *)color
  cornerBorderColor:(UIColor *)borderColor
        borderWidth:(CGFloat)borderWidth {
    CGFloat scale = [UIScreen mainScreen].scale;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(size, YES, scale);
        if (nil == UIGraphicsGetCurrentContext()) {
            return;
        }
        UIBezierPath* cornerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height)
                                                              cornerRadius:cornerRadius];
        UIBezierPath* backgroundRect = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
        [color setFill];
        [backgroundRect fill];
        [cornerPath addClip];
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        [borderColor setStroke];
        [cornerPath stroke];
        [cornerPath setLineWidth:borderWidth];
        id processedImageRef = (__bridge id _Nullable)(UIGraphicsGetImageFromCurrentImageContext().CGImage);
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setContents:processedImageRef];
        });
    });
}

@end
