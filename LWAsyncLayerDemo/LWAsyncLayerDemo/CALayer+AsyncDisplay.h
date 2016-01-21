//
//  CALayer+AsyncDisplay.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/21.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AsyncDisplayHelper.h"


typedef void(^AsyncDisplayBlock)(CGContextRef context,CGSize size);

@interface CALayer(AsyncDisplay)

- (void)asyncDisplayWithBolock:(AsyncDisplayBlock) displayBlock;

@end
