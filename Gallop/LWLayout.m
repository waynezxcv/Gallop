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


#import "LWLayout.h"
#import <objc/runtime.h>
#import "GallopDefine.h"


@interface LWLayout ()

@property (nonatomic,strong) NSMutableArray<LWTextStorage *>* textStorages;
@property (nonatomic,strong) NSMutableArray<LWImageStorage *>* imageStorages;
@property (nonatomic,strong) NSMutableArray<LWStorage *>* totalStorages;

@end

@implementation LWLayout


#pragma mark - Override Hash & isEqual

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (!object || ![object isKindOfClass:[LWLayout class]]) {
        return NO;
    }
    LWLayout* layout = (LWLayout *)object;
    return ([layout.textStorages isEqual:self.textStorages] && [layout.imageStorages isEqual:self.imageStorages]);
}

- (NSUInteger)hash {
    long v1 = (long)((__bridge void *)self.textStorages);
    long v2 = (long)((__bridge void *)self.imageStorages);
    return v1 ^ v2;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.textStorages forKey:@"textStorages"];
    [aCoder encodeObject:self.imageStorages forKey:@"imageStorages"];
    [aCoder encodeObject:self.totalStorages forKey:@"totalStorages"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.textStorages = [aDecoder decodeObjectForKey:@"textStorages"];
        self.imageStorages = [aDecoder decodeObjectForKey:@"imageStorages"];
        self.totalStorages = [aDecoder decodeObjectForKey:@"totalStorages"];
    }
    return self;
}

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
    }
    else if ([storage isMemberOfClass:[LWImageStorage class]]) {
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

#pragma mark - Getter
- (NSMutableArray *)textStorages {
    if (_textStorages) {
        return _textStorages;
    }
    _textStorages = [[NSMutableArray alloc] init];
    return _textStorages;
}

- (NSMutableArray *)imageStorages {
    if (_imageStorages) {
        return _imageStorages;
    }
    _imageStorages = [[NSMutableArray alloc] init];
    return _imageStorages;
}

- (NSMutableArray *)totalStorages {
    if (_totalStorages) {
        return _totalStorages;
    }
    _totalStorages = [[NSMutableArray alloc] init];
    return _totalStorages;
}



@end
