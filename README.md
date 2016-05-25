
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/waynezxcv/LWAsyncDisplayView/blob/master/LICENSE)&nbsp;


# Gallop v0.2.1
Gallop --- 异步绘制排版引擎，支持布局预加载缓存、支持图文混排显示，支持添加链接、支持自定义排版，自动布局。
只需要少量简单代码，就可以构建一个性能相当优秀（滚动时帧数60）的图文混排界面。
<br>

## Features
* 支持文本布局绘制预加载，并使用异步绘制的方式，保持界面的流畅性
* 支持富文本，图文混排显示，支持行间距 字间距，设置行数，自适应高度
* 支持添加属性文本，自定义链接
* 支持在子线程圆角图片，并避免离屏渲染
* 支持通过设置约束的方式自动布局
* API简单，只需设置简单的属性，其余交给Gallop就好啦。

## Requirements
使用Gallop实现网络图片加载部分依赖于SDWebImage（https://github.com/rs/SDWebImage）
'SDWebImage', '~>3.7'

## Who Use
适合于想要快速搭建类似微信朋友圈、新浪微博Timeline等复杂的图文混排滚动界面，并对于滚动流畅性性能有一定要求的情况。

## Installation
将Gallop文件夹下的.h及.m文件添加到你的工程当中。

```objc
#import "Gallop.h"
```

## Usage

 ![image](https://github.com/waynezxcv/Gallop/raw/master/pics/1.jpg)

* **API Quickstart**


### 使用示例

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
LWAsyncDisplayView* asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero maxImageStorageCount:10];
asyncDisplayView.layout = layout;
[self.view addSubview:asyncDisplayView];

```


* **如果需要更加详细的内容，请看各个头文件和Demo，有详细的注释**
*  Demo中有用Gallop构建的微信朋友圈,下载Demo真机调试。

![image](https://github.com/waynezxcv/Gallop/raw/master/pics/2.png)
![image](https://github.com/waynezxcv/Gallop/raw/master/pics/3.PNG)



## 正在不断完善中...
## 有任何问题请联系我 liuweiself@126.com



## License

Gallop is available under the MIT license. See the LICENSE file for more info.

