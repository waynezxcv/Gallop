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
 *  这个类用于管理所有transactions<LWTransaction *>容器不为空的CALayer对象
 *  LWTransactionGroup把这些CALayer对象放在一个哈希表layersContainers中
 *  LWTransactionGroup注册了一个主线程的runLoopObserver，当状态为(kCFRunLoopBeforeWaiting | kCFRunLoopExit)时，
 *  LWTransactionGroup会遍历layersContainers，来对这些CALayer上的所有LWTransactions执行 commit
 */
@interface LWTransactionGroup : NSObject

/**
 *  获取主线程CFRunLoopObserverRef，注册观察时间点并返回封装后的LWTransactionGroup对象
 *
 *  @return 一个LWTransactionGroup对象
 */
+ (LWTransactionGroup *)mainTransactionGroup;

/**
 *  将一个包含LWTransaction事物的CALayer添加到LWTransactionGroup
 *
 *  @param containerLayer CALayer容器
 */
- (void)addTransactionContainer:(CALayer *)containerLayer;

/**
 *  提交mainTransactionGroup当中所有容器中的所有任务的操作
 *
 */
+ (void)commit;

@end
