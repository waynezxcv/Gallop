//
//  ContainerView.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/2.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "ContainerView.h"
#import "LWAsyncDisplayLayer.h"


@interface ContainerView ()<LWAsyncDisplayLayerDelegate>

@property (nonatomic,strong) LWAsyncDisplayLayer* asyncDisplayLayer;

@end

@implementation ContainerView

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

- (void)setLayout:(DiscoverLayout *)layout {
    if (_layout != layout) {
        _layout = layout;
    }
    [self.asyncDisplayLayer setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.asyncDisplayLayer setFrame:frame];
}


#pragma mark - LWAsyncDisplayLayerDelegate

- (BOOL)willBeginAsyncDisplay:(LWAsyncDisplayLayer *)layer {
    return YES;
}

- (void)didAsyncDisplay:(LWAsyncDisplayLayer *)layer context:(CGContextRef)context size:(CGSize)size isCancled:(BOOL)isCancled {
    [_layout.nameTextLayout drawTextLayoutIncontext:context];
    [_layout.textTextLayout drawTextLayoutIncontext:context];
    [_layout.timeStampTextLayout drawTextLayoutIncontext:context];
    [self drawImage:[UIImage imageNamed:@"menu"] rect:_layout.menuPosition context:context];
    CGContextAddRect(context,_layout.avatarPosition);
    CGContextMoveToPoint(context, 0.0f, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextSetLineWidth(context, 0.3f);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextStrokePath(context);
    if (isCancled) {
        NSLog(@"cancled");
    }
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
