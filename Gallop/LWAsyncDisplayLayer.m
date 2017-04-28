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

#import "LWAsyncDisplayLayer.h"
#import "GallopUtils.h"
#import "LWTransactionGroup.h"
#import "LWTransaction.h"
#import "CALayer+LWTransaction.h"
#import "LWFlag.h"


@interface LWAsyncDisplayLayer ()

@property (nonatomic,strong) LWFlag* displayFlag;


@end


@implementation LWAsyncDisplayLayer


#pragma mark -

+ (dispatch_queue_t)displayQueue {
    static dispatch_queue_t displayQueue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        displayQueue = dispatch_queue_create("com.Gallop.LWAsyncDisplayLayer.displayQueue",
                                             DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_set_target_queue(displayQueue,
                                  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0));
    });
    return displayQueue;
}

+ (id)defaultValueForKey:(NSString *)key {
    if ([key isEqualToString:@"displaysAsynchronously"]) {
        return @YES;
    } else {
        return [super defaultValueForKey:key];
    }
}

#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    if (self) {
        _displayFlag = [[LWFlag alloc] init];
        self.opaque = YES;
        self.displaysAsynchronously = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _displayFlag = [[LWFlag alloc] init];
        self.opaque = YES;
        self.displaysAsynchronously = YES;
    }
    return self;
}

- (void)setNeedsDisplay {
    [self cancelAsyncDisplay];
    [super setNeedsDisplay];
}


- (void)display {
    [self _hackResetNeedsDisplay];
    [self display:self.displaysAsynchronously];
}

- (void)_hackResetNeedsDisplay {
    super.contents = super.contents;
}

- (void)displayImmediately {
    [_displayFlag increment];
    [self display:NO];
}

- (void)dealloc {
    [self.displayFlag increment];
}

#pragma mark - Display


- (void)display:(BOOL)asynchronously {
    
    
    __strong id <LWAsyncDisplayLayerDelegate> delegate = (id) self.delegate;
    LWAsyncDisplayTransaction* transaction = [delegate asyncDisplayTransaction];
    if (!transaction.displayBlock) {
        if (transaction.willDisplayBlock) {
            transaction.willDisplayBlock(self);
        }
        
        CGImageRef imageRef = (__bridge_retained CGImageRef)(self.contents);
        id contents = self.contents;
        self.contents = nil;
        if (imageRef) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [contents class];
                CFRelease(imageRef);
            });
        }
        
        if (transaction.didDisplayBlock) {
            transaction.didDisplayBlock(self, YES);
        }
        return;
    }
    
    //清除之前的内容
    CGImageRef imageRef = (__bridge_retained CGImageRef)(self.contents);
    id contents = self.contents;
    self.contents = nil;
    if (imageRef) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [contents class];
            CFRelease(imageRef);
        });
    }
    
    
    //把内容尽可能多的绘制在同一个CALayer上，然后赋值给contents
    if (asynchronously) {
        if (transaction.willDisplayBlock) {
            transaction.willDisplayBlock(self);
        }
        
        
        LWFlag* displayFlag = _displayFlag;
        int32_t value = displayFlag.value;
        
        LWAsyncDisplayIsCanclledBlock isCancelledBlock = ^BOOL() {
            return value != displayFlag.value;
        };
        
        CGSize size = self.bounds.size;
        BOOL opaque = self.opaque;
        CGFloat scale = self.contentsScale;
        CGColorRef backgroundColor = (opaque && self.backgroundColor) ?
        CGColorRetain(self.backgroundColor) : NULL;
        
        if (size.width < 1 || size.height < 1) {
            CGImageRef image = (__bridge_retained CGImageRef)(self.contents);
            self.contents = nil;
            if (image) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    CFRelease(image);
                });
            }
            if (transaction.didDisplayBlock) {
                transaction.didDisplayBlock(self, YES);
            }
            CGColorRelease(backgroundColor);
            return;
        }
        
        dispatch_async([LWAsyncDisplayLayer displayQueue], ^{
            if (isCancelledBlock()) {
                CGColorRelease(backgroundColor);
                return;
            }
            UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
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
            transaction.displayBlock(context, size, isCancelledBlock);
            if (isCancelledBlock()) {
                UIGraphicsEndImageContext();
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (transaction.didDisplayBlock) {
                        transaction.didDisplayBlock(self, NO);
                    }
                });
                return;
            }
            
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (isCancelledBlock()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (transaction.didDisplayBlock) {
                        transaction.didDisplayBlock(self, NO);
                    }
                });
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __weak typeof(self) weakSelf = self;
                LWTransaction* layerAsyncTransaction = self.lw_asyncTransaction;
                [layerAsyncTransaction addAsyncOperationWithTarget:self
                                                          selector:@selector(setContents:)
                                                            object:(__bridge id)(image.CGImage)
                                                        completion:^(BOOL canceled) {
                                                            __strong typeof(weakSelf) swself = weakSelf;
                                                            if (canceled) {
                                                                if (transaction.didDisplayBlock) {
                                                                    transaction.didDisplayBlock(swself,NO);
                                                                }
                                                            } else {
                                                                if (transaction.didDisplayBlock) {
                                                                    transaction.didDisplayBlock(swself,YES);
                                                                }
                                                            }
                                                        }];
            });
        });
        
    } else {
        
        if (transaction.willDisplayBlock) {
            transaction.willDisplayBlock(self);
        }
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, self.contentsScale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (self.opaque) {
            CGSize size = self.bounds.size;
            size.width *= self.contentsScale;
            size.height *= self.contentsScale;
            CGContextSaveGState(context); {
                if (!self.backgroundColor || CGColorGetAlpha(self.backgroundColor) < 1) {
                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                    CGContextFillPath(context);
                }
                if (self.backgroundColor) {
                    CGContextSetFillColorWithColor(context, self.backgroundColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                    CGContextFillPath(context);
                }
            } CGContextRestoreGState(context);
        }
        
        
        transaction.displayBlock(context, self.bounds.size, ^{return NO;});
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contents = (__bridge id)(image.CGImage);
        if (transaction.didDisplayBlock) {
            transaction.didDisplayBlock(self, YES);
        }
    }
}

- (void)cancelAsyncDisplay {
    [self.displayFlag increment];
}


@end


@implementation LWAsyncDisplayTransaction

@end

