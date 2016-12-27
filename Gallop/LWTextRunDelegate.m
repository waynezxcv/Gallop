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

#import "LWTextRunDelegate.h"
#import <objc/runtime.h>
#import "GallopUtils.h"


static void LWTextDeallocCallback(void *ref);
static CGFloat LWTextAscentCallback(void *ref);
static CGFloat LWTextDescentCallback(void *ref);
static CGFloat LWTextWidthCallback(void *ref);


@implementation LWTextRunDelegate

#pragma mark - Getter
- (CTRunDelegateRef)CTRunDelegate {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks,0,sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.dealloc = LWTextDeallocCallback;
    callbacks.getAscent = LWTextAscentCallback;
    callbacks.getDescent = LWTextDescentCallback;
    callbacks.getWidth = LWTextWidthCallback;
    return CTRunDelegateCreate(&callbacks, (__bridge_retained void *)([self copy]));
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        self.ascent = [aDecoder decodeFloatForKey:@"ascent"];
        self.descent = [aDecoder decodeFloatForKey:@"descent"];
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.height = [aDecoder decodeFloatForKey:@"height"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeFloat:self.ascent forKey:@"ascent"];
    [aCoder encodeFloat:self.descent forKey:@"descent"];
    [aCoder encodeFloat:self.width forKey:@"width"];
    [aCoder encodeFloat:self.height forKey:@"height"];
}


#pragma mark - NSCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    LWTextRunDelegate* delegate = [[[self class] alloc] init];
    delegate.ascent = self.ascent;
    delegate.descent = self.descent;
    delegate.width = self.width;
    delegate.height = self.height;
    delegate.userInfo = [self.userInfo copy];
    return delegate;
}

@end

static void LWTextDeallocCallback(void *ref) {
    LWTextRunDelegate* self = (__bridge_transfer LWTextRunDelegate *)(ref);
    self = nil;
}

static CGFloat LWTextAscentCallback(void *ref) {
    LWTextRunDelegate* self = (__bridge LWTextRunDelegate *)(ref);
    return self.ascent;
}

static CGFloat LWTextDescentCallback(void *ref) {
    LWTextRunDelegate* self = (__bridge LWTextRunDelegate *)(ref);
    return self.descent;
}

static CGFloat LWTextWidthCallback(void *ref) {
    LWTextRunDelegate* self = (__bridge LWTextRunDelegate *)(ref);
    return self.width;
}
