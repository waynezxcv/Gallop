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

@property (nonatomic,strong) LWAsyncDisplayView* asyncDisplayView;

@end

@implementation CoreTextDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CoreText";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.asyncDisplayView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableParagraphStyle* p = [[NSMutableParagraphStyle alloc] init];
        [p setLineSpacing:2.0f];
        NSDictionary* attris = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:18],
                                 NSParagraphStyleAttributeName:p};
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:@"Gallop --- 异步绘制排版引擎，支持布局预加载缓存、支持图文混排显示" attributes:attris];
        LWTextStorage* storage = [LWTextStorage LW_textStrageWithText:attributedString frame:CGRectMake(10.0f, 10.0f, self.view.bounds.size.width - 30.0f, 300.0f)];

        NSMutableAttributedString* attributedString1 = [[NSMutableAttributedString alloc] initWithString:@"第二行文字,Gallop --- 异步绘制排版引擎，支持布局预加载缓存、支持图文混排显示" attributes:attris];
        NSMutableAttributedString* attachmentString1 = [NSMutableAttributedString lw_textAttachmentStringWithContent:[UIImage imageNamed:@"pic.jpeg"]
                                                                                                         contentMode:UIViewContentModeScaleAspectFill
                                                                                                              ascent:30
                                                                                                             descent:10
                                                                                                               width:40];
        NSMutableAttributedString* attributedString2 = [[NSMutableAttributedString alloc] initWithString:@"Gallop --- 异步绘制排版引擎，支持布局预加载缓存、支持图文混排显示" attributes:attris];
        [attributedString1 appendAttributedString:attachmentString1];
        [attributedString1 appendAttributedString:attributedString2];
        NSMutableAttributedString* attachmentString2 = [NSMutableAttributedString lw_textAttachmentStringWithContent:[UIImage imageNamed:@"pic.jpeg"]
                                                                                                         contentMode:UIViewContentModeScaleAspectFill
                                                                                                              ascent:60
                                                                                                             descent:0
                                                                                                               width:60];
        [attributedString1 appendAttributedString:attachmentString2];
        [attributedString1 setTextBackgroundColor:[UIColor redColor] range:NSMakeRange(0, attributedString1.length)];
        LWTextStorage* storage1 = [LWTextStorage LW_textStrageWithText:attributedString1 frame:CGRectMake(10.0f, 100.0f, self.view.bounds.size.width - 100.0f, 600.0f)];
        LWLayout* layout = [[LWLayout alloc] init];
        [layout addStorage:storage];
        [layout addStorage:storage1];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.asyncDisplayView.layout = layout;
        });
    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.asyncDisplayView.frame = CGRectMake(10.0f, 100.0f, self.view.bounds.size.width - 20.0f, 500.0f);
}


- (LWAsyncDisplayView *)asyncDisplayView {
    if (_asyncDisplayView) {
        return _asyncDisplayView;
    }
    _asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
    _asyncDisplayView.backgroundColor = [UIColor lightGrayColor
                                         ];
    return _asyncDisplayView;
}

@end
