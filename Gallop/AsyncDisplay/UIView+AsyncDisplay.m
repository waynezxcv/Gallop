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


#import "UIView+AsyncDisplay.h"
#import "LWRunLoopTransactions.h"

@implementation UIView(AsyncDisplay)

- (void)lw_asyncDisplay:(LWAsyncDisplayBlock)displayBlock complete:(LWAsyncDisplayCompleteBlock)completeBlock {
    __weak typeof(self) weakSelf=  self;
    [LWAsyncDisplayManager.sharedManager displayWithDisplaySize:self.layer.bounds.size
                                                         opaque:self.layer.opaque
                                                  contentsScale:[UIScreen mainScreen].scale
                                                backgroundColor:self.backgroundColor
                                                   asyncDisplay:displayBlock
                                                     completion:^(id displayContent, BOOL isFinished) {
                                                         completeBlock(displayContent,isFinished);
                                                         if (isFinished) {
                                                             __strong typeof(weakSelf) strongWeakSelf = weakSelf;
                                                             strongWeakSelf.layer.contents = displayContent;
                                                         }
                                                     }];
}

- (void)lw_addDisplayTransactionsWithasyncDisplay:(LWAsyncDisplayBlock)displayBlock complete:(LWAsyncDisplayCompleteBlock)completeBlock {
    [[LWRunLoopTransactions transactionsWithTarget:self
                                          selector:@selector(_commitAsyncDisplayTransactionWithDisplayBlock:complete:)
                                           object1:displayBlock
                                           object2:completeBlock] commit];
}

- (void)_commitAsyncDisplayTransactionWithDisplayBlock:(LWAsyncDisplayBlock)displayBlock complete:(LWAsyncDisplayCompleteBlock)completeBlock {
    __weak typeof(self) weakSelf=  self;
    [LWAsyncDisplayManager.sharedManager displayWithDisplaySize:self.layer.bounds.size
                                                         opaque:self.layer.opaque
                                                  contentsScale:self.layer.contentsScale
                                                backgroundColor:self.backgroundColor
                                                   asyncDisplay:displayBlock
                                                     completion:^(id displayContent, BOOL isFinished) {
                                                         completeBlock(displayContent,isFinished);
                                                         if (isFinished) {
                                                             __strong typeof(weakSelf) strongWeakSelf = weakSelf;
                                                             strongWeakSelf.layer.contents = displayContent;
                                                         }
                                                     }];
}


@end
