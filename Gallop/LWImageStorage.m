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

#import "LWImageStorage.h"
#import "GallopDefine.h"
#import "LWAsyncDisplayLayer.h"
#import "UIImage+Gallop.h"
#import "GallopUtils.h"


@interface LWImageStorage()

@property (nonatomic,assign) BOOL needRerendering;

@end

@implementation LWImageStorage

@synthesize cornerRadius = _cornerRadius;
@synthesize cornerBorderWidth = _cornerBorderWidth;


#pragma mark - Override Hash & isEqual


- (BOOL)isEqual:(id)object {
    if (!object || ![object isMemberOfClass:[LWImageStorage class]]) {
        return NO;
    }
    if (self == object) {
        return YES;
    }
    
    LWImageStorage* imageStorage = (LWImageStorage *)object;
    return [imageStorage.contents isEqual:self.contents] && CGRectEqualToRect(imageStorage.frame, self.frame);
}


- (NSUInteger)hash {
    long v1 = (long)self.contents;
    long v2 = (long)[NSValue valueWithCGRect:self.frame];
    return v1 ^ v2;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.contents forKey:@"contents"];
    [aCoder encodeInteger:self.localImageType forKey:@"localImageType"];
    [aCoder encodeObject:self.placeholder forKey:@"placeholder"];
    [aCoder encodeBool:self.fadeShow forKey:@"fadeShow"];
    [aCoder encodeBool:self.userInteractionEnabled forKey:@"userInteractionEnabled"];
    [aCoder encodeBool:self.needRerendering forKey:@"needRerendering"];
    [aCoder encodeBool:self.needResize forKey:@"needResize"];
    [aCoder encodeBool:self.isBlur forKey:@"isBlur"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.contents = [aDecoder decodeObjectForKey:@"contents"];
        self.placeholder = [aDecoder decodeObjectForKey:@"placeholder"];
        self.localImageType = [aDecoder decodeIntegerForKey:@"localImageType"];
        self.fadeShow = [aDecoder decodeBoolForKey:@"fadeShow"];
        self.userInteractionEnabled = [aDecoder decodeBoolForKey:@"userInteractionEnabled"];
        self.needResize = [aDecoder decodeBoolForKey:@"needResize"];
        self.needRerendering = [aDecoder decodeBoolForKey:@"needRerendering"];
        self.isBlur = [aDecoder decodeBoolForKey:@"isBlur"];
    }
    return self;
}

#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    if (self) {
        self.contents = nil;
        self.userInteractionEnabled = YES;
        self.placeholder = nil;
        self.fadeShow = YES;
        self.clipsToBounds = NO;
        self.contentsScale = [GallopUtils contentsScale];
        self.needRerendering = NO;
        self.needResize = NO;
        self.localImageType = LWLocalImageDrawInLWAsyncDisplayView;
        self.isBlur = NO;
    }
    return self;
}

- (BOOL)needRerendering {
    //这个图片设置了圆角的相关属性，需要对原图进行处理
    if (self.cornerBorderWidth != 0 || self.cornerRadius != 0) {
        return YES;
    } else {
        return _needRerendering;
    }
}

#pragma mark - Methods

- (void)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(NSInteger)topCapHeight {
    
    if ([self.contents isKindOfClass:[UIImage class]] &&
        self.localImageType == LWLocalImageDrawInLWAsyncDisplayView) {
        self.contents = [(UIImage *)self.contents
                         stretchableImageWithLeftCapWidth:leftCapWidth
                         topCapHeight:topCapHeight];
    }
}

- (void)lw_drawInContext:(CGContextRef)context isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld {
    
    if (isCancelld()) {
        return;
    }
    
    if ([self.contents isKindOfClass:[NSURL class]]) {
        return;
    }
    
    if ([self.contents isKindOfClass:[UIImage class]] &&
        self.localImageType == LWLocalImageDrawInLWAsyncDisplayView) {
        
        
        UIImage* image = (UIImage *)self.contents;
        BOOL isOpaque = self.opaque;
        UIColor* backgroundColor = self.backgroundColor;
        CGFloat cornerRaiuds = self.cornerRadius;
        UIColor* cornerBackgroundColor = self.cornerBackgroundColor;
        UIColor* cornerBorderColor = self.cornerBorderColor;
        CGFloat cornerBorderWidth = self.cornerBorderWidth;
        CGRect rect = self.frame;
        rect = CGRectStandardize(rect);
        
        CGRect imgRect = {
            {rect.origin.x + cornerBorderWidth,rect.origin.y + cornerBorderWidth},
            {rect.size.width - 2 * cornerBorderWidth,rect.size.height - 2 * cornerBorderWidth}
        };
        
        if (!image) {
            return;
        }
        
        if (self.isBlur) {
            image = [image lw_applyBlurWithRadius:20
                                        tintColor:RGB(0, 0, 0, 0.15f)
                            saturationDeltaFactor:1.4
                                        maskImage:nil];
        }
        
        CGContextSaveGState(context);
        if (isOpaque && backgroundColor) {
            [backgroundColor setFill];
            UIRectFill(imgRect);
        }
        
        UIBezierPath* backgroundRect = [UIBezierPath bezierPathWithRect:imgRect];
        UIBezierPath* cornerPath = [UIBezierPath bezierPathWithRoundedRect:imgRect
                                                              cornerRadius:cornerRaiuds];
        
        if (cornerBackgroundColor) {
            [cornerBackgroundColor setFill];
            [backgroundRect fill];
        }
        [cornerPath addClip];
        
        [image lw_drawInRect:imgRect
                 contentMode:self.contentMode
               clipsToBounds:YES];
        
        CGContextRestoreGState(context);
        if (cornerBorderColor && cornerBorderWidth != 0) {
            [cornerPath setLineWidth:cornerBorderWidth];
            [cornerBorderColor setStroke];
            [cornerPath stroke];
        }
        
        
    }
}



@end




