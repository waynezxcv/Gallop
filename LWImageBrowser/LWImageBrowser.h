//
//  LWImageBrowser.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWImageBrowserModel.h"
#import "LWImageItem.h"



/**
 *  图片浏览器式样
 */
typedef NS_ENUM(NSUInteger, LWImageBrowserShowAnimationStyle){
    LWImageBrowserAnimationStyleScale,
    LWImageBrowserAnimationStylePush,
};

/**
 *  LWImageBrowser协议
 */
@protocol LWImageBrowserDelegate <NSObject>


@optional
/**
 *  下载完高清图片后，会通过此方法通知
 */
- (void)imageBrowserDidFnishDownloadImageToRefreshThumbnialImageIfNeed;



@end


/**
 *  图片浏览器
 */
@interface LWImageBrowser : UIViewController

@property (nonatomic,weak) id <LWImageBrowserDelegate> delegate;

/**
 *  浏览器式样
 */
@property (nonatomic,assign) LWImageBrowserShowAnimationStyle style;


/**
 *  浏览器背景式样
 */
//@property (nonatomic,assign) LWImageBrowserBackgroundStyle backgroundStyle;

/**
 *  存放图片模型的数组
 */
@property (nonatomic,copy)NSArray* imageModels;

/**
 *  当前页码
 */
@property (nonatomic,assign) NSInteger currentIndex;


/**
 *  当前的ImageItem
 */
@property (nonatomic,strong) LWImageItem* currentImageItem;


/**
 *  创建并初始化一个LWImageBrowser
 *
 *  @param parentVC    父级ViewController
 *  @param style       图片浏览器式样
 *  @param imageModels 一个存放LWImageModel的数组
 *  @param index       初始化的图片的Index
 *
 */
- (id)initWithParentViewController:(UIViewController *)parentVC
                             style:(LWImageBrowserShowAnimationStyle)style
                       imageModels:(NSArray *)imageModels
                      currentIndex:(NSInteger)index;

/**
 *  显示图片浏览器
 */
- (void)show;


@end
