//
//  LWImageBrowserModel.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/17.
//  Copyright © 2016年 Warm+. All rights reserved.
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
@property (nonatomic,strong) NSURL* thumbnailURL;

/**
 *  略缩图
 *
 */
@property (nonatomic,strong) UIImage* thumbnailImage;

/**
 *  高清图URL
 */
@property (nonatomic,strong) NSURL* HDURL;

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
             thumbnailURL:(NSURL *)thumbnailURL
                    HDURL:(NSURL *)HDURL
       imageViewSuperView:(UIView *)superView
      positionAtSuperView:(CGRect)positionAtSuperView
                    index:(NSInteger)index;

/**
 *  创建LWImageModel实例对象
 *
 *  @param placeholder  本地图片
 *  @param originRect   原始位置
 *  @param index        标号
 *
 *  @return LWImageModel实例对象
 */
- (id)initWithLocalImage:(UIImage *)localImage
      imageViewSuperView:(UIView *)superView
     positionAtSuperView:(CGRect)positionAtSuperView
                   index:(NSInteger)index;

@end
