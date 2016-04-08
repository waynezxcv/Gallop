//
//  LWStorage.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWStorage.h"

@implementation LWStorage


- (CGFloat)left {
    return self.frame.origin.x;
}

- (CGFloat)right {
    return  self.frame.origin.x + self.width;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.height;
}

@end
