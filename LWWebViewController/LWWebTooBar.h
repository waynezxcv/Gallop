//
//  LWWebTooBar.h
//  WarmerApp
//
//  Created by 刘微 on 16/3/15.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWWebTooBar : UIView

@property (nonatomic, assign) BOOL canGoBack;
@property (nonatomic, assign) BOOL canGoForward;

@property (nonatomic,strong) UIButton* backButton;
@property (nonatomic,strong) UIButton* forwardButton;
@property (nonatomic,strong) UIButton* reloadButton;

@end
