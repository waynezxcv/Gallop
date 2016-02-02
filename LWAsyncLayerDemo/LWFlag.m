//
//  LWFlag.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWFlag.h"
#import <libkern/OSAtomic.h>


@interface LWFlag ()

@property (atomic,assign,readwrite) int32_t value;

@end


@implementation LWFlag


@synthesize value = _value;

- (int32_t)value {
    return _value;
}

- (void)setValue:(int32_t)value {
    _value = value;
}

- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}

@end
