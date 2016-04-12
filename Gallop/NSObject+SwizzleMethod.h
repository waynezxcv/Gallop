//
//  NSObject+SwizzleMethod.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/12.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(SwizzleMethod)

+ (void)swizzleMethod:(SEL)origSel withMethod:(SEL)aftSel;

@end
