//
//  LWConstraintManager.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/9.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWConstraintManager.h"
#import "LWTextStorage.h"
#import <objc/runtime.h>


static void* LWConstraintManagerCacheKey = &LWConstraintManagerCacheKey;
static void* LWContainerSizeKey = &LWContainerSizeKey;


@implementation LWConstraintManager

+ (LWConstraint *)constraint {
    return objc_getAssociatedObject(self, LWConstraintManagerCacheKey);
}

+ (void)setConstraint:(LWConstraint *)constraint {
    objc_setAssociatedObject(self,LWConstraintManagerCacheKey, constraint, OBJC_ASSOCIATION_RETAIN);
}

+ (CGSize)containerSize {
    return [objc_getAssociatedObject(self, LWContainerSizeKey) CGSizeValue];
}

+ (void)setContainerSize:(CGSize)size {
    objc_setAssociatedObject(self,LWContainerSizeKey,[NSValue valueWithCGSize:size], OBJC_ASSOCIATION_RETAIN);
}

+ (void)lw_makeConstraint:(LWConstraint* )constraint {
    [self setConstraint:constraint];
    [self setContainerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX)];
    [self auotoLayout];
}

+ (void)lw_makeConstraint:(LWConstraint* )constraint containerSize:(CGSize)size {
    [self setConstraint:constraint];
    [self setContainerSize:size];
    [self auotoLayout];
}

+ (void)auotoLayout {
    if (self.constraint.left) {
        [self changeLeft:self.constraint.left];
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
    if (self.constraint.right) {
        [self changeRight:self.constraint.right];
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
    if ([self.constraint.superStorage isMemberOfClass:[LWTextStorage class]]) {
        LWTextStorage* TextStorage = (LWTextStorage *)self.constraint.superStorage;
        [TextStorage creatCTFrameRef];
    }
}

#pragma mark - ChangeFrame

+ (void)changeLeft:(NSNumber *)left {
    CGRect frame = self.constraint.superStorage.frame;
    frame.origin.x = [left floatValue];
    self.constraint.superStorage.frame = frame;
}

+ (void)changeRight:(NSNumber *)right {
    CGRect frame = self.constraint.superStorage.frame;
    frame.size.width = [self containerSize].width - [right floatValue] - self.constraint.superStorage.frame.origin.x;
    self.constraint.superStorage.frame = frame;
}

+ (void)changeTop:(NSNumber *)top {
    CGRect frame = self.constraint.superStorage.frame;
    frame.origin.y = [top floatValue];
    self.constraint.superStorage.frame = frame;
}

+ (void)changeBottom:(NSNumber *)bottom {
    CGRect frame = self.constraint.superStorage.frame;
    frame.origin.y = [bottom floatValue] - frame.size.height;
    self.constraint.superStorage.frame = frame;
}

+ (void)changeWidth:(NSNumber *)width {
    CGRect frame = self.constraint.superStorage.frame;
    frame.size.width = [width floatValue];
    self.constraint.superStorage.frame = frame;
}

+ (void)changeHeight:(NSNumber *)height {
    CGRect frame = self.constraint.superStorage.frame;
    frame.size.height = [height floatValue];
    self.constraint.superStorage.frame = frame;
}


@end
