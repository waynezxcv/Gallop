//
//  UIImageView+GallopAddtions.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/5/23.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "UIImageView+GallopAddtions.h"

@implementation UIImageView(GallopAddtions)

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
        UIImage* processedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = processedImage;
        });
    });
}

@end
