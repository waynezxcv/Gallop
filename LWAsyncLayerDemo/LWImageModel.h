//
//  LWImageModel.h
//  Warmjar2
//
//  Created by 刘微 on 15/10/6.
//  Copyright © 2015年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KPageControlHeight 40.0f
#define KImageBrowserWidth ([UIScreen mainScreen].bounds.size.width + 10.0f)
#define KImageBrowserHeight [UIScreen mainScreen].bounds.size.height



@interface LWImageModel : NSObject


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
@property (nonatomic,assign) CGRect originFrame;

/**
 *  计算后的位置
 */
@property (nonatomic,assign) CGRect destinationFrame;


/**
 *  标号
 */
@property (nonatomic,assign) NSInteger index;



- (id)initWithplaceholder:(UIImage *)placeholder
             thumbnailURL:(NSString *)thumbnailURL
                    HDURL:(NSString *)HDURL
             originRect:(CGRect)originRect
                  index:(NSInteger)index;

@end
