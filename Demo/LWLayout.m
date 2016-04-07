//
//  LWAutoLayout.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWLayout.h"

@implementation LWLayout

- (id)initWithTextStorages:(NSArray<LWTextStorage *>*)textStorages
             imageStorages:(NSArray<LWImageStorage *>*)imageStorages {
    self = [super init];
    if (self) {
        self.textStorages = [textStorages copy];
        self.imageStorages = [imageStorages copy];
    }
    return self;
}
@end
