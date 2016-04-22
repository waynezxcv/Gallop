//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "LWStorage.h"


typedef NS_ENUM(NSUInteger, LWImageStorageType) {
    LWImageStorageWebImage = 0,
    LWImageStorageLocalImage = 1,
};

@interface LWImageStorage : LWStorage

/**
 *  图片类型
 */
@property (nonatomic,assign) LWImageStorageType type;

/**
 *  图片URL（LWImageStorageWebImage）
 */
@property (nonatomic,strong) NSURL* URL;

/**
 *  图片UIImage （LWImageStorageLocalImage）
 */
@property (nonatomic,strong) UIImage* image;
/**
 *  内容模式
 */
@property (nonatomic,copy) NSString* contentMode;

/**
 *
 */
@property (nonatomic,assign) BOOL masksToBounds;

/**
 *  占位图
 */
@property (nonatomic,strong) UIImage* placeholder;

/**
 *  加载完成是否渐隐出现
 */
@property (nonatomic,assign,getter=isFadeShow) BOOL fadeShow;

/**
 *  圆角半径
 */
@property (nonatomic,assign) CGFloat cornerRadius;
/**
 *  圆角背景颜色
 */
@property (nonatomic,strong) UIColor* cornerBackgroundColor;

@property (nonatomic,strong) UIColor* cornerBorderColor;
@property (nonatomic,assign) CGFloat cornerBorderWidth;

- (void)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(NSInteger)topCapHeight;


@end



@interface LWImageContainer : CALayer

@property (nonatomic,copy) NSString* containerIdentifier;

- (void)setContentWithImageStorage:(LWImageStorage *)imageStorage;
- (void)layoutImageStorage:(LWImageStorage *)imageStorage;
- (void)cleanup;



- (void)delayLayoutImageStorage:(LWImageStorage *)imageStorage;
- (void)delayCleanup;


@end

