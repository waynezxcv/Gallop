//
//  LWAutoLayout.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWTextStorage.h"
#import "LWImageStorage.h"


@interface LWLayout : NSObject

@property (nonatomic,copy) NSArray<LWTextStorage *>* textStorages;
@property (nonatomic,copy) NSArray<LWImageStorage *>* imageStorages;


- (id)initWithTextStorages:(NSArray<LWTextStorage *>*)textStorages
             imageStorages:(NSArray<LWImageStorage *>*)imageStorages;

@end
