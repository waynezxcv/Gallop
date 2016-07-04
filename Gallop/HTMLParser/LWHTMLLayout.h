//
//  LWHTMLLayout.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/7/5.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWStorage.h"

@interface LWHTMLLayout : NSObject


- (void)addStorage:(LWStorage *)storage;
- (void)addStorages:(NSArray <LWStorage *>*)storages;

- (void)appendStorage:(LWStorage *)storage;
- (void)appendStorages:(NSArray <LWStorage *>*)storages;


- (NSArray *)allItems;


@end
