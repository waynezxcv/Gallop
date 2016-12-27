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

#import "LWStorage.h"
#import "GallopUtils.h"
#import <objc/runtime.h>
#import "GallopDefine.h"


@interface LWStorage ()

@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat left;
@property (nonatomic,assign) CGFloat right;
@property (nonatomic,assign) CGFloat top;
@property (nonatomic,assign) CGFloat bottom;

@end


@implementation LWStorage

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
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
    self = [super init];
    if (self) {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.tag = [aDecoder decodeIntegerForKey:@"tag"];
        self.clipsToBounds = [aDecoder decodeBoolForKey:@"clipsToBounds"];
        self.opaque = [aDecoder decodeBoolForKey:@"opaque"];
        self.hidden = [aDecoder decodeBoolForKey:@"hidden"];
        self.alpha = [aDecoder decodeFloatForKey:@"alpha"];
        self.frame = [aDecoder decodeCGRectForKey:@"frame"];
        self.bounds = [aDecoder decodeCGRectForKey:@"bounds"];
        self.height = [aDecoder decodeFloatForKey:@"height"];
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.left = [aDecoder decodeFloatForKey:@"left"];
        self.right = [aDecoder decodeFloatForKey:@"right"];
        self.top = [aDecoder decodeFloatForKey:@"top"];
        self.bottom = [aDecoder decodeFloatForKey:@"bottom"];
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

#pragma mark - Init

- (id)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.tag = -1;
        self.clipsToBounds = NO;
        self.opaque = YES;
        self.hidden = NO;
        self.alpha = 1.0f;
        self.frame = CGRectZero;
        self.bounds = CGRectZero;
        self.cornerRadius = 0.0f;
        self.cornerBackgroundColor = [UIColor whiteColor];
        self.cornerBorderColor = [UIColor whiteColor];
        self.cornerBorderWidth = 0.0f;
        self.shadowColor = nil;
        self.shadowOpacity = 0.0f;
        self.shadowOffset = CGSizeZero;
        self.shadowRadius = 0.0f;
        self.contentsScale = [GallopUtils contentsScale];
        self.backgroundColor = [UIColor whiteColor];
        self.contentMode = UIViewContentModeScaleToFill;
        self.extraDisplayIdentifier = nil;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.identifier = @"";
        self.tag = -1;
        self.clipsToBounds = NO;
        self.opaque = YES;
        self.hidden = NO;
        self.alpha = 1.0f;
        self.frame = CGRectZero;
        self.bounds = CGRectZero;
        self.cornerRadius = 0.0f;
        self.cornerBackgroundColor = nil;
        self.cornerBorderColor = nil;
        self.cornerBorderWidth = 0.0f;
        self.shadowColor = nil;
        self.shadowOpacity = 0.0f;
        self.shadowOffset = CGSizeZero;
        self.shadowRadius = 0.0f;
        self.contentsScale = [GallopUtils contentsScale];
        self.backgroundColor = nil;
        self.contentMode = UIViewContentModeScaleToFill;
        self.extraDisplayIdentifier = nil;
    }
    return self;
}


#pragma mark - Getter & Setter

- (void)setCenter:(CGPoint)center {
    CGRect frame = self.frame;
    frame.origin.x = center.x - frame.size.width * 0.5f;
    frame.origin.y = center.y - frame.size.height * 0.5f;
    self.frame = frame;
}

- (void)setBounds:(CGRect)bounds {
    CGRect frame = self.frame;
    frame = CGRectMake(frame.origin.x, frame.origin.y, bounds.size.width, bounds.size.height);
    self.frame = frame;
}


- (CGRect)bounds {
    return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (CGFloat)right {
    return  self.frame.origin.x + self.width;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.height;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGPoint)center {
    return CGPointMake(self.frame.origin.x + self.frame.size.width * 0.5f,
                       self.frame.origin.y + self.frame.size.height * 0.5f);
}


@end
