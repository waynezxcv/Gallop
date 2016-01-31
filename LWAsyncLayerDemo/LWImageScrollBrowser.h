//
//  LWImageScrollBrowser.h
//  Warmjar2
//
//  Created by 刘微 on 15/10/6.
//  Copyright © 2015年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWImageModel.h"


@protocol LWImageScrollBrowserDelegate <NSObject>


@optional
- (void)imageBrowserDidFnishDownloadImageToRefreshThumbnialImageIfNeed;

@end

@interface LWImageScrollBrowser : UIView

@property (nonatomic,weak)id <LWImageScrollBrowserDelegate>delegate;
@property (nonatomic,copy) NSArray* modelArray;

- (id)initWithModelArray:(NSArray *)modelArray currentIndex:(NSInteger)currentIndex;
- (void)show;

@end
