//
//  DisplayCell.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/21.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "DisplayCell.h"
#import "CALayer+AsyncDisplay.h"

@implementation DisplayCell


- (void)drawContent {
    [self.layer asyncDisplayWithBolock:^(CGContextRef context, CGSize size) {
        AsyncDisplayHelper* helper = [AsyncDisplayHelper sharedDisplayHelper];
        [helper draText:[NSString stringWithFormat:@"异步绘制测试 :%@",[NSThread currentThread]]
                             inRect:CGRectMake(10.0f, 10.0f, self.bounds.size.width - 20.0f, 100.0f)
                               font:[UIFont systemFontOfSize:10.0f]
                      textAlignment:NSTextAlignmentCenter
                          lineSpace:5.0f
                          textColor:[UIColor blackColor]
                            context:context];
    }];
}

@end
