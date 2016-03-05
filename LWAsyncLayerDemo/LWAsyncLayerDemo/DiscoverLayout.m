//
//  DiscoverLayout.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "DiscoverLayout.h"

@interface DiscoverLayout ()


@end

@implementation DiscoverLayout

- (id)initWithStatusModel:(DiscoverStatuModel *)statuModel {
    self = [super init];
    if (self) {
        self.statusModel = statuModel;
        [self layout];
    }
    return self;
}

- (void)layout {
    //avatar
    self.avatarPosition = CGRectMake(10.0f, 20.0f,40.0f, 40.0f);
    //name
    self.nameTextLayout = [[LWTextLayout alloc] init];
    self.nameTextLayout.text = self.statusModel.user.name;
    self.nameTextLayout.font = [UIFont systemFontOfSize:15.0f];
    self.nameTextLayout.textAlignment = NSTextAlignmentLeft;
    self.nameTextLayout.linespace = 2.0f;
    self.nameTextLayout.textColor = RGB(113, 129, 161, 1);
    self.nameTextLayout.boundsRect = CGRectMake(60, 20, SCREEN_WIDTH, 20);
    [self.nameTextLayout creatCTFrameRef];

    [self.nameTextLayout addLinkWithData:@"touch name link"
                                 inRange:NSMakeRange(0, self.statusModel.user.name.length)
                               linkColor:nil
                          highLightColor:[UIColor grayColor]
                          UnderLineStyle:NSUnderlineStyleNone];


    //text
    self.textTextLayout = [[LWTextLayout alloc] init];
    self.textTextLayout.text = self.statusModel.text;
    self.textTextLayout.font = [UIFont systemFontOfSize:15.0f];
    self.textTextLayout.textColor = RGB(40, 40, 40, 1);
    self.textTextLayout.boundsRect = CGRectMake(60.0f,50.0f,SCREEN_WIDTH - 80.0f,MAXFLOAT);
    [self.textTextLayout creatCTFrameRef];

    if (self.textTextLayout.text.length >= 11) {
        
        [self.textTextLayout addLinkWithData:@"touch text link  - 1"
                                     inRange:NSMakeRange(6, 5)
                                   linkColor:[UIColor redColor]
                              highLightColor:[UIColor blueColor]
                              UnderLineStyle:NSUnderlineStyleSingle];
        
        [self.textTextLayout addLinkWithData:@"touch text link - 2"
                                     inRange:NSMakeRange(0, 5)
                                   linkColor:[UIColor redColor]
                              highLightColor:[UIColor blueColor]
                              UnderLineStyle:NSUnderlineStyleSingle];
    }

    if (self.textTextLayout.text.length >= 70) {
        [self.textTextLayout insertImage:[UIImage imageNamed:@"loading"] atIndex:4];
        [self.textTextLayout insertImage:[UIImage imageNamed:@"menu"] atIndex:8];
        [self.textTextLayout insertImage:[UIImage imageNamed:@"menu"] atIndex:6];

    }
    //pics
    NSInteger imageCount = [self.statusModel.imageModels count];
    switch (imageCount) {
        case 0:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.textTextLayout.textHeight, 250.0f, 0.0f);
            break;
        case 1:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.textTextLayout.textHeight, 250.0f, 80.0f);
            break;
        case 2:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.textTextLayout.textHeight, 250.0f, 80.0f);
            break;
        case 3:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.textTextLayout.textHeight, 250.0f, 80.0f);
            break;
        case 4:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.textTextLayout.textHeight, 250.0f, 165.0f);
            break;
        case 5:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.textTextLayout.textHeight, 250.0f, 165.0f);
            break;
        case 6:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.textTextLayout.textHeight, 250.0f, 165.0f);
            break;
        case 7:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.textTextLayout.textHeight, 250.0f, 250.0f);
            break;
        case 8:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.textTextLayout.textHeight, 250.0f, 250.0f);
            break;
        case 9:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.textTextLayout.textHeight, 250.0f, 250.0f);
            break;
        default:self.imagesPosition = CGRectMake(60.0f, 60.0f + self.textTextLayout.textHeight, 250.0f, 0.0f);
            break;
    }

    //    image detail Position
    NSMutableArray* tmpArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
    NSInteger row = 0;
    NSInteger column = 0;
    for (NSInteger i = 0; i < self.statusModel.imageModels.count; i ++) {
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
    self.timeStampTextLayout = [[LWTextLayout alloc] init];
    self.timeStampTextLayout.text = self.statusModel.timeStamp;
    self.timeStampTextLayout.font = [UIFont systemFontOfSize:13.0f];
    self.timeStampTextLayout.textColor = [UIColor grayColor];
    self.timeStampTextLayout.boundsRect = CGRectMake(60, 70 + self.imagesPosition.size.height + self.textTextLayout.textHeight, SCREEN_WIDTH - 80, 20.0f);
    [self.timeStampTextLayout creatCTFrameRef];

    //menu
    self.menuPosition = CGRectMake(SCREEN_WIDTH - 40.0f, 70.0f + self.textTextLayout.boundsRect.size.height + self.imagesPosition.size.height, 20.0f, 15.0f);
    //cellHeight
    self.cellHeight = 100.0f + self.imagesPosition.size.height + self.textTextLayout.boundsRect.size.height;
}


@end
