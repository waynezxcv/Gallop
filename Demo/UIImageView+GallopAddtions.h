//
//  UIImageView+GallopAddtions.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/5/23.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView(GallopAddtions)


- (void)lw_setImage:(UIImage *)image
      containerSize:(CGSize)size
       cornerRadius:(CGFloat)cornerRadius
cornerBackgroundColor:(UIColor *)color
  cornerBorderColor:(UIColor *)borderColor
        borderWidth:(CGFloat)borderWidth;

@end
