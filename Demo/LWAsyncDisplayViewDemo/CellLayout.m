//
//  CellLayout.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/3/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "CellLayout.h"
#import "LWDefine.h"



@implementation CellLayout

- (id)initWithStatusModel:(StatusModel *)statusModel {
    self = [super init];
    if (self) {
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
        
        [self.nameTextLayout addLinkWithData:@"touch name link"
                                     inRange:NSMakeRange(0, self.statusModel.name.length)
                                   linkColor:nil
                              highLightColor:[UIColor grayColor]
                              UnderLineStyle:NSUnderlineStyleNone];        
        //content
        self.contentTextLayout = [[LWTextLayout alloc] init];
        self.contentTextLayout.text = self.statusModel.content;
        self.contentTextLayout.font = [UIFont systemFontOfSize:15.0f];
        self.contentTextLayout.textColor = RGB(40, 40, 40, 1);
        self.contentTextLayout.boundsRect = CGRectMake(60.0f,50.0f,SCREEN_WIDTH - 80.0f,MAXFLOAT);
        [self.contentTextLayout creatCTFrameRef];
        [LWTextParser parseEmojiWithTextLayout:self.contentTextLayout];
        [LWTextParser parseHttpURLWithTextLayout:self.contentTextLayout
                                       linkColor:[UIColor blueColor]
                                  highlightColor:nil
                                  underlineStyle:NSUnderlineStyleSingle];
        [LWTextParser parseAccountWithTextLayout:self.contentTextLayout
                                       linkColor:[UIColor redColor]
                                  highlightColor:nil
                                  underlineStyle:NSUnderlineStyleNone];
        [LWTextParser parseTopicWithTextLayout:self.contentTextLayout
                                     linkColor:[UIColor redColor]
                                highlightColor:nil
                                underlineStyle:NSUnderlineStyleNone];
        //imgs
        NSInteger imageCount = [self.statusModel.imgs count];
        switch (imageCount) {
            case 0:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.contentTextLayout.textHeight, 250.0f, 0.0f);
                break;
            case 1:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.contentTextLayout.textHeight, 250.0f, 80.0f);
                break;
            case 2:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.contentTextLayout.textHeight, 250.0f, 80.0f);
                break;
            case 3:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.contentTextLayout.textHeight, 250.0f, 80.0f);
                break;
            case 4:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.contentTextLayout.textHeight, 250.0f, 165.0f);
                break;
            case 5:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.contentTextLayout.textHeight, 250.0f, 165.0f);
                break;
            case 6:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.contentTextLayout.textHeight, 250.0f, 165.0f);
                break;
            case 7:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.contentTextLayout.textHeight, 250.0f, 250.0f);
                break;
            case 8:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.contentTextLayout.textHeight, 250.0f, 250.0f);
                break;
            case 9:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.contentTextLayout.textHeight, 250.0f, 250.0f);
                break;
            default:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.contentTextLayout.textHeight, 250.0f, 0.0f);
                break;
        }
        //image detail Position
        NSMutableArray* tmpArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
        NSInteger row = 0;
        NSInteger column = 0;
        for (NSInteger i = 0; i < self.statusModel.imgs.count; i ++) {
            CGRect imageRect = CGRectMake(self.imagesPosition.origin.x + (column * 85.0f),
                                          self.imagesPosition.origin.y + (row * 85.0f),
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
        self.imagePostionArray = tmpArray;
        //timeStamp
        self.dateTextLayout = [[LWTextLayout alloc] init];
//        self.dateTextLayout.text = self.statusModel.date;
        self.dateTextLayout.font = [UIFont systemFontOfSize:13.0f];
        self.dateTextLayout.textColor = [UIColor grayColor];
        self.dateTextLayout.boundsRect = CGRectMake(60, 70 + self.imagesPosition.size.height + self.contentTextLayout.textHeight, SCREEN_WIDTH - 80, 20.0f);
        [self.dateTextLayout creatCTFrameRef];
        //menu
        self.menuPosition = CGRectMake(SCREEN_WIDTH - 40.0f,
                                       70.0f + self.contentTextLayout.boundsRect.size.height + self.imagesPosition.size.height,
                                       20.0f,
                                       15.0f);
        //cellHeight
        self.cellHeight = 100.0f + self.imagesPosition.size.height + self.contentTextLayout.boundsRect.size.height;
    }
    return self;
}

@end
