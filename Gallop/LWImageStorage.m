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
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeInteger:self.tag forKey:@"tag"];
    [aCoder encodeBool:self.clipsToBounds forKey:@"clipsToBounds"];
    [aCoder encodeBool:self.opaque forKey:@"opaque"];
    [aCoder encodeBool:self.hidden forKey:@"hidden"];
    [aCoder encodeFloat:self.alpha forKey:@"alpha"];
    [aCoder encodeCGRect:self.frame forKey:@"frame"];
    [aCoder encodeCGRect:self.bounds forKey:@"bounds"];
    [aCoder encodeFloat:self.height forKey:@"height"];
    [aCoder encodeFloat:self.width forKey:@"width"];
    [aCoder encodeFloat:self.left forKey:@"left"];
    [aCoder encodeFloat:self.right forKey:@"right"];
    [aCoder encodeFloat:self.top forKey:@"top"];
    [aCoder encodeFloat:self.bottom forKey:@"bottom"];
    [aCoder encodeCGPoint:self.center forKey:@"center"];
    [aCoder encodeCGPoint:self.position forKey:@"position"];
    [aCoder encodeFloat:self.cornerRadius forKey:@"cornerRadius"];
    [aCoder encodeObject:self.cornerBackgroundColor forKey:@"cornerBackgroundColor"];
    [aCoder encodeObject:self.cornerBorderColor forKey:@"cornerBorderColor"];
    [aCoder encodeFloat:self.cornerBorderWidth forKey:@"cornerBorderWidth"];
    [aCoder encodeObject:self.shadowColor forKey:@"shadowColor"];
    [aCoder encodeFloat:self.shadowOpacity forKey:@"shadowOpacity"];
    [aCoder encodeCGSize:self.shadowOffset forKey:@"shadowOffset"];
    [aCoder encodeFloat:self.shadowRadius forKey:@"shadowRadius"];
    [aCoder encodeFloat:self.contentsScale forKey:@"contentsScale"];
    [aCoder encodeObject:self.backgroundColor forKey:@"backgroundColor"];
    [aCoder encodeInteger:self.contentMode forKey:@"contentMode"];
    [aCoder encodeUIEdgeInsets:self.htmlLayoutEdgeInsets forKey:@"htmlLayoutEdgeInsets"];
    [aCoder encodeObject:self.extraDisplayIdentifier forKey:@"extraDisplayIdentifier"];
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
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.tag = [aDecoder decodeIntegerForKey:@"tag"];
        self.clipsToBounds = [aDecoder decodeBoolForKey:@"clipsToBounds"];
        self.opaque = [aDecoder decodeBoolForKey:@"opaque"];
        self.hidden = [aDecoder decodeBoolForKey:@"hidden"];
        self.alpha = [aDecoder decodeFloatForKey:@"alpha"];
        self.frame = [aDecoder decodeCGRectForKey:@"frame"];
        self.bounds = [aDecoder decodeCGRectForKey:@"bounds"];
        self.center = [aDecoder decodeCGPointForKey:@"center"];
        self.position = [aDecoder decodeCGPointForKey:@"position"];
        self.cornerRadius = [aDecoder decodeFloatForKey:@"cornerRadius"];
        self.cornerBackgroundColor = [aDecoder decodeObjectForKey:@"cornerBackgroundColor"];
        self.cornerBorderColor = [aDecoder decodeObjectForKey:@"cornerBorderColor"];
        self.cornerBorderWidth = [aDecoder decodeFloatForKey:@"cornerBorderWidth"];
        self.shadowColor = [aDecoder decodeObjectForKey:@"shadowColor"];
        self.shadowOpacity = [aDecoder decodeFloatForKey:@"shadowOpacity"];
        self.shadowOffset = [aDecoder decodeCGSizeForKey:@"shadowOffset"];
        self.shadowRadius = [aDecoder decodeFloatForKey:@"shadowRadius"];
        self.contentsScale = [aDecoder decodeFloatForKey:@"contentsScale"];
        self.backgroundColor = [aDecoder decodeObjectForKey:@"backgroundColor"];
        self.contentMode = [aDecoder decodeIntegerForKey:@"contentMode"];
        self.htmlLayoutEdgeInsets = [aDecoder decodeUIEdgeInsetsForKey:@"htmlLayoutEdgeInsets"];
        self.extraDisplayIdentifier = [aDecoder decodeObjectForKey:@"extraDisplayIdentifier"];
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
    if (self.cornerBorderWidth != 0 || self.cornerRadius != 0) {
        return YES;
    }
    else {
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




