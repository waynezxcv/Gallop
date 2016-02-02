//
//  CALayer+AsyncDisplay.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "CALayer+AsyncDisplay.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "LWRunLoopObserver.h"

@implementation CALayer(AsyncDisplay)


- (void)lazySetContent:(id)contents {
    LWRunLoopObserver* obeserver = [LWRunLoopObserver observerWithTarget:self
                                                                selector:@selector(setContents:)
                                                                  object:contents];
    [obeserver commit];
}

@end
