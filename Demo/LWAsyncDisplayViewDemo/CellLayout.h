//
//  CellLayout.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/3/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusModel.h"
#import "LWTextLayout.h"
#import "LWTextParser.h"



@interface CellLayout : NSObject

@property (nonatomic,strong) StatusModel* statusModel;
@property (nonatomic,strong) LWTextLayout* nameTextLayout;
@property (nonatomic,strong) LWTextLayout* contentTextLayout;
@property (nonatomic,strong) LWTextLayout* dateTextLayout;

@property (nonatomic,assign) CGRect avatarPosition;
@property (nonatomic,assign) CGRect imagesPosition;
@property (nonatomic,assign) CGRect menuPosition;
@property (nonatomic,assign) CGRect likesAndCommentsPosition;
@property (nonatomic,copy) NSArray* imagePostionArray;

@property (nonatomic,assign) CGFloat textHeight;
@property (nonatomic,assign) CGFloat imagesHeight;
@property (nonatomic,assign) CGFloat likesAndCommentsHeight;
@property (nonatomic,assign) CGFloat cellHeight;

- (id)initWithStatusModel:(StatusModel *)statusModel;

@end
