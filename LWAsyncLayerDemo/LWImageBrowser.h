//
//  LWImageBrowser.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWImageBrowserModel.h"


@protocol LWImageBrowserDelegate <NSObject>

- (void)imageBrowserDidFnishDownloadImageToRefreshThumbnialImageIfNeed;

@end



@interface LWImageBrowser : UIViewController

@property (nonatomic,copy)NSArray* imageModels;

- (id)initWithModelArray:(NSArray *)modelArray currentIndex:(NSInteger)currentIndex;

- (void)show;

@end
