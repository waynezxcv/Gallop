//
//  CALayer+CornerRadius.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/12.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "CALayer+GallopAddtions.h"
#import "LWRunLoopTransactions.h"
#import "NSObject+SwizzleMethod.h"
#import "objc/runtime.h"

static void* LWCornerRadiusKey = &LWCornerRadiusKey;
static void* LWCornerBackgroundColorKey = &LWCornerBackgroundColorKey;

@implementation CALayer(GallopAddtions)

#pragma mark - CornerRadius

- (void)lw_delaySetContents:(id)contents {
    LWRunLoopTransactions* transactions = [LWRunLoopTransactions
                                           transactionsWithTarget:self
                                           selector:@selector(setContents:)
                                           object:contents];
    [transactions commit];
}


- (void)lw_advanceCornerRadius:(CGFloat)cornerRadius cornerBackgroundColor:(UIColor *)color {
    objc_setAssociatedObject(self, LWCornerRadiusKey, @(cornerRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, LWCornerBackgroundColorKey,color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.class swizzleMethod:@selector(layoutSublayers) withMethod:@selector(lw_LayoutSublayers)];
}

- (UIColor *)cornerBackgroundColor {
    return objc_getAssociatedObject(self, LWCornerBackgroundColorKey);
}

- (CGFloat)lw_cornerRadius {
    return [objc_getAssociatedObject(self, LWCornerRadiusKey) floatValue];
}

- (void)lw_LayoutSublayers {
    NSLog(@"lw_layoutsubviews");
    CGSize size = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(size, YES, scale);
        if (nil == UIGraphicsGetCurrentContext()) {
            return;
        }
        UIBezierPath* cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self lw_cornerRadius]];
        UIBezierPath* backgroundRect = [UIBezierPath bezierPathWithRect:self.bounds];
        [[self cornerBackgroundColor] setFill];
        [backgroundRect fill];
        [cornerPath addClip];
        [self.contents drawInRect:self.bounds];
        id processedImageRef = (__bridge id _Nullable)(UIGraphicsGetImageFromCurrentImageContext().CGImage);
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contents = processedImageRef;
        });
    });
}


@end
