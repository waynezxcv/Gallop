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

#import "LWHTMLLayout.h"

@interface LWHTMLLayout ()

@property (nonatomic,strong) NSMutableArray* items;

@end

@implementation LWHTMLLayout


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.items forKey:@"items"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.items = [aDecoder decodeObjectForKey:@"items"];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addStorage:(LWStorage *)storage {
    if (!storage) {
        return;
    }
    [self.items addObject:storage];
}
- (void)addStorages:(NSArray <LWStorage *>*)storages {
    if (!storages.count) {
        return;
    }
    [self.items addObjectsFromArray:storages];
}

- (void)appendStorage:(LWStorage *)storage {
    if (!self.items.count || !storage) {
        return;
    }
    id lastObject = [self.items lastObject];
    if ([lastObject isKindOfClass:[NSArray class]]) {
        NSInteger index = [self.items indexOfObject:lastObject];
        NSMutableArray* tmp = [[NSMutableArray alloc] initWithArray:lastObject];
        [tmp addObject:storage];
        [self.items replaceObjectAtIndex:index withObject:[tmp copy]];
    }
    else if ([lastObject isKindOfClass:[LWStorage class]]) {
        NSInteger index = [self.items indexOfObject:lastObject];
        NSMutableArray* tmp = [[NSMutableArray alloc] init];
        [tmp addObject:lastObject];
        [tmp addObject:storage];
        [self.items replaceObjectAtIndex:index withObject:[tmp copy]];
    }
}

- (void)appendStorages:(NSArray <LWStorage *>*)storages {
    if (!self.items.count  || !storages.count ) {
        return;
    }
    id lastObject = [self.items lastObject];
    if ([lastObject isKindOfClass:[NSArray class]]) {
        NSInteger index = [self.items indexOfObject:lastObject];
        NSMutableArray* tmp = [[NSMutableArray alloc] initWithArray:lastObject];
        [tmp addObjectsFromArray:storages];
        [self.items replaceObjectAtIndex:index withObject:[tmp copy]];
    }
    else if ([lastObject isKindOfClass:[LWStorage class]]) {
        NSInteger index = [self.items indexOfObject:lastObject];
        NSMutableArray* tmp = [[NSMutableArray alloc] init];
        [tmp addObject:lastObject];
        [tmp addObjectsFromArray:storages];
        [self.items replaceObjectAtIndex:index withObject:[tmp copy]];
    }
}

- (NSArray *)allItems {
    return [self.items copy];
}

@end
