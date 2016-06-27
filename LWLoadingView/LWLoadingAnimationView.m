/*
 https://github.com/waynezxcv/Gallop

 Copyright (c) 2016 waynezxcv <liuweiself@126.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


#import "LWLoadingAnimationView.h"

@interface LWLoadingAnimationView ()

@property (nonatomic,strong) NSMutableArray* pulsingLayers;
@property (nonatomic,strong)CALayer* animationLayer;
@property (nonatomic,strong)CALayer* thumbnailLayer;

@end

@implementation LWLoadingAnimationView

- (id)initWithFrame:(CGRect)frame {
    self  = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.animationLayer = [[CALayer alloc]init];
        self.animationLayer.contentsScale = [UIScreen mainScreen].scale;
        self.animationLayer.zPosition = -1;
        [self.layer addSublayer:self.animationLayer];

        self.thumbnailLayer = [[CALayer alloc]init];
        self.thumbnailLayer.backgroundColor = RGB(232, 104, 96,1.0f).CGColor;
        self.thumbnailLayer.cornerRadius = 7.5f;
        self.thumbnailLayer.borderWidth = 0.0f;
        self.thumbnailLayer.masksToBounds = YES;
        self.thumbnailLayer.borderColor = [UIColor whiteColor].CGColor;
        self.thumbnailLayer.zPosition = -1;
        self.thumbnailLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:self.thumbnailLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.bounds;
    CGRect thumbnailRect = CGRectMake(0, 0, 15.0f, 15.0f);
    thumbnailRect.origin.x = (rect.size.width - thumbnailRect.size.width)/2.0;
    thumbnailRect.origin.y = (rect.size.height - thumbnailRect.size.height)/2.0;
    self.thumbnailLayer.frame = thumbnailRect;
}

- (NSMutableArray *)pulsingLayers {
    if (!_pulsingLayers) {
        _pulsingLayers = [[NSMutableArray alloc] init];
    }
    return _pulsingLayers;
}

- (void)animationBegin {
    CGRect rect = self.bounds;
    NSInteger pulsingCount = 3;
    double animationDuration = 0.8f;
    for (int i = 0; i < pulsingCount; i++) {
        CALayer* pulsingLayer = [[CALayer alloc]init];
        pulsingLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        pulsingLayer.backgroundColor = self.animationTintColor.CGColor;
        pulsingLayer.borderColor = self.animationTintColor.CGColor;
        pulsingLayer.borderWidth = 1.0;
        pulsingLayer.cornerRadius = rect.size.height/2;
        pulsingLayer.contentsScale = [UIScreen mainScreen].scale;

        CAMediaTimingFunction* defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        CAAnimationGroup* animationGroup = [[CAAnimationGroup alloc]init];
        animationGroup.fillMode = kCAFillModeBoth;
        animationGroup.beginTime = CACurrentMediaTime() + (double)i * animationDuration/(double)pulsingCount;
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = HUGE_VAL;
        animationGroup.timingFunction = defaultCurve;

        CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.autoreverses = NO;
        scaleAnimation.fromValue = [NSNumber numberWithDouble:0.2];
        scaleAnimation.toValue = [NSNumber numberWithDouble:0.8];

        CAKeyframeAnimation* opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values = @[[NSNumber numberWithDouble:0.6],[NSNumber numberWithDouble:0.35],[NSNumber numberWithDouble:0.3],[NSNumber numberWithDouble:0.0]];
        opacityAnimation.keyTimes = @[[NSNumber numberWithDouble:0.0],[NSNumber numberWithDouble:0.25],[NSNumber numberWithDouble:0.5],[NSNumber numberWithDouble:1.0]];
        animationGroup.animations = @[scaleAnimation,opacityAnimation];
        [pulsingLayer addAnimation:animationGroup forKey:@"pulsing"];
        [self.animationLayer addSublayer:pulsingLayer];
        [self.pulsingLayers addObject:pulsingLayer];
    }
}

- (void)animationStop {
    for (CALayer* pulsingLayer in self.pulsingLayers) {
        [pulsingLayer removeAllAnimations];
        [pulsingLayer removeFromSuperlayer];
    }
    [self.pulsingLayers removeAllObjects];
}

@end
