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
//  LWWebImage.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWImageStorage.h"

@interface LWImageStorage ()

@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic,assign,readwrite) LWImageContainerType imageContainerType;

@end

@implementation LWImageStorage

- (id)init {
    self = [super init];
    if (self) {
        self.type = LWImageStorageLocalImage;
        self.imageContainerType = LWImageContainerTypeCALayer;
        self.image = nil;
        self.URL = nil;
        self.frame = CGRectZero;
        self.contentMode = kCAGravityResizeAspect;
        self.masksToBounds = YES;
        self.placeholder = nil;
        self.fadeShow = NO;
    }
    return self;
}

- (void)addtarget:(id)target action:(SEL)selector {
    if (!target || !selector) {
        return;
    }
    self.target = target;
    self.selector = selector;
    self.imageContainerType = LWImageContainerTypeUIImageView;
}

@end
