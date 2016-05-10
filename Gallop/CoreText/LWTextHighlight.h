//
//  LWTextHighlight.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/5/11.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LWTextLinkAttributedName @"LWTextLinkAttributedName"


@interface LWTextHighlight : NSObject

@property (nonatomic,assign) NSRange range;//在字符串的range
@property (nonatomic,strong) UIColor* linkColor;
@property (nonatomic,strong) UIColor* hightlightColor;//高亮颜色
@property (nonatomic,copy) NSArray<NSValue *>* positions;//位置数组
@property (nonatomic,strong) id content;//内容
@property (nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息

@end
