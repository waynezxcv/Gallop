//
//  CellLayout.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/3/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWTextStorage.h"
#import "LWImageStorage.h"
#import "LWTextParser.h"
#import "StatusModel.h"


@interface CellLayout : NSObject

@property (nonatomic,strong) StatusModel* statusModel;
@property (nonatomic,strong) LWTextStorage* nameTextLayout;
@property (nonatomic,strong) LWTextStorage* contentTextLayout;
@property (nonatomic,strong) LWTextStorage* dateTextLayout;

@property (nonatomic,assign) CGRect avatarPosition;
@property (nonatomic,assign) CGRect menuPosition;
@property (nonatomic,assign) CGRect likesAndCommentsPosition;
@property (nonatomic,copy) NSArray* imagePostionArray;

@property (nonatomic,assign) CGFloat textHeight;
@property (nonatomic,assign) CGFloat imagesHeight;
@property (nonatomic,assign) CGFloat likesAndCommentsHeight;
@property (nonatomic,assign) CGRect commentBgPosition;
@property (nonatomic,copy) NSArray* commentTextLayouts;
@property (nonatomic,assign) CGFloat cellHeight;

@property (nonatomic,copy) NSArray* imageStorages;

- (id)initWithCDStatusModel:(StatusModel *)statusModel;

@end
