//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//  Created by 刘微 on 16/3/7.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//


#import "LWRunLoopTransactions.h"


@interface LWRunLoopTransactions ()

@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) id object;

@end


static NSMutableSet* transactionSet = nil;

static void RunLoopObserverCallBack(CFRunLoopObserverRef observer,
                                    CFRunLoopActivity activity,
                                    void *info) {
    if (transactionSet.count == 0) return;
    NSSet* currentSet = transactionSet;
    transactionSet = [[NSMutableSet alloc] init];
    [currentSet enumerateObjectsUsingBlock:^(LWRunLoopTransactions* transactions, BOOL* stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [transactions.target performSelector:transactions.selector withObject:transactions.object];
#pragma clang diagnostic pop
    }];
}

static void RunLoopTransactionsSetup() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [[NSMutableSet alloc] init];
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,
                                           0xFFFFFF,
                                           RunLoopObserverCallBack, NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
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
    transactions.object = object;
    return transactions;
}

- (void)commit {
    if (!_target || !_selector) {
        return;
    }
    RunLoopTransactionsSetup();
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
