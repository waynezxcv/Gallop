//
//  LWAsyncDisplayView.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWAsyncDisplayView.h"

@implementation LWAsyncDisplayView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}


- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [self asyncDisplay];
}

- (void)asyncDisplay {
    LWAsyncDisplayTask* task = [self.delegate newAsyncDisplayTask];
    if (task.willDisplay) {
        task.willDisplay(self.layer);
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, ![self.backgroundColor isEqual:[UIColor clearColor]], 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == NULL) {
            return;
        }
        if (![self.backgroundColor isEqual:[UIColor clearColor]]) {
            [self.backgroundColor set];
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height));
        }
        if (task.display) {
            task.display(context,self.bounds.size);
        }

        UIImage* screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (task.didDisplay) {
                task.didDisplay(self.layer,YES);
            }
            //            self.layer.contents = (__bridge id)screenshotImage.CGImage;
            LWTransaction* transaction = [LWTransaction transactionWithTarget:self.layer
                                                                     selector:@selector(setContents:)
                                                                   withObject:(__bridge id)screenshotImage.CGImage];
            [transaction commit];
        });
    });
}



@end


@implementation LWAsyncDisplayTask


@end




@interface LWTransaction()
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic,strong) id object;
@end

static NSMutableSet *transactionSet = nil;

static void YYRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    if (transactionSet.count == 0) return;
    NSSet *currentSet = transactionSet;
    transactionSet = [NSMutableSet new];
    [currentSet enumerateObjectsUsingBlock:^(LWTransaction *transaction, BOOL *stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [transaction.target performSelector:transaction.selector withObject:transaction.object];
#pragma clang diagnostic pop
    }];
}

static void LWTransactionSetup() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [NSMutableSet new];
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,
                                           0xFFFFFF,
                                           YYRunLoopObserverCallBack, NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}


@implementation LWTransaction

+ (LWTransaction *)transactionWithTarget:(id)target selector:(SEL)selector withObject:(id)object{
    if (!target || !selector) return nil;
    LWTransaction *t = [LWTransaction new];
    t.target = target;
    t.selector = selector;
    t.object = object;
    return t;
}

- (void)commit {
    if (!_target || !_selector || !_object) return;
    LWTransactionSetup();
    [transactionSet addObject:self];
}

- (NSUInteger)hash {
    long v1 = (long)((void *)_selector);
    long v2 = (long)_target;
    return v1 ^ v2;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isMemberOfClass:self.class]) return NO;
    LWTransaction *other = object;
    return other.selector == _selector && other.target == _target;
}

@end

