//
//  LWHTMLImageConfig.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/6/27.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface LWHTMLImageConfig : NSObject

@property (nonatomic,assign) BOOL autolayoutHeight;
@property (nonatomic,assign) CGSize size;
@property (nonatomic,strong) UIImage* placeholder;
@property (nonatomic,assign, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;
@property (nonatomic,assign) CGFloat paragraphSpacing;
@property (nonatomic,assign) BOOL needAddToImageBrowser;//是否需要将这个Image包含到照片浏览器的内容中去

+ (LWHTMLImageConfig *)defaultsConfig;

@end
