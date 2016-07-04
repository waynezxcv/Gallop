//
//  LWHTMLLayout.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/7/5.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWHTMLLayout.h"

@interface LWHTMLLayout ()

@property (nonatomic,strong) NSMutableArray* items;

@end

@implementation LWHTMLLayout

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
    if (!self.items.count) {
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
    if (!self.items.count) {
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
