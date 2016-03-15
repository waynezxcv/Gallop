//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//  LWImageBrowserModel.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/17.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LWImageBrowserModel : NSObject

/**
 *  占位图
 */
@property (nonatomic,strong) UIImage* placeholder;

/**
 *  略缩图URL
 *
 */
@property (nonatomic,copy) NSString* thumbnailURL;

/**
 *  略缩图
 *
 */
@property (nonatomic,strong) UIImage* thumbnailImage;

/**
 *  高清图URL
 */
@property (nonatomic,copy) NSString* HDURL;

/**
 *  是否已经下载
 */
@property (nonatomic,assign,readonly) BOOL isDownload;

/**
 *  原始位置（在window坐标系中）
 */
@property (nonatomic,assign) CGRect originPosition;

/**
 *  计算后的位置
 */
@property (nonatomic,assign,readonly) CGRect destinationFrame;

/**
 *  标号
 */
@property (nonatomic,assign) NSInteger index;

/**
 标题
 */
@property (nonatomic,copy) NSString* title;

/**
 *  详细描述
 */
@property (nonatomic,copy) NSString* contentDescription;


/**
 *  创建LWImageModel实例对象
 *
 *  @param placeholder  占位图片
 *  @param thumbnailURL 略缩图URL
 *  @param HDURL        高清图URL
 *  @param originRect   原始位置
 *  @param index        标号
 *
 *  @return LWImageModel实例对象
 */
- (id)initWithplaceholder:(UIImage *)placeholder
             thumbnailURL:(NSString *)thumbnailURL
                    HDURL:(NSString *)HDURL
       imageViewSuperView:(UIView *)superView
      positionAtSuperView:(CGRect)positionAtSuperView
                    index:(NSInteger)index;

@end
