//
//  LWWebImage.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



typedef NS_ENUM(NSUInteger, LWImageStorageType) {
    LWImageStorageLocalImage,
    LWImageStorageWebImage,
};


@interface LWImageStorage : NSObject

@property (nonatomic,assign) LWImageStorageType type;
@property (nonatomic,strong) NSURL* URL;
@property (nonatomic,strong) UIImage* image;
@property (nonatomic,assign) CGRect boundsRect;
@property (nonatomic,copy) NSString* contentMode;
@property (nonatomic,assign) BOOL masksToBounds;

@end
