//
//  CALayer+AsyncDisplay.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/21.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "CALayer+AsyncDisplay.h"
#import <UIKit/UIKit.h>



@implementation CALayer(AsyncDisplay)

- (void)asyncDisplayWithBolock:(AsyncDisplayBlock) displayBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,self.opaque, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == NULL) {
            return;
        }
        displayBlock(context,self.bounds.size);
        UIImage* screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contents = (__bridge id)screenshotImage.CGImage;
        });
    });
}

@end
