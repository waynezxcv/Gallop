//
//  LWTextAttach.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/23.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



typedef NS_ENUM(NSUInteger, LWTextAttachType) {
    LWTextAttachTypeLink,
    LWTextAttachTypeImage,
};

@interface LWTextAttach : NSObject

@property (nonatomic,assign) LWTextAttachType type;
@property (nonatomic,strong) id data;
@property (nonatomic,assign) NSRange range;
@property (nonatomic,assign) CGRect imagePosition;


@end
