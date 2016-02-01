//
//  LWRunLoopObserver.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWRunLoopObserver : NSObject


/**
 *  创建LWRunLoopObserver实例
 */
+ (LWRunLoopObserver *)observerWithTarget:(id)target
                                 selector:(SEL)selector
                                   object:(id)object;

/**
 *  提交事件，开始执行
 */
- (void)commit;

@end
