//
//  TableViewCell.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/3/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWAsyncDisplayView.h"
#import "CellLayout.h"


@class TableViewCell;

@protocol TableViewCellDelegate <NSObject>

- (void)tableViewCell:(TableViewCell *)cell didClickedImageWithCellLayout:(CellLayout *)layout atIndex:(NSInteger)index;
- (void)tableViewCell:(TableViewCell *)cell didClickedLinkWithData:(id)data;

@end

@interface TableViewCell : UITableViewCell

@property (nonatomic,weak) id <TableViewCellDelegate> delegate;
@property (nonatomic,strong) CellLayout* cellLayout;

@end


