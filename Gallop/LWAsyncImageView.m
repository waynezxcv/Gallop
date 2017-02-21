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



#import "LWAsyncImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "LWImageStorage.h"
#import "GallopUtils.h"
#import "LWTransaction.h"
#import "CALayer+LWTransaction.h"
#import "UIImage+Gallop.h"
#import "NSData+ImageContentType.h"
#import "LWGIFImage.h"



@interface LWAsyncImageView ()
/**
 * 显示gif动画图片时，当前帧的图片
 */
@property (nonatomic,strong) UIImage* gifCurrentFrame;

/**
 * 显示gif动画图片时，当前帧的序号
 */
@property (nonatomic,assign) NSUInteger gifCurrentFrameIndex;

/**
 * 显示gif动画图片时，循环播放的剩余次数
 */
@property (nonatomic,assign) NSUInteger loopCountdown;


/**
 * 显示gif动画图片时，播放动画时间累加
 */
@property (nonatomic,assign) NSTimeInterval accumulator;

/**
 * 显示gif动画图片时，用于播放gif的定时器，定时触发时，完成切换图片，并setNeedDisplay
 */
@property (nonatomic,strong) CADisplayLink* displayLink;


/**
 * 当前是否需要播放动画，当前LWAsyncImageView可见且gif模型不为nil时返回YES
 */
@property (nonatomic,assign) BOOL needAnimate;


/**
 * 显示gif动画图片时,一个flag值，表示当前帧的参数已经准备好，可以开始渲染了
 */
@property (nonatomic,assign) BOOL needDisplayNextFrame;


@end

@implementation LWAsyncImageView

#pragma mark - Init

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.animationRunLoopMode = [self defaultAnimatitonRunLoopMode];
}


#pragma mark - UIView LifeCycle

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self animateIfNeed];
}


- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self animateIfNeed];
}

- (void)dealloc {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

#pragma mark - Orverride

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    [self animateIfNeed];
}

- (void)setHidden:(BOOL)hidden {
    if (self.displayAsynchronously) {
        [self.layer.lw_asyncTransaction addAsyncOperationWithTarget:self
                                                           selector:@selector(_setHidden:)
                                                             object:@(hidden)
                                                         completion:nil];
    } else {
        [self _setHidden:@(hidden)];
    }
}

- (void)_setHidden:(NSNumber *)hidden {
    [super setHidden:[hidden boolValue]];
    [self animateIfNeed];
}

- (void)setFrame:(CGRect)frame {
    if (self.displayAsynchronously) {
        [self.layer.lw_asyncTransaction addAsyncOperationWithTarget:self
                                                           selector:@selector(_setFrameValue:)
                                                             object:[NSValue valueWithCGRect:frame]
                                                         completion:nil];
    } else {
        [super setFrame:frame];
    }
}

- (void)_setFrameValue:(NSValue *)frameValue {
    if (!CGRectEqualToRect(super.frame,[frameValue CGRectValue])) {
        [super setFrame:[frameValue CGRectValue]];
    }
    [self animateIfNeed];
}

- (UIImage *)image {
    UIImage* image = nil;
    
    if (self.gifImage) {
        //如果是gif动画，这里从去当前帧的UIImage对象,当displayLink计时器触发时，会调用
        //“- (void)displayLayer:(CALayer *)layer ”方法。通过设置Layer的contents完成动画的播放
        image = self.gifCurrentFrame;
    } else {
        CGImageRef imageRef = (__bridge CGImageRef)(self.layer.contents);
        image = [UIImage imageWithCGImage:imageRef];
    }
    return image;
}



- (void)setImage:(UIImage *)image {
    //清除image
    if (!image) {
        if (self.image) {
            CGImageRef imageRef = (__bridge_retained CGImageRef)(self.layer.contents);
            id contents = self.layer.contents;
            self.layer.contents = nil;
            if (imageRef) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    [contents class];
                    CFRelease(imageRef);
                });
            }
        }
        
    } else {
        if (self.displayAsynchronously) {
            [self.layer.lw_asyncTransaction addAsyncOperationWithTarget:self.layer
                                                               selector:@selector(setContents:)
                                                                 object:(__bridge id _Nullable)image.CGImage
                                                             completion:nil];
        } else {
            [self.layer setContents:(__bridge id _Nullable)image.CGImage];
        }
    }
}

- (void)setGifImage:(LWGIFImage *)gifImage {
    if ([_gifImage isEqual:gifImage]) {
        return;
    }
    //清除gifImage
    if (!gifImage) {
        if (self.gifImage) {
            LWGIFImage* oldOne = _gifImage;
            _gifImage = nil;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [oldOne class];
            });
            [self stopAnimating];
        }
    } else {
        LWGIFImage* oldOne = _gifImage;
        _gifImage = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [oldOne class];
        });
        
        _gifImage = gifImage;
        
        //初始化为第一帧
        self.gifCurrentFrame = gifImage.coverImage;
        self.gifCurrentFrameIndex = 0;
        
        
        if (gifImage.loopCount > 0) {
            self.loopCountdown = gifImage.loopCount;
        } else {
            self.loopCountdown = NSUIntegerMax;
        }
        
        self.accumulator = 0.0;
        [self updateNeedAnimate];//确定是否需要动画
        
        if (self.needAnimate) {
            [self startAnimating];
        }
        [self.layer setNeedsDisplay];
    }
}

