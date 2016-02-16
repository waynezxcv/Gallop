//
//  FPSLabel.h
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 WayneInc. All rights reserved.
//


#import "LWFPSLabel.h"

#define kSize CGSizeMake(55, 20)

@implementation LWFPSLabel {
    CADisplayLink* _link;
    NSUInteger _count;
    NSTimeInterval _lastTime;
    UIFont* _font;
    UIFont* _subFont;
    NSTimeInterval _llll;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size = kSize;
    }
    self = [super initWithFrame:frame];
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.textAlignment = NSTextAlignmentCenter;
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.700];
    _font = [UIFont fontWithName:@"Menlo" size:14];
    if (_font) {
        _subFont = [UIFont fontWithName:@"Menlo" size:4];
    } else {
        _font = [UIFont fontWithName:@"Courier" size:14];
        _subFont = [UIFont fontWithName:@"Courier" size:4];
    }
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    return self;
}

- (void)dealloc {
    [_link invalidate];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return kSize;
}

- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    CGFloat progress = fps / 60.0;
    UIColor* color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    NSDictionary* attributes_1 = @{NSForegroundColorAttributeName:color,
                                   NSFontAttributeName:_font};
    NSDictionary* attributes_2 = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                   NSFontAttributeName:_font};
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS",(int)round(fps)]];
    [text addAttributes:attributes_1 range:NSMakeRange(0, text.length - 3)];
    [text addAttributes:attributes_2 range:NSMakeRange(text.length - 3, 3)];
    self.attributedText = text;
}

@end
