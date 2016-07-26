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
 *  一个全局的对象，用于管理当前所有的LWTransaction,对CFRunLoopObserverRef的封装
 */
@interface LWTransactionGroup : NSObject

/**
 *  获取主线程CFRunLoopObserverRef，注册观察时间点并返回封装后的LWTransactionGroup对象
 *
 *  @return 一个LWTransactionGroup对象
 */
+ (id)mainTransactionGroup;

/**
 *  一个LWTransaction的CALayer容器添加到LWTransactionGroup
 *
 *  @param containerLayer CALayer容器
 */
- (void)addTransactionContainer:(CALayer *)containerLayer;

/**
 *  提交mainTransactionGroup当中所有容器中的所有任务的操作
 *  mainTransactionGroup->containerLayer->LWTrasactions->LWTrasaction->operaiton
 */
+ (void)commit;

@end
