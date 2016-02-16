//
//  DiscoverLayout.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiscoverStatuModel.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "LWTextLayout.h"

@interface DiscoverLayout : NSObject

@property (nonatomic,strong) DiscoverStatuModel* statusModel;

@property (nonatomic,strong) LWTextLayout* nameTextLayout;
@property (nonatomic,strong) LWTextLayout* textTextLayout;
@property (nonatomic,strong) LWTextLayout* timeStampTextLayout;


@property (nonatomic,assign) CGRect avatarPosition;
@property (nonatomic,assign) CGRect imagesPosition;
@property (nonatomic,assign) CGRect menuPosition;
@property (nonatomic,assign) CGRect likesAndCommentsPosition;
@property (nonatomic,copy) NSArray* imagePostionArray;

@property (nonatomic,assign) CGFloat textHeight;
@property (nonatomic,assign) CGFloat imagesHeight;
@property (nonatomic,assign) CGFloat likesAndCommentsHeight;
@property (nonatomic,assign) CGFloat cellHeight;

- (id)initWithStatusModel:(DiscoverStatuModel *)statuModel;

@end
