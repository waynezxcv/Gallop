//
//  LWAsyncDisplayLayer.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AsyncDisplayHelper.h"


typedef void(^AsyncDisplayBlock)(CGContextRef context,CGSize size);

@interface LWAsyncDisplayLayer : CALayer

- (void)asyncDisplayWithBolock:(AsyncDisplayBlock) displayBlock;

@end
