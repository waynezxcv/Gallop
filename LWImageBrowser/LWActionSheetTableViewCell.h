//
//  LWActionSheetTableViewCell.h
//  WarmerApp
//
//  Created by 刘微 on 16/3/2.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWActionSheetTableViewCell : UITableViewCell

@property (nonatomic,copy) NSString* title;


- (void)show;

@end


@interface LWActionSheetTableViewCellContent : UIView

@property (nonatomic,copy) NSString* title;

@end