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

#import "LWTextAttachment.h"
#import <objc/runtime.h>
#import "GallopUtils.h"
#import "GallopDefine.h"



@implementation LWTextAttachment

+ (id)lw_textAttachmentWithContent:(id)content {
    LWTextAttachment* attachment = [[LWTextAttachment alloc] init];
    attachment.content = content;
    attachment.contentMode = UIViewContentModeScaleAspectFill;
    attachment.contentEdgeInsets = UIEdgeInsetsZero;
    return attachment;
}


- (id)init {
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.contentEdgeInsets = UIEdgeInsetsZero;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
    [aCoder encodeCGRect:self.frame forKey:@"frame"];
    [aCoder encodeObject:self.URL forKey:@"URL"];
    [aCoder encodeInteger:self.contentMode forKey:@"contentMode"];
    [aCoder encodeUIEdgeInsets:self.contentEdgeInsets forKey:@"contentEdgeInsets"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.range = [[aDecoder decodeObjectForKey:@"range"] rangeValue];
        self.frame = [aDecoder decodeCGRectForKey:@"frame"];
        self.URL = [aDecoder decodeObjectForKey:@"URL"];
        self.contentMode = [aDecoder decodeIntegerForKey:@"contentMode"];
        self.contentEdgeInsets = [aDecoder decodeUIEdgeInsetsForKey:@"contentEdgeInsets"];
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LWTextAttachment* attachment = [[LWTextAttachment alloc] init];
    if ([self.content conformsToProtocol:@protocol(NSCopying)]) {
        attachment.content = [self.content copy];
    } else {
        attachment.content = self.content;
    }
    attachment.range = self.range;
    attachment.frame = self.frame;
    attachment.URL = [self.URL copy];
    attachment.contentMode = self.contentMode;
    attachment.contentEdgeInsets = self.contentEdgeInsets;
    attachment.userInfo = [self.userInfo copy];
    return attachment;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

@end




@implementation LWTextHighlight

- (id)init {
    self = [super init];
    if (self) {
        self.content = nil;
        self.range = NSMakeRange(0, 0);
        self.linkColor = [UIColor clearColor];
        self.hightlightColor = [UIColor clearColor];
        self.positions = @[];
        self.userInfo = @{};
        self.type = LWTextHighLightTypeNormal;
    }
    return self;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
    [aCoder encodeObject:self.linkColor forKey:@"linkColor"];
    [aCoder encodeObject:self.hightlightColor forKey:@"hightlightColor"];
    [aCoder encodeObject:self.positions forKey:@"positions"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeInteger:self.type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.range = [[aDecoder decodeObjectForKey:@"range"] rangeValue];
        self.linkColor = [aDecoder decodeObjectForKey:@"linkColor"];
        self.hightlightColor = [aDecoder decodeObjectForKey:@"hightlightColor"];
        self.positions = [aDecoder decodeObjectForKey:@"positions"];
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
    }
    return self;
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LWTextHighlight* highlight = [[LWTextHighlight alloc] init];
    if ([self.content conformsToProtocol:@protocol(NSCopying)]) {
        highlight.content = [self.content copy];
    }
    else {
        highlight.content = self.content;
    }
    highlight.range = self.range;
    highlight.linkColor = [self.linkColor copy];
    highlight.hightlightColor = [self.hightlightColor copy];
    highlight.positions = [self.positions copy];
    highlight.userInfo = [self.userInfo copy];
    highlight.type = self.type;
    return highlight;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}


#pragma mark -
- (NSUInteger)hash {
    long v1 = (long)((__bridge void *)self.content);
    long v2 = (long)[NSValue valueWithRange:self.range];
    return v1 ^ v2;
}

- (BOOL)isEqual:(id)object{
    if (self == object) {
        return YES;
    }
    if (![object isMemberOfClass:self.class]){
        return NO;
    }
    LWTextHighlight* other = object;
    return other.content == _content && [NSValue valueWithRange:other.range] == [NSValue valueWithRange:self.range];
}


@end


@implementation LWTextBackgroundColor

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.range = NSMakeRange(0, 0);
        self.userInfo = @{};
        self.positions = @[];
    }
    return self;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.backgroundColor forKey:@"backgroundColor"];
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeObject:self.positions forKey:@"positions"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.backgroundColor = [aDecoder decodeObjectForKey:@"backgroundColor"];
        self.range = [[aDecoder decodeObjectForKey:@"range"] rangeValue];
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        self.positions = [aDecoder decodeObjectForKey:@"positions"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LWTextBackgroundColor* bgColor = [[LWTextBackgroundColor alloc] init];
    bgColor.backgroundColor = [self.backgroundColor copy];
    bgColor.range = self.range;
    bgColor.userInfo = [self.userInfo copy];
    bgColor.positions = [self.positions copy];
    return bgColor;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

@end








//*** Text描边 ***//

@implementation LWTextStroke

- (id)init {
    self = [super init];
    if (self) {
        self.range = NSMakeRange(0, 0);
        self.strokeColor = [UIColor blackColor];
        self.strokeWidth = 1.0f;
        self.userInfo = @{};
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LWTextStroke* stroke = [[LWTextStroke alloc] init];
    stroke.strokeColor = [self.strokeColor copy];
    stroke.range = self.range;
    stroke.userInfo = [self.userInfo copy];
    stroke.strokeWidth = self.strokeWidth;
    return stroke;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
    [aCoder encodeObject:self.strokeColor forKey:@"strokeColor"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeFloat:self.strokeWidth forKey:@"strokeWidth"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.range = [[aDecoder decodeObjectForKey:@"range"] rangeValue];
        self.strokeColor = [aDecoder decodeObjectForKey:@"strokeColor"];
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        self.strokeWidth = [aDecoder decodeFloatForKey:@"strokeWidth"];
    }
    return self;
}

@end






/**
 *  文本边框
 */

@implementation LWTextBoundingStroke

- (id)init {
    self = [super init];
    if (self) {
        self.range = NSMakeRange(0, 0);
        self.strokeColor = [UIColor clearColor];
        self.userInfo = @{};
        self.positions = @[];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LWTextBoundingStroke* stroke = [[LWTextBoundingStroke alloc] init];
    stroke.strokeColor = [self.strokeColor copy];
    stroke.range = self.range;
    stroke.userInfo = [self.userInfo copy];
    stroke.positions = [self.positions copy];
    return stroke;
}
- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSValue valueWithRange:self.range] forKey:@"range"];
    [aCoder encodeObject:self.strokeColor forKey:@"strokeColor"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeObject:self.positions forKey:@"positions"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.range = [[aDecoder decodeObjectForKey:@"range"] rangeValue];
        self.strokeColor = [aDecoder decodeObjectForKey:@"strokeColor"];
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        self.positions = [aDecoder decodeObjectForKey:@"positions"];
    }
    return self;
}

@end


