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


#import "LWAsyncDisplayOperation.h"


#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface LWAsyncDisplayOperation ()

@property (nonatomic,copy) LWAsyncDisplayBlock displayBlock;
@property (nonatomic,copy) LWAsyncDisplayCompleteBlock completeBlock;

@property (nonatomic,readwrite,getter=isExecuting) BOOL executing;
@property (nonatomic,readwrite,getter=isFinished) BOOL finished;

@property (nonatomic,strong) NSThread* thread;
@property (nonatomic,assign) CGSize size;
@property (nonatomic,assign) BOOL opaque;
@property (nonatomic,assign) CGFloat contentsScale;
@property (nonatomic,strong) UIColor* backgroundColor;

@end

@implementation LWAsyncDisplayOperation {
    dispatch_semaphore_t _lock;
}

@synthesize executing = _executing;
@synthesize finished = _finished;


- (LWAsyncDisplayOperation *)initWithDisplaySize:(CGSize)size
                                          opaque:(BOOL)opaque
                                 backgroundColor:(UIColor *)backgroundColor
                                   contentsScale:(CGFloat)contentsScale
                                    asyncDisplay:(LWAsyncDisplayBlock)display
                                      completion:(LWAsyncDisplayCompleteBlock)completion {
    self = [super init];
    if (self) {
        self.displayBlock = [display copy];
        self.completeBlock = [completion copy];
        self.size = size;
        self.opaque = opaque;
        self.contentsScale = contentsScale;
        self.executing = NO;
        self.finished = NO;
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - Override
- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (self.isCancelled) {
        self.finished = YES;
        [self reset];
        return;
    }
    self.executing = YES;
    self.thread = [NSThread currentThread];
    [self.thread setName:@"LWAsyncDisplayThread"];
    dispatch_semaphore_signal(_lock);
    CGSize size = self.size;
    BOOL opaque = self.opaque;
    CGFloat scale = self.contentsScale;
    CGColorRef backgroundColor = (opaque && self.backgroundColor.CGColor) ?
    CGColorRetain(self.backgroundColor.CGColor) : NULL;
    if (size.width < 1 || size.height < 1) {
        CGColorRelease(backgroundColor);
        dispatch_main_async_safe(^{
            if (self.completeBlock) {
                self.completeBlock(nil,NO);
            }
        });
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        [self done];
        dispatch_semaphore_signal(_lock);
        return;
    }
    UIGraphicsBeginImageContextWithOptions(size,opaque,scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        CGColorRelease(backgroundColor);
        UIGraphicsEndImageContext();
        dispatch_main_async_safe(^{
            if (self.completeBlock) {
                self.completeBlock(nil,NO);
            }
        });
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        [self done];
        dispatch_semaphore_signal(_lock);
        return;
    }
    if (opaque) {
        CGContextSaveGState(context); {
            if (!backgroundColor || CGColorGetAlpha(backgroundColor) < 1) {
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                CGContextFillPath(context);
            }
            if (backgroundColor) {
                CGContextSetFillColorWithColor(context, backgroundColor);
                CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                CGContextFillPath(context);
            }
        } CGContextRestoreGState(context);
        CGColorRelease(backgroundColor);
    }
    if (self.displayBlock) {
        self.displayBlock(context,size);
    }
    id content = (__bridge id _Nullable)(UIGraphicsGetImageFromCurrentImageContext().CGImage);
    UIGraphicsEndImageContext();
    dispatch_main_sync_safe(^{
        if (self.completeBlock) {
            self.completeBlock(content,YES);
        }
    });
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [self done];
    dispatch_semaphore_signal(_lock);
}

#pragma mark -

- (void)cancel {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (self.thread) {
        [self performSelector:@selector(cancelInternalAndStop)
                     onThread:self.thread
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [self cancelInternal];
    }
    dispatch_semaphore_signal(_lock);
}

- (void)cancelInternalAndStop {
    if (self.isFinished){
        return;
    }
    [self cancelInternal];
}

- (void)cancelInternal {
    if (self.isFinished) {
        return;
    }
    [super cancel];
    if (self.isExecuting){
        self.executing = NO;
    }
    if (!self.isFinished) {
        self.finished = YES;
    }
    [self reset];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}


- (void)reset {
    self.thread = nil;
    self.size = CGSizeZero;
    self.opaque = YES;
    self.contentsScale = 0.0f;
    self.displayBlock = nil;
    self.completeBlock = nil;
}


#pragma mark - Setter

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}


- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}


@end
