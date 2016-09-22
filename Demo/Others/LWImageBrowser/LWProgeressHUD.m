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

#import "LWProgeressHUD.h"
#import "LWImageBrowserDefine.h"


const CGFloat kHUDSize = 70.0f;

@interface LWProgeressHUD ()

@property (nonatomic,strong) CAShapeLayer* shapeLayer;

@end

@implementation LWProgeressHUD

+ (LWProgeressHUD *)showHUDAddedTo:(UIView *)view {
    LWProgeressHUD* hud = [[LWProgeressHUD alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           kHUDSize,
                                                                           kHUDSize)];
    hud.center = view.center;
    hud.progress = 0.0f;
    [view addSubview:hud];
    return hud;
}


+ (void)hideAllHUDForView:(UIView *)view {
    for (UIView* subView in view.subviews) {
        if ([subView isMemberOfClass:[LWProgeressHUD class]]) {
            [subView removeFromSuperview];
        }
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.shapeLayer.strokeEnd = self.progress;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 8.0f;
        self.layer.masksToBounds = YES;
        self.backgroundColor = RGB(0, 0, 0, 0.75f);
        
        UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:self.center
                                                            radius:25.0f
                                                        startAngle:-M_PI/2
                                                          endAngle:3.0f/2 * M_PI
                                                         clockwise:YES];
        
        CAShapeLayer* shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.lineWidth = 2.0f;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.strokeStart = 0.0f;
        shapeLayer.strokeEnd = 1.0f;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        [self.layer addSublayer:shapeLayer];
        
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.path = path.CGPath;
        self.shapeLayer.lineWidth = 2.0f;
        self.shapeLayer.lineCap = kCALineCapRound;
        self.shapeLayer.strokeStart = 0.0f;
        self.shapeLayer.strokeEnd = 0.0f;
        self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
        self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:self.shapeLayer];
    }
    return self;
}

@end
