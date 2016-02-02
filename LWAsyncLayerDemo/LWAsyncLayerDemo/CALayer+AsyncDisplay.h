//
//  CALayer+AsyncDisplay.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>




@interface CALayer(AsyncDisplay)

/**
 *  在MainRunLoop足够空闲的情况下set内容
 */
- (void)lazySetContent:(id)contents;

@end
