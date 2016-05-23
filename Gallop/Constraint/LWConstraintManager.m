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
    if (self.constraint.centerValue) {
        [self changeCenter:self.constraint.centerValue];
    }
    if (self.constraint.left) {
        [self changeLeft:self.constraint.left];
    }
    if (self.constraint.top) {
        [self changeTop:self.constraint.top];
    }
    if (self.constraint.bottom) {
        [self changeBottom:self.constraint.bottom];
    }
    if (self.constraint.width) {
        [self changeWidth:self.constraint.width];
    }
    if (self.constraint.height) {
        [self changeHeight:self.constraint.height];
    }
    if (self.constraint.leftEqualObject) {
        [self changeLeft:@(self.constraint.leftEqualObject.referenceStorage.left)];
    }
    if (self.constraint.topEqualObject) {
        [self changeTop:@(self.constraint.rightEqualObject.referenceStorage.right)];
    }
    if (self.constraint.bottomEqualObject) {
        [self changeBottom:@(self.constraint.bottomEqualObject.referenceStorage.bottom)];
    }
    if (self.constraint.leftMarginObject) {
        [self changeLeft:@(self.constraint.leftMarginObject.referenceStorage.right + self.constraint.leftMarginObject.value)];
    }
    if (self.constraint.right) {
        [self changeRight:self.constraint.right];
    }
    if (self.constraint.rightEqualObject) {
        [self changeRight:@(self.constraint.rightEqualObject.referenceStorage.right)];
    }
    if (self.constraint.rightMarginObject) {
        [self changeRight:@(self.constraint.rightMarginObject.referenceStorage.left - self.constraint.rightMarginObject.value)];
    }
    if (self.constraint.topMarginObject) {
        [self changeTop:@(self.constraint.topMarginObject.referenceStorage.bottom + self.constraint.topMarginObject.value)];
    }
    if (self.constraint.bottomMarginObject) {
        [self changeTop:@(self.constraint.bottomMarginObject.referenceStorage.top - self.constraint.bottomMarginObject.value)];
    }
    if ([self.constraint.superStorage isMemberOfClass:[LWTextStorage class]]) {
        LWTextStorage* TextStorage = (LWTextStorage *)self.constraint.superStorage;
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

+ (void)changeCenter:(NSValue *)center {
    CGPoint centerPoint = [center CGPointValue];
    self.constraint.superStorage.center = centerPoint;
}


@end
