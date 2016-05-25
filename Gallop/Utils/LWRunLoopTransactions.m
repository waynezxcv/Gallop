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

#import "LWRunLoopTransactions.h"


@interface LWRunLoopTransactions ()

@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) id object1;
@property (nonatomic, strong) id object2;

@end


static NSMutableSet* transactionSet = nil;

static void RunLoopObserverCallBack(CFRunLoopObserverRef observer,
                                    CFRunLoopActivity activity,
                                    void *info) {
    if (transactionSet.count == 0) {
        return;
    }
    NSSet* currentSet = transactionSet;
    transactionSet = [[NSMutableSet alloc] init];
    [currentSet enumerateObjectsUsingBlock:^(LWRunLoopTransactions* transactions, BOOL* stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [transactions.target performSelector:transactions.selector
                                  withObject:transactions.object1
                                  withObject:transactions.object2];
#pragma clang diagnostic pop
    }];
}

static void RegisterRunLoopTransactions() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [[NSMutableSet alloc] init];
        static CFRunLoopObserverRef observer;
        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        CFOptionFlags activities = (kCFRunLoopBeforeWaiting |
                                    kCFRunLoopExit);
        CFRunLoopObserverContext context = {
            0,           // version
            (__bridge void *)transactionSet,  // info
            &CFRetain,   // retain
            &CFRelease,  // release
            NULL         // copyDescription
        };
        observer = CFRunLoopObserverCreate(NULL,        // allocator
                                           activities,  // activities
                                           YES,         // repeats
                                           INT_MAX,     // order after CA transaction commits
                                           RunLoopObserverCallBack,  // callback
                                           &context);   // context
        CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}

@implementation LWRunLoopTransactions

+ (LWRunLoopTransactions *)transactionsWithTarget:(id)target
                                         selector:(SEL)selector
                                           object:(id)object {
    if (!target || !selector) {
        return nil;
    }
    LWRunLoopTransactions* transactions = [[LWRunLoopTransactions alloc] init];
    transactions.target = target;
    transactions.selector = selector;
    transactions.object1 = object;
    transactions.object2 = nil;
    return transactions;
}

+ (LWRunLoopTransactions *)transactionsWithTarget:(id)target
                                         selector:(SEL)selector
                                          object1:(id)object1
                                          object2:(id)object2 {
    if (!target || !selector) {
        return nil;
    }
    LWRunLoopTransactions* transactions = [[LWRunLoopTransactions alloc] init];
    transactions.target = target;
    transactions.selector = selector;
    transactions.object1 = object1;
    transactions.object2 = object2;
    return transactions;
}

- (void)commit {
    if (!_target || !_selector) {
        return;
    }
    RegisterRunLoopTransactions();
    [transactionSet addObject:self];
}

- (NSUInteger)hash {
    long v1 = (long)((void *)_selector);
    long v2 = (long)_target;
    return v1 ^ v2;
}

- (BOOL)isEqual:(id)object{
    if (self == object) {
        return YES;
    }
    if (![object isMemberOfClass:self.class]){
        return NO;
    }
    LWRunLoopTransactions* other = object;
    return other.selector == _selector && other.target == _target;
}

@end
