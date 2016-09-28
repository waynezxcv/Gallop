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

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LWTextAttachment* attachment = [[LWTextAttachment alloc] init];
    
    if ([self.content conformsToProtocol:@protocol(NSCopying)]) {
        attachment.content = [self.content copy];
    }
    else {
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
    }
    return self;
}

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
    return highlight;
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


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LWTextBackgroundColor* bgColor = [[LWTextBackgroundColor alloc] init];
    bgColor.backgroundColor = [self.backgroundColor copy];
    bgColor.range = self.range;
    bgColor.userInfo = [self.userInfo copy];
    bgColor.positions = [self.positions copy];
    return bgColor;
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

@end


