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
        return constraint;
    }
    constraint = [[LWConstraint alloc] init];
    objc_setAssociatedObject(self,LWConstraintCacheKey, constraint, OBJC_ASSOCIATION_RETAIN);
    return constraint;
}


- (void)auotoLayout {
    if (self.constraint.left) {
        [self changeLeft:self.constraint.left];
    }
    if (self.constraint.right) {
        [self changeRight:self.constraint.right];
    }
    if (self.constraint.top) {
        [self changeTop:self.constraint.top];
    }
    if (self.constraint.bottom) {
        [self changeTop:self.constraint.bottom];
    }
    if (self.constraint.width) {
        [self changeWidth:self.constraint.width];
    }
    if (self.constraint.height) {
        [self changeHeight:self.constraint.height];
    }
    if (self.constraint.leftObject) {
        [self changeLeft:@(self.constraint.leftObject.referenceStorage.right + self.constraint.leftObject.value)];
    }
    if (self.constraint.rightObject) {
        [self changeRight:@(self.constraint.rightObject.referenceStorage.left - self.constraint.rightObject.value)];
    }
    if (self.constraint.topObject) {
        [self changeTop:@(self.constraint.topObject.referenceStorage.bottom + self.constraint.topObject.value)];
    }
    if (self.constraint.bottomObject) {
        [self changeTop:@(self.constraint.bottomObject.referenceStorage.top - self.constraint.bottomObject.value)];
    }
}

#pragma mark - ChangeFrame

- (void)changeLeft:(NSNumber *)left {
    CGRect frame = self.frame;
    frame.origin.x = [left floatValue];
    self.frame = frame;
}

- (void)changeRight:(NSNumber *)right {
    CGRect frame = self.frame;
    frame.origin.x = [right floatValue] - frame.size.width;
    self.frame = frame;
}

- (void)changeTop:(NSNumber *)top {
    CGRect frame = self.frame;
    frame.origin.y = [top floatValue];
    self.frame = frame;
}

- (void)changeBottom:(NSNumber *)bottom {
    CGRect frame = self.frame;
    frame.origin.y = [bottom floatValue] - frame.size.height;
    self.frame = frame;
}

- (void)changeWidth:(NSNumber *)width {
    CGRect frame = self.frame;
    frame.size.width = [width floatValue];
    self.frame = frame;
}

- (void)changeHeight:(NSNumber *)height {
    CGRect frame = self.frame;
    frame.size.height = [height floatValue];
    self.frame = frame;
}

@end
