//
//  CoreTextDemoViewController.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/5/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "CoreTextDemoViewController.h"
#import "LWTextLabel.h"
#import "NSMutableAttributedString+Gallop.h"

@interface CoreTextDemoViewController ()

@end

@implementation CoreTextDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CoreText";
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableParagraphStyle* p = [[NSMutableParagraphStyle alloc] init];
    [p setLineSpacing:2.0f];
    
    NSDictionary* attris = @{NSForegroundColorAttributeName:[UIColor blackColor],
                             NSFontAttributeName:[UIFont systemFontOfSize:18],
                             NSParagraphStyleAttributeName:p};
    NSMutableAttributedString* attachmentString1 = [NSMutableAttributedString lw_textAttachmentStringWithContent:[UIImage imageNamed:@"[face]"]
                                                                                                     contentMode:UIViewContentModeScaleAspectFill
                                                                                                          ascent:30
                                                                                                         descent:10
                                                                                                           width:40];
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"[face]"]];
    NSMutableAttributedString* attachmentString2 = [NSMutableAttributedString lw_textAttachmentStringWithContent:imageView
                                                                                                     contentMode:UIViewContentModeScaleAspectFill
                                                                                                          ascent:60
                                                                                                         descent:0
                                                                                                           width:60];
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:@"Gallop --- 异步绘制排版引擎，支持布局预加载缓存、支持图文混排显示" attributes:attris];
    
    [attributedString addLinkWithData:@"linik" range:NSMakeRange(0, 11) linkColor:[UIColor blueColor] highLightColor:[UIColor redColor]];
    
    [attributedString addLinkWithData:@"linik" range:NSMakeRange(16, 11) linkColor:[UIColor blueColor] highLightColor:[UIColor redColor]];
    
    [attributedString appendAttributedString:attachmentString1];
    [attributedString appendAttributedString:attachmentString2];
    [attributedString appendAttributedString:attachmentString1];
    
    NSMutableAttributedString* s = [[NSMutableAttributedString alloc] initWithString:@"，支持添加链接、支持自定义排版，自动布局。 只需要少量简单代码，就可以构建一个性能相当优秀(滚动时帧数60)的 Feed流界面." attributes:attris];
    [attributedString appendAttributedString:s];
    
    UIImageView* imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"[face]"]];
    
    NSMutableAttributedString* attachmentString3 = [NSMutableAttributedString lw_textAttachmentStringWithContent:imageView1
                                                                                                     contentMode:UIViewContentModeScaleAspectFill ascent:80 descent:0 width:80];
    [attributedString appendAttributedString:attachmentString3];
    
    
    
    
    //    LWTextContainer* container = [LWTextContainer lw_textContainerWithPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(20, 20, self.view.bounds.size.width - 40.0f, 600.0f) cornerRadius:50]];
    
    LWTextContainer* container = [LWTextContainer lw_textContainerWithSize:CGSizeMake(self.view.bounds.size.width - 20, 600.0f)
                                                                edgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    LWTextLayout* textLayout = [LWTextLayout lw_layoutWithContainer:container text:attributedString];
    
    LWTextLabel* textLabel = [[LWTextLabel alloc] initWithFrame:CGRectMake(10, 84, self.view.bounds.size.width - 20,300)];
    textLabel.textLayout = textLayout;
    textLabel.backgroundColor = [UIColor grayColor];
    [self.view addSubview:textLabel];
}


@end
