//
//  LWTextAttach.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/23.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface LWTextAttach : NSObject

@property (nonatomic,strong) UIImage* image;
@property (nonatomic,assign) NSRange range;
@property (nonatomic,assign) CGRect imagePosition;

@end
