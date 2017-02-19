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

#import "CALayer+LWTransaction.h"
#import "LWTransaction.h"
#import "LWTransactionGroup.h"
#import <objc/runtime.h>


static void* LWTransactionsKey = @"LWTransactionsKey";
static void* LWCurrentTransacitonKey = @"LWCurrentTransacitonKey";

@implementation CALayer(LWTransaction)

#pragma mark - Associations
- (void)setTransactions:(NSHashTable *)transactions {
    objc_setAssociatedObject(self, LWTransactionsKey, transactions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSHashTable *)transactions {
    return objc_getAssociatedObject(self, LWTransactionsKey);
}

- (void)setCurrentTransaction:(LWTransaction *)currentTransaction {
    objc_setAssociatedObject(self, LWCurrentTransacitonKey, currentTransaction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LWTransaction *)currentTransaction {
    return  objc_getAssociatedObject(self, LWCurrentTransacitonKey);
}

- (LWTransactionContainerState)transactionContainerState {
    return ([self.transactions count] == 0) ? LWTransactionContainerStateNoTransactions : LWTransactionContainerStatePendingTransactions;
}

- (void)lw_transactionContainerWillBeginTransaction:(LWTransaction *)transaction {
    
}
- (void)lw_transactionContainerrDidCompleteTransaction:(LWTransaction *)transaction {
    
}

- (void)lw_cancelAsyncTransactions {
    LWTransaction* currentTransaction = self.currentTransaction;
    [currentTransaction commit];
    self.currentTransaction = nil;
    for (LWTransaction* transaction in [self.transactions copy]) {
        [transaction cancel];
    }
}

- (void)lw_asyncTransactionContainerStateDidChange {
    id delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(lw_asyncTransactionContainerStateDidChange)]) {
        [delegate lw_asyncTransactionContainerStateDidChange];
    }
}

- (LWTransaction *)lw_asyncTransaction {
    LWTransaction* transaction = self.currentTransaction;
    if (transaction == nil) {
        NSHashTable* transactions = self.transactions;
        if (transactions == nil) {
            transactions = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
            self.transactions = transactions;
        }
        
        transaction = [[LWTransaction alloc] initWithCallbackQueue:dispatch_get_main_queue()
                                                   completionBlock:^(LWTransaction *completeTransaction, BOOL isCancelled) {
                                                       [transactions removeObject:completeTransaction];
                                                       [self lw_transactionContainerrDidCompleteTransaction:completeTransaction];
                                                       if ([transactions count] == 0) {
                                                           [self lw_asyncTransactionContainerStateDidChange];
                                                       }
                                                   }];
        [transactions addObject:transaction];
        self.currentTransaction = transaction;
        [self lw_transactionContainerWillBeginTransaction:transaction];
        if ([transactions count] == 1) {
            [self lw_asyncTransactionContainerStateDidChange];
        }
    }
    [[LWTransactionGroup mainTransactionGroup] addTransactionContainer:self];
    return transaction;
}

@end
