//
//  CoreTextDemoViewController.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/5/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "CoreTextDemoViewController.h"
#import "Gallop.h"

@interface CoreTextDemoViewController ()

@end

@implementation CoreTextDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CoreText";
    self.view.backgroundColor = [UIColor whiteColor];

    LWAsyncDisplayView* asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:asyncDisplayView];

}


@end
