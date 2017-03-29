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





#ifndef GallopDefine_h
#define GallopDefine_h

//屏幕宽
#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#endif


//屏幕高
#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#endif


//屏幕大小
#ifndef SCREEN_BOUNDS
#define SCREEN_BOUNDS [UIScreen mainScreen].bounds
#endif


//通过RGB返回UIColor
#ifndef RGB
#define RGB(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#endif

//DEBUG模式下打印
#ifdef DEBUG
#define NSLog(...) NSLog(@"\n ---- \n [FUNC:%s 第%d行] \n [LOG:%@] \n ---- \n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define NSLog(...)
#endif


//获取iOS版本号
#ifndef IOS_VERSION
#define IOS_VERSION [[UIDevice currentDevice] systemVersion] floatValue]
#endif


//获取App版本号
#ifndef APP_VERSION
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#endif


//获取标准NSUserDefaults单例对象
#ifndef STANDARD_USER_DEFAULTS
#define STANDARD_USER_DEFAULTS [NSUserDefaults standardUserDefaults]
#endif


//获取沙盒Document路径
#ifndef SAND_BOX_DOCUMENT_PATH
#define SAND_BOX_DOCUMENT_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#endif


//获取沙盒Temp路径
#ifndef SAND_BOX_TEMP_PATH
#define SAND_BOX_TEMP_PATH NSTemporaryDirectory()
#endif


//获取沙盒Cache路径
#ifndef SAND_BOX_CACHE_PATH
#define SAND_BOX_CACHE_PATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
#endif







/******************************************************************************/
@class LWImageStorage;
typedef BOOL(^LWAsyncDisplayIsCanclledBlock)(void);
typedef void(^LWAsyncDisplayWillDisplayBlock)(CALayer *layer);
typedef void(^LWAsyncDisplayBlock)(CGContextRef context, CGSize size, LWAsyncDisplayIsCanclledBlock isCancelledBlock);
typedef void(^LWAsyncDisplayDidDisplayBlock)(CALayer *layer, BOOL finished);
typedef void(^LWHTMLImageResizeBlock)(LWImageStorage*imageStorage, CGFloat delta);
typedef void(^LWAsyncCompleteBlock)(void);
typedef void(^LWWebImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL* targetURL);
typedef void(^LWWebImageDownloaderCompletionBlock)(UIImage* image,NSData* imageData,NSError* error);
/******************************************************************************/


#endif /* GallopDefine_h */
