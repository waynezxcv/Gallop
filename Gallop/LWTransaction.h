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

#import <Foundation/Foundation.h>
#import "GallopUtils.h"


@class LWTransaction;

typedef void(^LWAsyncTransactionCompletionBlock)(LWTransaction* completeTransaction,BOOL isCancelled);
typedef void(^LWAsyncTransactionOperationCompletionBlock)(BOOL canceled);

/**
 *  LWAsyncTransaction事务的状态
 */
typedef NS_ENUM(NSUInteger, LWAsyncTransactionState) {
    /**
     *  开始处理一个事务
     */
    LWAsyncTransactionStateOpen = 0,
    /**
     *  提交一个事务
     */
    LWAsyncTransactionStateCommitted,
    /**
     *  事务取消
     */
    LWAsyncTransactionStateCanceled,
    /**
     *  事务完成
     */
    LWAsyncTransactionStateComplete
};


/**
 * LWTransaction封装了一个消息的接收者target、selecotr、和一个参数object
 */
@interface LWTransaction : NSObject


/**
 *  构造方法
 *
 *  @param callbackQueue   事务处理完成后会收到回调，这里可以指定回调所在的dispatch_queue_t
 *  @param completionBlock 事务处理完成回调Block
 *
 *  @return 一个LWTransaction对象
 */
- (LWTransaction *)initWithCallbackQueue:(dispatch_queue_t)callbackQueue
                         completionBlock:(LWAsyncTransactionCompletionBlock)completionBlock;

@property (nonatomic,strong,readonly) dispatch_queue_t callbackQueue;//回调所在的dispatch_queue_t
@property (nonatomic,copy,readonly) LWAsyncTransactionCompletionBlock completionBlock;//处理完成时回调的Block
@property (nonatomic,assign,readonly) LWAsyncTransactionState state;//事务状态


/**
 *  添加一个操作到LWTransaction
 *
 *  @param target             消息接收者
 *  @param selector           消息选择子
 *  @param object             消息参数
 *  @param operationComletion 操作完成回调
 */
- (void)addAsyncOperationWithTarget:(id)target
                           selector:(SEL)selector
                             object:(id)object
                         completion:(LWAsyncTransactionOperationCompletionBlock)operationComletion;

/**
 *  提交一个LWTransaction中的Operation
 */
- (void)commit;

/**
 *  取消一个LWTransaction当中的Operation
 */
- (void)cancel;

@end

