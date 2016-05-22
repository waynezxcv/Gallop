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



#import "GallopUtils.h"
#import <libkern/OSAtomic.h>
#import "objc/runtime.h"

@implementation GallopUtils

+ (CGFloat)contentsScale {
    static dispatch_once_t once;
    static CGFloat contentsScale;
    dispatch_once(&once, ^{
        contentsScale = [UIScreen mainScreen].scale;
    });
    return contentsScale;
}

@end


@implementation LWFlag {
    int32_t _value;
}

- (int32_t)value {
    return _value;
}

- (int32_t)increment {
    return OSAtomicIncrement32(&_value);
}

@end


@implementation NSObject(SwizzleMethod)

+ (void)swizzleMethod:(SEL)origSel withMethod:(SEL)aftSel {
    Method originMethod = class_getInstanceMethod(self, origSel);
    Method newMethod = class_getInstanceMethod(self, aftSel);
    if(originMethod && newMethod) {
        method_exchangeImplementations(originMethod, newMethod);
    }
}


@end


