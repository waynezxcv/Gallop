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

#import "LWTransaction.h"
#import "LWTransactionGroup.h"
#import <objc/message.h>



@interface LWAsyncDisplayTransactionOperation : NSObject

@property (nonatomic,strong) id target;
@property (nonatomic,assign) SEL selector;
@property (nonatomic,strong) id object;
@property (nonatomic,copy) LWAsyncTransactionOperationCompletionBlock completion;

- (id)initWithCompletion:(LWAsyncTransactionOperationCompletionBlock)completion;
- (void)callAndReleaseCompletionBlock:(BOOL)canceled;


@end

@implementation LWAsyncDisplayTransactionOperation


- (id)initWithCompletion:(LWAsyncTransactionOperationCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.completion = [completion copy];
    }
    return self;
}

- (void)callAndReleaseCompletionBlock:(BOOL)canceled {
    void (*objc_msgSendToPerform)(id, SEL, id) = (void*)objc_msgSend;
    objc_msgSendToPerform(self.target,self.selector,self.object);
    if (self.completion) {
        self.completion(canceled);
        self.completion = nil;
    }
    self.target = nil;
    self.selector = nil;
    self.object = nil;
}

@end


@interface LWTransaction ()

@property (nonatomic,strong) dispatch_queue_t callbackQueue;
@property (nonatomic,copy) LWAsyncTransactionCompletionBlock completionBlock;
@property (nonatomic,assign) LWAsyncTransactionState state;
@property (nonatomic,strong) NSMutableArray* operations;

@end


@implementation LWTransaction

#pragma mark - LifeCycle

- (LWTransaction *)initWithCallbackQueue:(dispatch_queue_t)callbackQueue
            completionBlock:(LWAsyncTransactionCompletionBlock)completionBlock {
    if ((self = [self init])) {
        if (callbackQueue == NULL) {
            callbackQueue = dispatch_get_main_queue();
        }
        self.callbackQueue = callbackQueue;
        self.completionBlock = [completionBlock copy];
        self.state = LWAsyncTransactionStateOpen;
    }
    return self;
}

#pragma mark - Methods

- (void)addAsyncOperationWithTarget:(id)target
                           selector:(SEL)selector
                             object:(id)object
                         completion:(LWAsyncTransactionOperationCompletionBlock)operationComletion {
    LWAsyncDisplayTransactionOperation* operation = [[LWAsyncDisplayTransactionOperation alloc]
                                                     initWithCompletion:operationComletion];
    operation.target = target;
    operation.selector = selector;
    operation.object = object;
    [self.operations addObject:operation];
}

- (void)cancel {
    self.state = LWAsyncTransactionStateCanceled;
}

- (void)commit {
    self.state = LWAsyncTransactionStateCommitted;
    if ([_operations count] == 0) {
        if (_completionBlock) {
            _completionBlock(self, NO);
        }
    } else {
        [self completeTransaction];
    }
}

- (void)completeTransaction {
    if (_state != LWAsyncTransactionStateComplete) {
        BOOL isCanceled = (_state == LWAsyncTransactionStateCanceled);
        for (LWAsyncDisplayTransactionOperation* operation in self.operations) {
            [operation callAndReleaseCompletionBlock:isCanceled];
        }
        self.state = LWAsyncTransactionStateComplete;
        if (_completionBlock) {
            _completionBlock(self, isCanceled);
        }
    }
}

#pragma mark - Getter
- (NSMutableArray *)operations {
    if (_operations) {
        return _operations;
    }
    _operations = [[NSMutableArray alloc] init];
    return _operations;
}

@end



