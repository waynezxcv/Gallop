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

LWSERIALIZE_CODER_DECODER();


#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    LWTextRunDelegate* delegate = [[[self class] allocWithZone:zone] init];
    delegate.ascent = self.ascent;
    delegate.descent = self.descent;
    delegate.width = self.width;
    delegate.userInfo = [self.userInfo copy];
    return delegate;
}

@end
