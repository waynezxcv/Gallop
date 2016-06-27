/*
 https://github.com/waynezxcv/Gallop

 Copyright (c) 2016 waynezxcv <liuweiself@126.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

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