- (void)startAnimating {
    if (self.gifImage) {
        
        // 1、frameInterval : 标识间隔多少帧调用一次displayLinkFired：方法，默认是1
        // 2、先求出gif中每帧图片的播放时间，求出这些播放时间的最大公约数，
        // 3、将这个最大公约数*刷新速率，再与1比取最大值，该值作为frameInterval。
        // 4、将GIF动画的每帧图片显示时间除以帧显示时间的最大公约数，得到单位时间内GIF动画的每个帧显示时间的比例，然后再乘以屏幕刷新速率kDisplayRefreshRate作为displayLink.frameInterval,
        // 正好可以用displayLink调用刷新方法的频率来保证GIF动画的帧图片展示时间 frame times 的间隔比例，使GIF动画的效果能够正常显示。
        
        const NSTimeInterval kDisplayRefreshRate = 60.0;//60hz
        //创建代理对象来将displayLinkFired:方法消息转发给一个weak的self..
        //因为LWAsyncImageView包含了strong的dislayLink对象，displayLink又会持有target，会造成循环引用
        
        if (!self.displayLink) {
            
            LWProxy* proxy = [LWProxy proxyWithObject:self];
            self.displayLink = [CADisplayLink displayLinkWithTarget:proxy selector:@selector(displayLinkFired:)];
            [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:self.animationRunLoopMode];
            
        }
        
        self.displayLink.frameInterval = MAX([self frameDelayGreatestCommonDivisor] * kDisplayRefreshRate, 1);
        self.displayLink.paused = NO;
        
    } else {
        [super startAnimating];
    }
}

- (void)stopAnimating {
    if (self.gifImage) {
        self.displayLink.paused = YES;
    } else {
        [super stopAnimating];
    }
}

- (BOOL)isAnimating {
    BOOL isAnimating = NO;
    if (self.gifImage) {
        isAnimating = self.displayLink && !self.displayLink.isPaused;
    } else {
        isAnimating = [super isAnimating];
    }
    return isAnimating;
}


- (void)setAnimationRunLoopMode:(NSString *)animationRunLoopMode {
    if (![@[NSDefaultRunLoopMode, NSRunLoopCommonModes] containsObject:animationRunLoopMode]) {
        _animationRunLoopMode = [[self class] defaultAnimatitonRunLoopMode];
    } else {
        _animationRunLoopMode = animationRunLoopMode;
    }
}

- (void)displayLayer:(CALayer *)layer {
    if (self.displayAsynchronously) {
        [self.layer.lw_asyncTransaction addAsyncOperationWithTarget:self.layer
                                                           selector:@selector(setContents:)
                                                             object:(__bridge id _Nullable)self.image.CGImage
                                                         completion:nil];
    } else {
        [self.layer setContents:(__bridge id _Nullable)self.image.CGImage];
    }
}


#pragma mark - Private

//触发CADisplayLink计时器
- (void)displayLinkFired:(CADisplayLink *)displayLink {
    if (!self.needAnimate) {
        return;
    }
    
    //从timesForIndex字典中取得帧的显示时间
    NSNumber* delayTimeNumber = [self.gifImage.timesForIndex objectForKey:@(self.gifCurrentFrameIndex)];
    
    if (delayTimeNumber) {
        NSTimeInterval delayTime = [delayTimeNumber floatValue];
        
        //当前帧图片
        UIImage* image = [self.gifImage frameImageWithIndex:self.gifCurrentFrameIndex];
        
        if (image) {
            self.gifCurrentFrame = image;
            
            if (self.needDisplayNextFrame) {
                [self.layer setNeedsDisplay];//渲染当前帧图像
                self.needDisplayNextFrame = NO;
            }
            
            self.accumulator += displayLink.duration * displayLink.frameInterval;
            
            //循环播放
            while (self.accumulator >= delayTime) {
                self.accumulator -= delayTime; //累加display link fires的时间间隔，并与帧图片的time做比较，如果小于time说明该帧图片还需要继续展示，否则该帧图片结束展示。
                self.gifCurrentFrameIndex++;
                
                if (self.gifCurrentFrameIndex >= self.gifImage.frameCount) {
                    self.loopCountdown --;//剩余循环次数减一
                    if (self.loopCountdown == 0) {
                        [self stopAnimating];
                        return;
                    }
                    self.gifCurrentFrameIndex = 0;
                }
                //当前帧的参数已经设置完毕，可以渲染下一帧了
                self.needDisplayNextFrame = YES;
            }
        }
    } else {
        self.gifCurrentFrameIndex ++;
    }
}

- (void)animateIfNeed {
    [self updateNeedAnimate];
    if (self.needAnimate) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}

- (void)updateNeedAnimate {
    BOOL isVisible = self.window && self.superview && !CGRectEqualToRect(super.frame, CGRectZero) && ![self isHidden] && self.alpha > 0.0;
    self.needAnimate = self.gifImage && isVisible;
}


- (NSTimeInterval)frameDelayGreatestCommonDivisor {
    
    const NSTimeInterval kGreatestCommonDivisorPrecision = 2.0 / kLWGIFDelayTimeIntervalMinimumValue;
    NSArray* delays = self.gifImage.timesForIndex.allValues;
    NSUInteger scaledGCD = lrint([delays.firstObject floatValue] * kGreatestCommonDivisorPrecision);
    for (NSNumber* value in delays) {
        scaledGCD = [GallopUtils greatestCommonDivisorWithNumber:lrint([value floatValue] * kGreatestCommonDivisorPrecision) another:scaledGCD];
    }
    return scaledGCD / kGreatestCommonDivisorPrecision;
}


- (NSString *)defaultAnimatitonRunLoopMode {
    return NSRunLoopCommonModes;
}

@end


