//
//  FHMagPhotoContainer.h
//  FHMagProject
//
//  Created by 刘微 on 15/10/4.
//  Copyright © 2015年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWImageModel.h"
#import "ItemModel.h"


@class FHMagPhotoContainer;

@protocol FHMagPhotoContainerDelegate <NSObject>

- (void)didSelectedImageAtIndex:(NSInteger)index imageModelArray:(NSArray *)modelsArray itemModel:(ItemModel *)itemModel;

@end

@interface FHMagPhotoContainer : UIView

@property (nonatomic,weak) id <FHMagPhotoContainerDelegate> delegate;
@property (nonatomic,copy) NSDictionary* imageDict;
@property (nonatomic,assign) CGFloat imageWidth;
@property (nonatomic,copy) NSArray* URLArray;
@property (nonatomic,strong) ItemModel* itemModel;

- (void)cleanUp;
@end
