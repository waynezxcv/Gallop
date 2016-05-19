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


#import "LWAsyncDisplayManager.h"

@interface LWAsyncDisplayManager ()

@property (nonatomic,strong) NSOperationQueue* displayQueue;

@end

@implementation LWAsyncDisplayManager

+ (LWAsyncDisplayManager *)sharedManager {
    static dispatch_once_t once;
    static LWAsyncDisplayManager* instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSOperationQueue* displayQueue = [[NSOperationQueue alloc] init];
        self.displayQueue = displayQueue;
        self.maxConcurrentAsyncDisplayCount = 16;
        displayQueue.maxConcurrentOperationCount = self.maxConcurrentAsyncDisplayCount;
    }
    return self;
}

- (LWAsyncDisplayOperation *)displayWithDisplaySize:(CGSize)size
                                             opaque:(BOOL)opaque
                                      contentsScale:(CGFloat)contentsScale
                                    backgroundColor:(UIColor *)backgroundColor
                                       asyncDisplay:(LWAsyncDisplayBlock)display
                                         completion:(LWAsyncDisplayCompleteBlock)completion {

    LWAsyncDisplayOperation* operation = [[LWAsyncDisplayOperation alloc]
                                          initWithDisplaySize:size
                                          opaque:opaque
                                          backgroundColor:backgroundColor
                                          contentsScale:contentsScale
                                          asyncDisplay:display
                                          completion:completion];
    [self.displayQueue addOperation:operation];
    return operation;
}


#pragma mark - Getter & Setter

- (void)setMaxConcurrentAsyncDisplayCount:(NSInteger)maxConcurrentAsyncDisplayCount {
    _maxConcurrentAsyncDisplayCount = maxConcurrentAsyncDisplayCount;
    self.displayQueue.maxConcurrentOperationCount = self.maxConcurrentAsyncDisplayCount;
}

- (NSInteger) countOfCurrentAsyncDisplayCount {
    return self.displayQueue.operationCount;
}

@end
