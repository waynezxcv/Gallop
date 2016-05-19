
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/waynezxcv/LWAsyncDisplayView/blob/master/LICENSE)&nbsp;


# Gallop v0.1.0
Gallop --- 异步绘制排版引擎，支持布局预加载缓存、支持图文混排显示，支持添加链接、支持自定义排版，自动布局。
只需要少量简单代码，就可以构建一个性能相当优秀（滚动时帧数60）的Feed流界面。
<br>

## Features
* 支持文本布局绘制预加载，并使用异步绘制的方式，保持界面的流畅性
* 支持富文本，图文混排显示，支持行间距 字间距，设置行数，自适应高度
* 支持添加属性文本，自定义链接
* 一行代码支持圆角图片，并避免离屏渲染
* 支持通过设置约束的方式自动布局
* API简单，只需设置简单的属性，复杂的多线程绘制、自动布局交给Gallop就好啦。

## Requirements
使用Gallop实现网络图片加载部分依赖于SDWebImage（https://github.com/rs/SDWebImage）
'SDWebImage', '~>3.7'

## Who Use
适合于想要快速搭建类似微信朋友圈、新浪微博Timeline等复杂的图文混排滚动界面，并对于滚动流畅性性能有一定要求的情况。

## Installation
将Gallop文件夹下的.h及.m文件添加到你的工程当中。

## Usage

 ![image](https://github.com/waynezxcv/Gallop/raw/master/pics/1.jpg)

* **API Quickstart**


### 使用示例

1.生成一个文本模型
```objc
LWTextStorage* nameTextStorage = [[LWTextStorage alloc] init];
nameTextStorage.text = @"waynezxcv";
nameTextStorage.font = [UIFont systemFontOfSize:15.0f];
nameTextStorage.textAlignment = NSTextAlignmentLeft;
nameTextStorage.linespace = 2.0f;
nameTextStorage.textColor = RGB(113, 129, 161, 1);

//为文本添加点击链接事件
[nameTextStorage addLinkWithData:data
                         inRange:NSMakeRange(0,statusModel.name.length)
                       linkColor:RGB(113, 129, 161, 1)
                  highLightColor:RGB(0, 0, 0, 0.15)
                 UnderLineStyle:NSUnderlineStyleNone];
                 
                 
//回调
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedLinkWithfData:(id)data;

//图片
/**
 *  用本地图片替换掉指定位置的文字
 *
 */
- (NSMutableAttributedString *)replaceTextWithImage:(UIImage *)image imageSize:(CGSize)size inRange:(NSRange)range;

/**
 *  用网络图片替换掉指定位置的文字
 *
 */
- (void)replaceTextWithImageURL:(NSURL *)URL imageSize:(CGSize)size inRange:(NSRange)range;

//如果想要插入图片，则将Range.length设为0即可。

//点击图片回调
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView
   didCilickedImageStorage:(LWImageStorage *)imageStorage
                     touch:(UITouch *)touch;

```
2.生成一个网络图片模型
```objc
LWImageStorage* avatarStorage = [[LWImageStorage alloc] init];
avatarStorage.type = LWImageStorageWebImage;
avatarStorage.URL = @"http://xxxxxx.jpg";
//为图片设置圆角
avatarStorage.cornerRadius = 20.0f;
avatarStorage.cornerBackgroundColor = [UIColor whiteColor];
avatarStorage.cornerBorderColor = [UIColor blackColor];
avatarStorage.cornerBorderWidth = 1.0f;
```
3.生成一个本地图片模型
```objc
LWImageStorage* menuStorage = [[LWImageStorage alloc] init];
menuStorage.type = LWImageStorageLocalImage;
menuStorage.frame = menuPosition;
menuStorage.image = [UIImage imageNamed:@"menu"];
```
4.设置约束 自动布局
```objc
[LWConstraintManager lw_makeConstraint:avatarStorage.constraint.leftMargin(10).topMargin(20).widthLength(40.0f).heightLength(40.0f)];
[LWConstraintManager lw_makeConstraint:nameTextStorage.constraint.leftMarginToStorage(avatarStorage,10).topMargin(20).widthLength(SCREEN_WIDTH)];
```
5.坐标布局
```objc
imageStorage.frame = CGRectMake(10,10,20,20);
```
6.生成布局模型
```objc
LWLayout* layout = [[LWLayout alloc] initWithContainer:container];
[layout addStorage:nameTextStorage];
[layout addStorage:avatarStorage];
```
7.创建LWAsyncDisplayView
```objc
/**
 *  初始化并设置最大ImageContainer的数量。如果用"initWithFrame"方法创建，则自动管理ImageContainers
 *  指定一个maxImageStorageCount，将避免在滚动中重复创建ImageContainer,滚动会更流畅。
 *  @param count 最大ImageStorage的数量。
 *  //例如微信朋友圈，9张图片加1个头像，最多10张图片，则设置为10
 */
LWAsyncDisplayView* asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero maxImageStorageCount:10];
```
8.将LWLayout实例赋值给创建LWAsyncDisplayView对象
```objc
asyncDisplayView.layout = layout;
```

* **如果需要更加详细的内容，请看各个头文件和Demo，有详细的注释**
*  Demo中有用Gallop构建的微信朋友圈,下载Demo真机调试。

![image](https://github.com/waynezxcv/Gallop/raw/master/pics/2.png)


![image](https://github.com/waynezxcv/Gallop/raw/master/pics/3.PNG)


## 正在不断完善中...  Enjoy~
## 有任何问题请联系我 liuweiself@126.com


## License

Gallop is available under the MIT license. See the LICENSE file for more info.

