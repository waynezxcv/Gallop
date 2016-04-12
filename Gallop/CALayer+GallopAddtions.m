//
//  CALayer+CornerRadius.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/12.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "CALayer+GallopAddtions.h"
#import "LWRunLoopTransactions.h"


@implementation CALayer(GallopAddtions)

#pragma mark - CornerRadius

- (void)lw_delaySetContents:(id)contents {
    LWRunLoopTransactions* transactions = [LWRunLoopTransactions
                                           transactionsWithTarget:self
                                           selector:@selector(setContents:)
                                           object:contents];
    [transactions commit];
}

- (void)lw_advanceCornerRadius:(CGFloat)cornerRadius cornerBackgroundColor:(UIColor *)color image:(UIImage *)image {
    CGSize size = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(size, YES, scale);
        if (nil == UIGraphicsGetCurrentContext()) {
            return;
        }
        UIBezierPath* cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius];
        UIBezierPath* backgroundRect = [UIBezierPath bezierPathWithRect:self.bounds];
        [color setFill];
        [backgroundRect fill];
        [cornerPath addClip];
        [image drawInRect:self.bounds];
        id processedImageRef = (__bridge id _Nullable)(UIGraphicsGetImageFromCurrentImageContext().CGImage);
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            [self lw_delaySetContents:processedImageRef];
        });
    });
}



@end
