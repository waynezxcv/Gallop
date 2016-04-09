//
//  LWConstraintManager.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWStorage+Constraint.h"
#import <objc/runtime.h>

static void* LWConstraintCacheKey = &LWConstraintCacheKey;

@implementation LWStorage(Constraint)

- (LWConstraint *)constraint {
    LWConstraint* constraint;
    if (objc_getAssociatedObject(self, LWConstraintCacheKey)) {
        constraint = objc_getAssociatedObject(self, LWConstraintCacheKey);
        constraint.superStorage = self;
        return constraint;
    }
    constraint = [[LWConstraint alloc] init];
    objc_setAssociatedObject(self,LWConstraintCacheKey, constraint, OBJC_ASSOCIATION_RETAIN);
    constraint.superStorage = self;
    return constraint;
}

@end
