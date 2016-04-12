//
//  NSObject+SwizzleMethod.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/12.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "NSObject+SwizzleMethod.h"
#import "objc/runtime.h"

@implementation NSObject(SwizzleMethod)

+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)aftSel {
    Method originMethod = class_getInstanceMethod(self, origSel);
    Method newMethod = class_getInstanceMethod(self, aftSel);
    if(originMethod && newMethod) {
        if(class_addMethod(self, origSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            class_replaceMethod(self, aftSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        }
        return YES;
    }
    return NO;
}


@end
