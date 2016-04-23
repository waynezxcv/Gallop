//
//  Menu.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/24.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Menu : UIView

@property (nonatomic,strong) UIButton* likeButton;
@property (nonatomic,strong) UIButton* commentButton;

- (void)clickedMenu;

- (void)menuShow;
- (void)menuHide;

@end
