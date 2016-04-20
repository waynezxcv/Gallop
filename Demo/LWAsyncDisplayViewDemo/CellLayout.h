//
//  CellLayout.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWLayout.h"
#import "StatusModel.h"

/**
 *  要添加一些其他属性，可以继承自LWLayout
 */

@interface CellLayout : LWLayout

@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) CGRect menuPosition;
@property (nonatomic,assign) CGRect commentBgPosition;
@property (nonatomic,copy) NSArray* imagePostionArray;
@property (nonatomic,strong) StatusModel* statusModel;

@end
