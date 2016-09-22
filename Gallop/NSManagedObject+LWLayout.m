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


#import "NSManagedObject+LWLayout.h"
#import <objc/runtime.h>


static void* LWTextStoragesKey = &LWTextStoragesKey ;
static void* LWImageStoragesKey = &LWImageStoragesKey;
static void* LWTotalStoragesKey = &LWTotalStoragesKey;

@implementation  NSManagedObject(LWLayout)

- (void)addStorage:(LWStorage *)storage {
    if (!storage) {
        return;
    }
    if ([storage isMemberOfClass:[LWTextStorage class]]) {
        [self.textStorages addObject:(LWTextStorage *)storage];
    }
    else if ([storage isMemberOfClass:[LWImageStorage class]]) {
        [self.imageStorages addObject:(LWImageStorage *)storage];
    }
    [self.totalStorages addObject:storage];
}

- (void)addStorages:(NSArray <LWStorage *> *)storages {
    if (!storages) {
        return;
    }
    for (LWStorage* storage in storages) {
        if ([storage isMemberOfClass:[LWTextStorage class]]) {
            [self.textStorages addObject:(LWTextStorage *)storage];
        }
        else if ([storage isMemberOfClass:[LWImageStorage class]]) {
            [self.imageStorages addObject:(LWImageStorage *)storage];
        }
    }
    [self.totalStorages addObjectsFromArray:storages];
}


- (void)removeStorage:(LWStorage *)storage {
    if (!storage) {
        return;
    }
    if ([storage isMemberOfClass:[LWTextStorage class]]) {
        if ([self.textStorages containsObject:(LWTextStorage *)storage]) {
            [self.textStorages removeObject:(LWTextStorage *)storage];
            [self.totalStorages removeObject:(LWTextStorage *)storage];
        }
    } else if ([storage isMemberOfClass:[LWImageStorage class]]) {
        if ([self.imageStorages containsObject:(LWImageStorage *)storage]) {
            [self.imageStorages removeObject:(LWImageStorage *)storage];
            [self.totalStorages removeObject:(LWImageStorage *)storage];
        }
    }
}

- (void)removeStorages:(NSArray <LWStorage *> *)storages {
    if (!storages) {
        return;
    }
    for (LWStorage* storage in storages) {
        if ([storage isMemberOfClass:[LWTextStorage class]]) {
            if ([self.textStorages containsObject:(LWTextStorage *)storage]) {
                [self.textStorages removeObject:(LWTextStorage *)storage];
                [self.totalStorages removeObject:(LWTextStorage *)storage];
            }
        } else if ([storage isMemberOfClass:[LWImageStorage class]]) {
            if ([self.imageStorages containsObject:(LWImageStorage *)storage]) {
                [self.imageStorages removeObject:(LWImageStorage *)storage];
                [self.totalStorages removeObject:(LWImageStorage *)storage];
            }
        }
    }
}

- (CGFloat)suggestHeightWithBottomMargin:(CGFloat)bottomMargin {
    CGFloat suggestHeight = 0.0f;
    for (LWStorage* storage in self.totalStorages) {
        suggestHeight = suggestHeight > storage.bottom ? suggestHeight :storage.bottom;
    }
    return suggestHeight + bottomMargin;
}

- (NSMutableArray<LWTextStorage *>*)textStorages {
    NSMutableArray* textStorages = objc_getAssociatedObject(self, LWTextStoragesKey);
    if (textStorages != nil) {
        return textStorages;
    }
    textStorages = [[NSMutableArray alloc] init];
    objc_setAssociatedObject(self,LWTextStoragesKey, textStorages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return textStorages;
}

- (NSMutableArray<LWImageStorage *>*)imageStorages {
    NSMutableArray* imageStorages = objc_getAssociatedObject(self, LWImageStoragesKey);
    if (imageStorages != nil) {
        return imageStorages;
    }
    imageStorages = [[NSMutableArray alloc] init];
    objc_setAssociatedObject(self,LWImageStoragesKey, imageStorages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return imageStorages;
}

- (NSMutableArray<LWStorage *>*) totalStorages {
    NSMutableArray* totalStorages = objc_getAssociatedObject(self, LWTotalStoragesKey);
    if (totalStorages != nil) {
        return totalStorages;
    }
    totalStorages = [[NSMutableArray alloc] init];
    objc_setAssociatedObject(self,LWTotalStoragesKey, totalStorages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return totalStorages;
}

@end
