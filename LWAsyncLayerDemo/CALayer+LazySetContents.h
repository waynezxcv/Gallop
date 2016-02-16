//
//  CALayer+LazySetContents.h
//  SDWebImage
//
//  Created by 刘微 on 16/2/2.
//  Copyright © 2016年 Dailymotion. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>



@interface CALayer(LazySetContents)


/**
 *  在MainRunLoop足够空闲的情况下set内容
 */
- (void)lazySetContent:(id)contents;

@end
