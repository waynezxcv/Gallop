//
//  LWHTMLImageConfig.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/6/27.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface LWHTMLImageConfig : NSObject

@property (nonatomic,assign) CGSize size;
@property (nonatomic,strong) UIImage* placeholder;
@property (nonatomic,assign, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;
@property (nonatomic,assign) CGFloat paragraphSpacing;


+ (LWHTMLImageConfig *)defaultsConfig;

@end
