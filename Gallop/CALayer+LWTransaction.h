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


#import <UIKit/UIKit.h>
#import "LWTransaction.h"

/**
 *  这个扩展给CALayer添加一个哈希表，用来保存这个CALayer上的LWTransaction对象
 *
 */



typedef NS_ENUM(NSUInteger, LWTransactionContainerState) {
    /**
     *  没有操作需要处理
     */
    LWTransactionContainerStateNoTransactions,
    /**
     *  正在处理操作
     */
    LWTransactionContainerStatePendingTransactions,
};


@protocol LWTransactionContainerDelegate

@property (nonatomic,readonly,assign) LWTransactionContainerState transactionContainerState;//操作事务容器的状态

/**
 *  取消这个容器CALayer上的所有事务,如果这个事务已经在执行了，则执行完
 */
- (void)lw_cancelAsyncTransactions;

/**
 *  操作事务容器的状态改变时回调
 */
- (void)lw_asyncTransactionContainerStateDidChange;

@end


/**
 *  LWTransaction对象是通过runloop的observer观察到退出一个runloop和runloop即将进入休眠时
 *  需要执行的操作的抽象。这是LWTransaction对CALayer的扩展
 */
@interface CALayer(LWTransaction)<LWTransactionContainerDelegate>

@property (nonatomic,strong) NSHashTable* transactions;//这个CALayer对象上的操作事务哈希表
@property (nonatomic,strong) LWTransaction* currentTransaction;//当前正在处理的事务
@property (nonatomic,readonly,strong) LWTransaction* lw_asyncTransaction;//创建一个LWTransaction并添加到transactions当中

- (void)lw_transactionContainerWillBeginTransaction:(LWTransaction *)transaction;//即将要开始处理一个LWTransaction
- (void)lw_transactionContainerrDidCompleteTransaction:(LWTransaction *)transaction;//LWTransaction处理完成


@end
