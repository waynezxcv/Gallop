//
//  LWRunLoopObserver.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Wayne. All rights reserved.
//



#import "LWRunLoopObserver.h"


@interface LWRunLoopObserver()

@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) id object;

@end

static NSMutableSet* transactionSet = nil;

static void LWRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    if (transactionSet.count == 0) return;
    NSSet *currentSet = transactionSet;
    transactionSet = [[NSMutableSet alloc] init];
    [currentSet enumerateObjectsUsingBlock:^(LWRunLoopObserver* observer, BOOL* stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [observer.target performSelector:observer.selector withObject:observer.object];
#pragma clang diagnostic pop
    }];
}

static void LWRunLoopObserverSetup() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [[NSMutableSet alloc] init];
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,
                                           0xFFFFFF,
                                           LWRunLoopObserverCallBack, NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}

@implementation LWRunLoopObserver

+ (LWRunLoopObserver *)observerWithTarget:(id)target
                                 selector:(SEL)selector
                                   object:(id)object {
    if (!target || !selector) {
        return nil;
    }
    LWRunLoopObserver* observer = [[LWRunLoopObserver alloc] init];
    observer.target = target;
    observer.selector = selector;
    observer.object = object;
    return observer;
}


- (void)commit {
    if (!_target || !_selector) {
        return;
    }
    LWRunLoopObserverSetup();
    [transactionSet addObject:self];
}

- (NSUInteger)hash {
    long v1 = (long)((void *)_selector);
    long v2 = (long)_target;
    return v1 ^ v2;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isMemberOfClass:self.class]){
        return NO;
    }
    LWRunLoopObserver* other = object;
    return other.selector == _selector && other.target == _target;
}

@end
