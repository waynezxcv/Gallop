//
//  CALayer+CornerRadius.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/12.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CALayer(GallopAddtions)

- (void)lw_advanceCornerRadius:(CGFloat)cornerRadous cornerBackgroundColor:(UIColor *)color;
- (void)lw_delaySetContents:(id)contents;

@end
