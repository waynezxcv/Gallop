//
//  LWFlag.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWFlag : NSObject

/**
 *  获取当前Flag的值
 */
@property (atomic,assign,readonly) int32_t value;


/**
 *  Flag的值+1
 */
- (int32_t)increase;

@end
