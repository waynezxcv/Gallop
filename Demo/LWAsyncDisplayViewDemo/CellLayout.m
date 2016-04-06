//
//  CellLayout.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/3/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "CellLayout.h"
#import "LWDefine.h"
#import "LWTextParser.h"



@implementation CellLayout


- (id)initWithCDStatusModel:(StatusModel *)statusModel {
    self = [super init];
    if (self) {
        static NSDateFormatter* dateFormatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM月dd日 hh:mm"];
        });
        self.statusModel = statusModel;
        //avatar
        self.avatarPosition = CGRectMake(10.0f, 20.0f,40.0f, 40.0f);
        //name
        self.nameTextLayout = [[LWTextLayout alloc] init];
        self.nameTextLayout.text = self.statusModel.name;
        self.nameTextLayout.font = [UIFont systemFontOfSize:15.0f];
        self.nameTextLayout.textAlignment = NSTextAlignmentLeft;
        self.nameTextLayout.linespace = 2.0f;
        self.nameTextLayout.textColor = RGB(113, 129, 161, 1);
        self.nameTextLayout.boundsRect = CGRectMake(60, 20, SCREEN_WIDTH, 20);
        [self.nameTextLayout creatCTFrameRef];

        [self.nameTextLayout addLinkWithData:[NSString stringWithFormat:@"%@",self.statusModel.name]
                                     inRange:NSMakeRange(0, self.statusModel.name.length)
                                   linkColor:nil
                              highLightColor:[UIColor grayColor]
                              UnderLineStyle:NSUnderlineStyleNone];

        //content
        self.contentTextLayout = [[LWTextLayout alloc] init];
        self.contentTextLayout.text = self.statusModel.content;
        self.contentTextLayout.font = [UIFont systemFontOfSize:15.0f];
        self.contentTextLayout.textColor = RGB(40, 40, 40, 1);
        self.contentTextLayout.boundsRect = CGRectMake(60.0f,self.nameTextLayout.bottom,SCREEN_WIDTH - 80.0f,MAXFLOAT);
        self.contentTextLayout.linespace = 2.0f;
        [self.contentTextLayout creatCTFrameRef];
        //解析表情跟主题（[emoji] - > 表情。。#主题# 添加链接）
        [LWTextParser parseEmojiWithTextLayout:self.contentTextLayout];
        [LWTextParser parseTopicWithTextLayout:self.contentTextLayout
                                     linkColor:RGB(113, 129, 161, 1)
                                highlightColor:nil
                                underlineStyle:NSUnderlineStyleNone];

        //imgs
        NSInteger imageCount = [self.statusModel.imgs count];
        NSMutableArray* tmpArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
        NSInteger row = 0;
        NSInteger column = 0;
        for (NSInteger i = 0; i < self.statusModel.imgs.count; i ++) {
            CGRect imageRect = CGRectMake(60.0f + (column * 85.0f),
                                          60.0f + self.contentTextLayout.textHeight + (row * 85.0f),
                                          80.0f,
                                          80.0f);
            NSString* rectString = NSStringFromCGRect(imageRect);
            [tmpArray addObject:rectString];
            column = column + 1;
            if (column > 2) {
                column = 0;
                row = row + 1;
            }
        }
        CGFloat imagesHeight = 0.0f;
        row < 3 ? (imagesHeight = (row + 1) * 85.0f):(imagesHeight = row  * 85.0f);
        self.imagePostionArray = tmpArray;
        //timeStamp
        self.dateTextLayout = [[LWTextLayout alloc] init];
        self.dateTextLayout.text = [dateFormatter stringFromDate:self.statusModel.date];
        self.dateTextLayout.font = [UIFont systemFontOfSize:13.0f];
        self.dateTextLayout.textColor = [UIColor grayColor];
        self.dateTextLayout.boundsRect = CGRectMake(60, 20.0f + imagesHeight + self.contentTextLayout.bottom,
                                                    SCREEN_WIDTH - 80,
                                                    20.0f);
        [self.dateTextLayout creatCTFrameRef];
        //menu
        self.menuPosition = CGRectMake(SCREEN_WIDTH - 40.0f,
                                       20.0f + imagesHeight + self.contentTextLayout.bottom,
                                       20.0f,
                                       15.0f);
        //comment
        self.commentBgPosition = CGRectZero;
        self.commentTextLayouts = @[];
        CGRect rect = CGRectMake(60.0f,self.dateTextLayout.bottom + 5.0f, SCREEN_WIDTH - 80, 20);
        CGFloat offsetY = 0.0f;
        if (self.statusModel.commentList.count != 0 && self.statusModel.commentList != nil) {
            NSMutableArray* tmp = [[NSMutableArray alloc] initWithCapacity:self.statusModel.commentList.count];
            for (NSDictionary* commentDict in self.statusModel.commentList) {
                NSString* to = commentDict[@"to"];
                if (to.length != 0) {
                    NSString* commentString = [NSString stringWithFormat:@"%@回复%@:%@",commentDict[@"from"],commentDict[@"to"],commentDict[@"content"]];
                    LWTextLayout* commentLayout = [[LWTextLayout alloc] init];
                    commentLayout.text = commentString;
                    commentLayout.font = [UIFont systemFontOfSize:14.0f];
                    commentLayout.textAlignment = NSTextAlignmentLeft;
                    commentLayout.linespace = 2.0f;
                    commentLayout.textColor = RGB(40, 40, 40, 1);
                    commentLayout.boundsRect = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY,SCREEN_WIDTH - 95.0f, 20.0f);
                    [commentLayout creatCTFrameRef];

                    [commentLayout addLinkWithData:[NSString stringWithFormat:@"%@",commentDict[@"from"]]
                                                 inRange:NSMakeRange(0,[(NSString *)commentDict[@"from"] length])
                                         linkColor:RGB(113, 129, 161, 1)
                                          highLightColor:[UIColor grayColor]
                                          UnderLineStyle:NSUnderlineStyleNone];

                    [commentLayout addLinkWithData:[NSString stringWithFormat:@"%@",commentDict[@"to"]]
                                           inRange:NSMakeRange([(NSString *)commentDict[@"from"] length] + 2,[(NSString *)commentDict[@"to"] length])
                                         linkColor:RGB(113, 129, 161, 1)
                                    highLightColor:[UIColor grayColor]
                                    UnderLineStyle:NSUnderlineStyleNone];


                    [LWTextParser parseEmojiWithTextLayout:commentLayout];
                    [LWTextParser parseTopicWithTextLayout:commentLayout
                                                 linkColor:RGB(113, 129, 161, 1)
                                            highlightColor:nil
                                            underlineStyle:NSUnderlineStyleNone];


                    [tmp addObject:commentLayout];
                    offsetY += commentLayout.textHeight;
                } else {
                    NSString* commentString = [NSString stringWithFormat:@"%@:%@",commentDict[@"from"],commentDict[@"content"]];
                    LWTextLayout* commentLayout = [[LWTextLayout alloc] init];
                    commentLayout.text = commentString;
                    commentLayout.font = [UIFont systemFontOfSize:14.0f];
                    commentLayout.textAlignment = NSTextAlignmentLeft;
                    commentLayout.linespace = 2.0f;
                    commentLayout.textColor = RGB(40, 40, 40, 1);
                    commentLayout.boundsRect = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY,SCREEN_WIDTH - 95.0f, 20.0f);
                    [commentLayout creatCTFrameRef];

                    [commentLayout addLinkWithData:[NSString stringWithFormat:@"%@",commentDict[@"from"]]
                                           inRange:NSMakeRange(0,[(NSString *)commentDict[@"from"] length])
                                         linkColor:RGB(113, 129, 161, 1)
                                    highLightColor:[UIColor grayColor]
                                    UnderLineStyle:NSUnderlineStyleNone];

                    [LWTextParser parseEmojiWithTextLayout:commentLayout];
                    [LWTextParser parseTopicWithTextLayout:commentLayout
                                                 linkColor:RGB(113, 129, 161, 1)
                                            highlightColor:nil
                                            underlineStyle:NSUnderlineStyleNone];

                    [tmp addObject:commentLayout];
                    offsetY += commentLayout.textHeight;
                }
            }
            self.commentTextLayouts = tmp;
            self.commentBgPosition = CGRectMake(60.0f,self.dateTextLayout.bottom + 5.0f, SCREEN_WIDTH - 80, offsetY + 15.0f);
        }
        //cellHeight
        self.cellHeight = self.dateTextLayout.bottom + self.commentBgPosition.size.height + 15.0f;
    }
    return self;
}

@end
