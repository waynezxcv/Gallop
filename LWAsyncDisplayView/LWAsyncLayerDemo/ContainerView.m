//
//  ContainerView.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/2.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import "ContainerView.h"
#import "LWAsyncDisplayLayer.h"


@interface ContainerView ()<LWAsyncDisplayLayerDelegate>

@end

@implementation ContainerView

+ (Class)layerClass {
    return [LWAsyncDisplayLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.opaque = NO;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.backgroundColor = [UIColor clearColor];
        ((LWAsyncDisplayLayer *)self.layer).asyncDisplayDelegate = self;
    }
    return self;
}

- (void)cleanUp {
    [(LWAsyncDisplayLayer *)self.layer cleanUp];
}

- (void)drawConent {
    [(LWAsyncDisplayLayer *)self.layer asyncDisplayContent];
}

#pragma mark - LWAsyncDisplayLayerDelegate

- (BOOL)willBeginAsyncDisplay:(LWAsyncDisplayLayer *)layer {
    return YES;
}

- (void)didAsyncDisplay:(LWAsyncDisplayLayer *)layer context:(CGContextRef)context size:(CGSize)size{
    [self drawImage:[UIImage imageNamed:@"menu"] rect:_layout.menuPosition context:context];
    CGContextAddRect(context,_layout.avatarPosition);
    CGContextMoveToPoint(context, 0.0f, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextSetLineWidth(context, 0.3f);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextStrokePath(context);
}

- (void)didFinishAsyncDisplay:(LWAsyncDisplayLayer *)layer isFiniedsh:(BOOL)isFinished {

}

- (void)drawImage:(UIImage *)image rect:(CGRect)rect context:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextRestoreGState(context);
}
@end
