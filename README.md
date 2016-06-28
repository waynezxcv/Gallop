
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/waynezxcv/LWAsyncDisplayView/blob/master/LICENSE)&nbsp;


# Gallop v0.3.0
Gallop --- 强大、快速地图文混排框架。
A framework for build a smooth asynchronous iOS APP.

# About Gallop

Gallop是一个功能强大、性能优秀的图文混排框架。

## Features

主要用于解决以下需求：
* 实现图文混排界面，比如在文本中添加表情，对文字添加点击链接。Gallop还提供了方便的方法可以直接完成表情、URL链接、@用户、#话题#等的解析。
* 滚动列表的性能优化。Gallop使用异步绘制、视图层级合并、主线程Runloop空闲时执行只能在主线程完成的任务、对布局模型预先缓存等方法，能在实现复杂的图文混排界面时，仍然保持一个相当优秀的滚动性能（FPS基本保持在60HZ），项目内有使用Gallop构建的微信朋友圈Demo。
* 方便的解析HTML渲染生成原生iOS页面，项目内有使用Gallop构建的知乎日报Demo。

解析HTML渲染生成原生iOS页面的优势：

1.性能更好。
2.可以将图片缓存到本地，无需重复加载，使用UIWebView只能缓存到内存，当UIWebView释放之后，就需要重新加载。
3.可以使用原生的图片浏览器来浏览照片，体验更好，可以解决UIWebView查看大图时无法覆盖NavigationBar的问题。
4.可以根据需要对HTML的内容重新布局、设置样式，去除不需要的部分。
5.可以根据需要在内容中添加其他原生控件。

//TODO：目前只支持，文字、图片，后续会支持视频。

![](https://github.com/waynezxcv/Gallop/raw/master/pics/1.PNG)
![](https://github.com/waynezxcv/Gallop/raw/master/pics/2.png)



# Modifications

v0.3.0 
* 增加了解析HTML渲染生成原生iOS页面的功能。

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

3.生成布局模型
```objc
LWLayout* layout = [[LWLayout alloc] init];

/***  将LWstorage实例添加到layout当中  ***/
[layout addStorage:textStorage];
[layout addStorage:imamgeStorage];
```

4.创建LWAsyncDisplayView，并将LWLayout实例赋值给创建LWAsyncDisplayView对象

```objc
LWAsyncDisplayView* asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
asyncDisplayView.layout = layout;
[self.view addSubview:asyncDisplayView];


```


5.解析HTML生成iOS原生页面

```objc

/*** 创建LWHTMLDisplayView  ***/
LWHTMLDisplayView* htmlView = [[LWHTMLDisplayView alloc] initWithFrame:self.view.bounds];
htmlView.parentVC = self;
htmlView.displayDelegate = self;
[self.view addSubview:htmlView];

/***  获取LWStorageBuilder  ***/
LWStorageBuilder* builder = htmlView.storageBuilder;

/***  创建LWLayout  ***/
LWLayout* layout = [[LWLayout alloc] init];

/***  创建LWHTMLTextConfig  ***/
LWHTMLTextConfig* contentConfig = [[LWHTMLTextConfig alloc] init];
contentConfig.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
contentConfig.textColor = RGB(50, 50, 50, 1);
contentConfig.linkColor = RGB(232, 104, 96,1.0f);
contentConfig.linkHighlightColor = RGB(0, 0, 0, 0.35f);

/***  创建另一个LWHTMLTextConfig  ***/
LWHTMLTextConfig* strongConfig = [[LWHTMLTextConfig alloc] init];
strongConfig.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.0f];
strongConfig.textColor = [UIColor blackColor];


/***  通过XPath解析HTML并生成LWStorage  ***/
/***  通过UIEdgeInsets设置布局传入第二个参数 ***/
/*** 标签名对应的LWHTMLTextConfig以字典的Key-Value格式传入最后一个参数 ***/
[builder createLWStorageWithXPath:@"//div[@class='content']/p"
edgeInsets:UIEdgeInsetsMake([layout suggestHeightWithBottomMargin:10.0f], 10.0f, 10.0, 10.0f)
configDictionary:@{@"p":contentConfig,
@"strong":strongConfig,
@"em":strongConfig}];

/***  获取生成的LWStorage实例数组  ***/
NSArray* storages = builder.storages;

/***  添加到LWLayout实例  ***/
[layout addStorages:storages];

/***  给LWHTMLDisplayView对象并赋值  ***/
htmlView.layout = layout;

```

XPath教程（http://www.w3school.com.cn/xpath/index.asp）

* **如果需要更加详细的内容，请看各个头文件和Demo，有详细的注释**

# 正在不断完善中...
# 有任何问题请联系我 liuweiself@126.com

# License

Gallop is available under the MIT license. See the LICENSE file for more info.

