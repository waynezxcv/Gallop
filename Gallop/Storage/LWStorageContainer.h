//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
////
//
//
//  Created by 刘微 on 16/4/21.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWStorage.h"
#import "LWTextStorage.h"
#import "LWImageStorage.h"

@interface LWStorageContainer : NSObject

@property (nonatomic,strong,readonly) NSMutableArray<LWTextStorage *>* textStorages;
@property (nonatomic,strong,readonly) NSMutableArray<LWImageStorage *>* imageStorages;
@property (nonatomic,strong,readonly) NSMutableArray<LWStorage *>* totalStorages;

- (void)addStorage:(LWStorage *)storage;
- (void)addStorages:(NSArray <LWStorage *> *)storages;

- (void)removeStorage:(LWStorage *)storage;
- (void)removeStorages:(NSArray <LWStorage *> *)storages;

- (CGFloat)suggestHeightWithBottomMargin:(CGFloat)bottomMargin;

@end
