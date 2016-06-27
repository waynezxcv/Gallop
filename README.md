
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/waynezxcv/LWAsyncDisplayView/blob/master/LICENSE)&nbsp;


# Gallop v0.3.0
Gallop --- 强大、快速地图文混排框架。
A framework for build a smooth asynchronous iOS APP.

# About Gallop

Gallop是一个功能强大、性能优秀的图文混排框架。

## Features

主要用于解决以下需求：
* 实现图文混排界面，比如在文本中添加表情，对文字添加点击链接。Gallop还提供了方便的方法可以直接完成表情、URL链接、@用户、#话题#等的解析。
* 滚动列表的性能优化。Gallop使用异步绘制、视图层级合并、主线程Runloop空闲时执行只能在主线程完成的任务、对布局模型预先缓存等方法，能在实现复杂的图文混排界面时，仍然保持一个相当优秀的滚动性能（FPS基本保持在60HZ）。
* 方便的解析HTML生成原生iOS页面。

![](https://github.com/waynezxcv/Gallop/raw/master/pics/1.png)  

![](https://github.com/waynezxcv/Gallop/raw/master/pics/2.png)  

# Modifications

v0.3.0 
* 增加了解析HTML生成原生iOS页面的功能。

v0.2.5
* 对图片加载进行了优化。

v0.2.4
* 增加了TransactionGroup，LWTransaction，CALayer+LWTransaction。

v0.2.3 
* 文字添加了描边绘制模式。

v0.2.2 
* 增加了一个方法 
“- (void)lw_addLinkForWholeTextStorageWithData:(id)data linkColor:(UIColor *)linkColor highLightColor:(UIColor *)highLightColor;”
* 废弃了方法“- (id)initWithFrame:(CGRect)frame maxImageStorageCount:(NSInteger)maxCount;"
现在，LWAsyncDisplayView内部将自动维护一个复用池，可以为LWStorage设置一个NSString*类型的Identifier，
来复用内部的相关UIView,简化API。
* 修复了对文字添加链接重叠而发生冲突的bug.


# Requirements
* 使用Gallop实现网络图片加载部分依赖于SDWebImage（https://github.com/rs/SDWebImage）'SDWebImage', '~>3.7'
* HTML解析依赖libxml2库


# Installation
1. 将Gallop文件夹下的.h及.m文件添加到你的工程当中。
2. 在XCode的Build Phases-> Link Binary With Libraries中添加libxml2.tbd库
3. 在XCode的Build Setting->Header Search Paths中添加‘/usr/include/libxml2’
4. #import "Gallop.h"
 

# Usage

## API Quickstart

```objc
#import "Gallop.h"
```

1.生成一个文本模型


```objc
LWTextStorage* textStorage = [[LWTextStorage alloc] init];
textStorage.text = @"waynezxcv";
textStorage.font = [UIFont systemFontOfSize:15.0f];
textStorage.textColor = RGB(113, 129, 161, 1);

/***  为文本添加点击链接事件  ***/
[textStorage addLinkWithData:data
inRange:NSMakeRange(0,statusModel.name.length)
linkColor:RGB(113, 129, 161, 1)
highLightColor:RGB(0, 0, 0, 0.15)];

/***  点击链接回调  ***/
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedLinkWithfData:(id)data;

/***  用本地图片替换掉指定位置的文字  ***/
[textStorage lw_replaceTextWithImage:[UIImage imageNamed:@"img"]
contentMode:UIViewContentModeScaleAspectFill
imageSize:CGSizeMake(60, 60)
alignment:LWTextAttachAlignmentTop
range:NSMakeRange(webImageTextStorage.text.length - 7, 0)];


/***  用网络图片替换掉指定位置的文字  ***/
[textStorage lw_replaceTextWithImageURL:[NSURL URLWithString:@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460"]
contentMode:UIViewContentModeScaleAspectFill
imageSize:CGSizeMake(60, 60)
alignment:LWTextAttachAlignmentTop
range:NSMakeRange(webImageTextStorage.text.length - 7, 0)];

/***  用UIView替换掉指定位置的文字  ***/
[textStorage lw_replaceTextWithView:[[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60.0f, 30.0f)]
contentMode:UIViewContentModeScaleAspectFill
size:CGSizeMake(60.0f, 30.0f)
alignment:LWTextAttachAlignmentTop
range:NSMakeRange(1,0)];

```

2.生成一个图片模型
```objc

/***  本地图片  ***/
LWImageStorage* imamgeStorage = [[LWImageStorage alloc] init];
imamgeStorage.contents = [UIImage imageNamed:@"pic.jpeg"];
imamgeStorage.frame = CGRectMake(textStorage.left, textStorage.bottom + 20.0f, 80, 80);
imamgeStorage.cornerRadius = 40.0f;//设置圆角半径


/***  网络图片  ***/
LWImageStorage* imamgeStorage = [[LWImageStorage alloc] init];
imamgeStorage.contents = [NSURL URLWithString:@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460"];
imamgeStorage.frame = CGRectMake(textStorage.left, textStorage.bottom + 20.0f, 80, 80);
imamgeStorage.cornerRadius = 40.0f;

/***  点击图片回调  ***/
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedImageStorage:(LWImageStorage *)imageStorage touch:(UITouch *)touch;

```

3.设置约束 自动布局
```objc
[LWConstraintManager lw_makeConstraint:textStorage.constraint.leftMargin(10).topMargin(20).widthLength(40.0f).heightLength(40.0f)];
[LWConstraintManager lw_makeConstraint:imamgeStorage.constraint.leftMarginToStorage(textStorage,10).topMargin(20).widthLength(SCREEN_WIDTH)];
```

4.生成布局模型
```objc
LWLayout* layout = [[LWLayout alloc] init];

/***  将LWstorage实例添加到layout当中  ***/
[layout addStorage:textStorage];
[layout addStorage:imamgeStorage];
```

5.创建LWAsyncDisplayView，并将LWLayout实例赋值给创建LWAsyncDisplayView对象

```objc
LWAsyncDisplayView* asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
asyncDisplayView.layout = layout;
[self.view addSubview:asyncDisplayView];


```
* **如果需要更加详细的内容，请看各个头文件和Demo，有详细的注释**


# 正在不断完善中...
# 有任何问题请联系我 liuweiself@126.com

# License

Gallop is available under the MIT license. See the LICENSE file for more info.

