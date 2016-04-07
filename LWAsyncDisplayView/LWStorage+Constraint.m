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
    LWConstraint* constraint = [self cacheConstraint];
    if (constraint) {
        return constraint;
    }
    constraint = [[LWConstraint alloc] init];
    self.cacheConstraint = constraint;
    return constraint;
}

- (LWConstraint *)cacheConstraint {
    return objc_getAssociatedObject(self, LWConstraintCacheKey);
}

- (void)setCacheConstraint:(LWConstraint *)cacheConstraint {
    objc_setAssociatedObject(self,LWConstraintCacheKey, cacheConstraint, OBJC_ASSOCIATION_RETAIN);
}


- (void)autoLayout {
//    NSLog(@"autoLayout %f",self.constraint.leftObject.value);
}

@end
