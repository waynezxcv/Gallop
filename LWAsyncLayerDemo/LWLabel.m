//
//  LWLabel.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWLabel.h"
#import "LWAsyncDisplayLayer.h"
#import "LWRunLoopObserver.h"

@interface LWLabel ()<LWAsyncDisplayLayerDelegate>

@property (nonatomic,strong) LWAsyncDisplayLayer* asyncDisplayLayer;

@end

@implementation LWLabel

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.asyncDisplayLayer = [[LWAsyncDisplayLayer alloc] init];
        self.asyncDisplayLayer.asyncDisplayDelegate = self;
        [self.layer addSublayer:self.asyncDisplayLayer];
    }
    return self;
}

#pragma mark - Setter & Getter

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.asyncDisplayLayer setFrame:frame];
}


- (void)setTextLayout:(LWTextLayout *)textLayout {
    if (_textLayout != textLayout) {
        _textLayout = textLayout;
    }
    [self.asyncDisplayLayer asyncDisplayContent];
}

- (void)cleanUp {
    [self.asyncDisplayLayer cleanUp];
}

#pragma mark - LWAsyncDisplayLayerDelegate

- (BOOL)willBeginAsyncDisplay:(LWAsyncDisplayLayer *)layer {
    return YES;
}

- (void)didAsyncDisplay:(LWAsyncDisplayLayer *)layer context:(CGContextRef)context size:(CGSize)size {
    [self.textLayout drawTextLayoutIncontext:context];
}

- (void)didFinishAsyncDisplay:(LWAsyncDisplayLayer *)layer isFiniedsh:(BOOL) isFinished {
    
}

#pragma mark - Private
static void _drawImage(UIImage* image,CGRect rect,CGContextRef context) {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextRestoreGState(context);
}

@end
