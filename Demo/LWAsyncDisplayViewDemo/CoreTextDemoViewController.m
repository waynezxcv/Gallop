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
        LWLayout* layout = [[LWLayout alloc] init];
        NSMutableParagraphStyle* p = [[NSMutableParagraphStyle alloc] init];
        [p setLineSpacing:2.0f];
        NSDictionary* attris = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:18],NSParagraphStyleAttributeName:p};
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:@"Gallop --- " attributes:attris];
        NSMutableAttributedString* emoji1 = [NSMutableAttributedString lw_textAttachmentStringWithContent:[UIImage imageNamed:@"001.png"]
                                                                                              contentMode:UIViewContentModeScaleAspectFill
                                                                                                   ascent:0.0f
                                                                                                  descent:12
                                                                                                    width:12.0f];
        NSMutableAttributedString* emoji2 = [NSMutableAttributedString lw_textAttachmentStringWithContent:[UIImage imageNamed:@"002.png"]
                                                                                              contentMode:UIViewContentModeScaleAspectFill
                                                                                                   ascent:12.0f
                                                                                                  descent:0
                                                                                                    width:12.0f];
        NSMutableAttributedString* emoji3 = [NSMutableAttributedString lw_textAttachmentStringWithContent:[UIImage imageNamed:@"003.png"]
                                                                                              contentMode:UIViewContentModeScaleAspectFill
                                                                                                   ascent:12.0f
                                                                                                  descent:0
                                                                                                    width:12.0f];
        NSMutableAttributedString* emoji4 = [NSMutableAttributedString lw_textAttachmentStringWithContent:[UIImage imageNamed:@"004.png"]
                                                                                              contentMode:UIViewContentModeScaleAspectFill
                                                                                                   ascent:12.0f
                                                                                                  descent:0
                                                                                                    width:12.0f];
        NSMutableAttributedString* emoji5 = [NSMutableAttributedString lw_textAttachmentStringWithContent:[UIImage imageNamed:@"005.png"]
                                                                                              contentMode:UIViewContentModeScaleAspectFill
                                                                                                   ascent:12.0f
                                                                                                  descent:0
                                                                                                    width:12.0f];
        [attributedString appendAttributedString:emoji1];
        [attributedString appendAttributedString:emoji2];
        [attributedString appendAttributedString:emoji3];
        [attributedString appendAttributedString:emoji4];
        [attributedString appendAttributedString:emoji5];
        [attributedString setTextColor:[UIColor redColor] range:NSMakeRange(0, attributedString.length)];
        [attributedString setTextBackgroundColor:[UIColor yellowColor] range:NSMakeRange(0, attributedString.length)];
        [attributedString setTextAlignment:NSTextAlignmentRight range:NSMakeRange(0, attributedString.length)];
        LWTextStorage* storage = [LWTextStorage lw_textStrageWithText:attributedString frame:CGRectMake(10.0f, 100.0f, self.view.bounds.size.width - 30.0f, 300.0f)];
        [layout addStorage:storage];

        LWTextStorage* storage1 = [[LWTextStorage alloc] initWithFrame:CGRectMake(10, 50.0f, self.view.bounds.size.width - 20.0f, CGFLOAT_MAX)];
        storage1.textColor = [UIColor greenColor];
        storage1.textBackgroundColor = [UIColor redColor];
        storage1.textAlignment = NSTextAlignmentRight;
        storage1.text = @"我想要写一个牛逼的框架。";

        [storage1 lw_replaceTextWithView:[[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60.0f, 30.0f)]
                             contentMode:UIViewContentModeScaleAspectFill
                                    size:CGSizeMake(60.0f, 30.0f)
                               alignment:LWTextAttachAlignmentTop
                                   range:NSMakeRange(1,0)];


        [storage1 lw_replaceTextWithImage:[UIImage imageNamed:@"005.png"]
                              contentMode:UIViewContentModeScaleAspectFill
                                imageSize:CGSizeMake(60, 60)
                                alignment:LWTextAttachAlignmentCenter
                                    range:NSMakeRange(4, 0)];



        [layout addStorage:storage1];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.asyncDisplayView.layout = layout;
        });
    });
}




- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.asyncDisplayView.frame = CGRectMake(0, 64.0f, self.view.bounds.size.width, self.view.bounds.size.height - 64.0f);
}


- (LWAsyncDisplayView *)asyncDisplayView {
    if (_asyncDisplayView) {
        return _asyncDisplayView;
    }
    _asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
    _asyncDisplayView.backgroundColor = [UIColor lightGrayColor];
    return _asyncDisplayView;
}

@end
