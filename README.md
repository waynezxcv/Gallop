
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/waynezxcv/LWAsyncDisplayView/blob/master/LICENSE)&nbsp;


# Gallop v0.3.5

# About Gallop

Gallop是一个功能强大、性能优秀的异步绘制、图文混排框架。你只需要使用框架中抽象的LWTextStorage(相当于UIKit中的UILabel)、LWImageStorage（相当于UIKit中的UIIamgeView）模型来方便、快速地构建图文混排界面，Gallop将为你通过各种优化手段，来确保你的应用的流畅性。

## Features

主要用于解决以下需求：


* 滚动列表的性能优化,能在实现复杂的图文混排界面时，仍然保持一个相当优秀的滚动性能（FPS基本保持在60）。**项目内有使用Gallop构建的微信朋友圈Demo**
* 实现图文混排界面，比如在文本中添加表情，对文字添加点击链接。
* 简便地实现对网络图片和本地图片的圆角和模糊处理等，并能提供缓存，无需重复处理，优化性能。
* 方便的解析HTML渲染生成原生iOS页面。**项目内有使用Gallop构建的知乎日报Demo**


**滚动性能请使用真机调试查看效果**

## Demo Snapshot

![](https://github.com/waynezxcv/Gallop/raw/master/pics/1.PNG)
![](https://github.com/waynezxcv/Gallop/raw/master/pics/2.png)


***



# Modifications

v0.3.5

LWImageStorage 新增一个属性isBlur。本地图片时，将在子线程进行模糊处理；当网络图片时，将在子线程进行模糊处理并直接缓存模糊的版本。详见Demo。

v0.3.4

* 支持CoreData来缓存布局模型


v0.3.3

* 更改了集成方式，解决了与SDWebImage部分文件冲突的问题。

v0.3.2
* 现在，设置了圆角半径的网络图片将额外缓存一份，解决了内存消耗过大的问题。

v0.3.1
* 解析HTML渲染生成原生iOS页面时，图片可以按照原图比例自适应高度了。

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


```
- (void)lw_addLinkForWholeTextStorageWithData:(id)data linkColor:(UIColor *)linkColor highLightColor:(UIColor *)highLightColor;

```


废弃了方法

```
- (id)initWithFrame:(CGRect)frame maxImageStorageCount:(NSInteger)maxCount;

```

现在，LWAsyncDisplayView内部将自动维护一个复用池，可以为LWStorage设置一个NSString*类型的Identifier，
来复用内部的相关UIView,简化API。

* 修复了对文字添加链接重叠而发生冲突的bug.

***


# TODO

* 对视频、音频的支持。

*** 



# Requirements
* 使用Gallop实现网络图片加载部分依赖于[SDWebImage](https://github.com/rs/SDWebImage) 'SDWebImage', '~>3.7'
* HTML解析依赖libxml2库


# Installation

1. 在XCode的Build Phases-> Link Binary With Libraries中添加libxml2.tbd库
2. 在XCode的Build Setting->Header Search Paths中添加‘/usr/include/libxml2’
3. 安装[SDWebImage](https://github.com/rs/SDWebImage)
4. 将Gallop文件夹下的.h及.m文件添加到你的工程当中
5. #import "Gallop.h"


# Usage

## API Quickstart

1.使用LWTextStorage在文本中插入图片、添加点击事件

```
//创建LWAsyncDisplayView对象
    LWAsyncDisplayView* view = [[LWAsyncDisplayView alloc] initWithFrame:CGRectMake(0.0f,                                                                     64.0,SCREEN_WIDTH,SCREEN_HEIGHT - 64.0f)];
    //设置代理
    view.delegate = self;
    [self.view addSubview:view];
    
    //创建LWTextStorage对象
    LWTextStorage* ts = [[LWTextStorage alloc] init];
    ts.frame = CGRectMake(20, 50.0f,SCREEN_WIDTH - 40.0f, ts.suggestSize.height);
    ts.text = @"Gallop支持图文混排,可以在文字中插入本地图片→和网络图片→UIView的子类→.给指定位置文字添加链接.快来试试吧。";
    ts.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    
    UIImage* image = [UIImage imageNamed:@"pic.jpeg"];
    UISwitch* switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    
    //在文字中插入本地图片
    [ts lw_replaceTextWithImage:image
                    contentMode:UIViewContentModeScaleAspectFill
                      imageSize:CGSizeMake(40, 40)
                      alignment:LWTextAttachAlignmentTop
                          range:NSMakeRange(26, 0)];
    
    //在文字中插入网络图片
    [ts lw_replaceTextWithImageURL:[NSURL URLWithString:@"http://joymepic.joyme.com/article/uploads/20163/81460101559518330.jpeg?imageView2/1"]
                       contentMode:UIViewContentModeScaleAspectFill
                         imageSize:CGSizeMake(80, 40)
                         alignment:LWTextAttachAlignmentTop
                             range:NSMakeRange(33, 0)];
    //在文字中插入UIView的子类
    [ts lw_replaceTextWithView:switchView
                   contentMode:UIViewContentModeScaleAspectFill
                          size:switchView.frame.size
                     alignment:LWTextAttachAlignmentTop
                         range:NSMakeRange(44, 0)];
    
    //给某位置的文字添加点击事件
    [ts lw_addLinkWithData:@"链接 ：）"
                     range:NSMakeRange(53,4)
                 linkColor:[UIColor blueColor]
            highLightColor:RGB(0, 0, 0, 0.15)];
    
    //给整段文字添加点击事件
    [ts lw_addLinkForWholeTextStorageWithData:@"整段文字"
                                    linkColor:nil
                               highLightColor:RGB(0, 0, 0, 0.15)];
    
    //创建LWLayout对象
    LWLayout* layout = [[LWLayout alloc] init];
    //将LWTextStorage对象添加到LWLayout对象中
    [layout addStorage:ts];
    //将LWLayout对象赋值给LWAsyncDisplayView对象
    view.layout = layout;

//给文字添加点击事件后，若触发事件，会在这个代理方法中收到回调
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView
    didCilickedTextStorage:(LWTextStorage *)textStorage
                  linkdata:(id)data {
    if ([data isKindOfClass:[NSString class]]) {
        [LWAlertView shoWithMessage:data];
    }
}



```

2.LWTextStorage的更多用法

```
    //设置空心文字和文本外边框颜色
    LWTextStorage* ts1 = [[LWTextStorage alloc] init];
    ts1.text = @"世界对着它的爱人，把它浩翰的面具揭下了。它变小了，小如一首歌，小如一回永恒的接吻。The world puts off its mask of vastness to its lover.It becomes small as one song, as one kiss of the eternal. ";
    ts1.textDrawMode = LWTextDrawModeStroke;
    ts1.font = [UIFont fontWithName:@"Heiti SC" size:18.0f];
    ts1.strokeColor = [UIColor redColor];
    ts1.textBoundingStrokeColor = [UIColor grayColor];
    ts1.frame = CGRectMake(20.0f,20.0f,SCREEN_WIDTH - 40.0f,CGFLOAT_MAX);
    ts1.linespacing = 10.0f;
    
    //创建属性字符串，并设置各种样式
    NSMutableAttributedString* as1 = [[NSMutableAttributedString alloc] initWithString:@"世界对着它的爱人，把它浩翰的面具揭下了。它变小了，小如一首歌，小如一回永恒的接吻。The world puts off its mask of vastness to its lover.It becomes small as one song, as one kiss of the eternal."];
    [as1 setLineSpacing:7.0f range:NSMakeRange(0, as1.length)];
    [as1 setFont:[UIFont systemFontOfSize:15.0f] range:NSMakeRange(0, as1.length)];
    [as1 setTextColor:[UIColor yellowColor] range:NSMakeRange(0, 11)];
    [as1 setTextBackgroundColor:[UIColor orangeColor] range:NSMakeRange(12, 19)];
    [as1 setUnderlineStyle:NSUnderlineStyleSingle underlineColor:[UIColor greenColor] range:NSMakeRange(31, 26)];
    [as1 setFont:[UIFont systemFontOfSize:20.0f] range:NSMakeRange(31, 26)];
    [as1 setCharacterSpacing:10 range:NSMakeRange(62, 3)];
    [as1 setFont:[UIFont systemFontOfSize:20.0f] range:NSMakeRange(62, 3)];
    [as1 setTextColor:[UIColor redColor] range:NSMakeRange(62, 3)];
    [as1 setStrokeColor:[UIColor blueColor] strokeWidth:2.0f range:NSMakeRange(66, 11)];
    [as1 setFont:[UIFont systemFontOfSize:18.0f] range:NSMakeRange(66, 11)];
    [as1 setTextColor:[UIColor whiteColor] range:NSMakeRange(78, 21)];
    [as1 setTextBackgroundColor:[UIColor blackColor] range:NSMakeRange(78, 21)];
    [as1 setFont:[UIFont systemFontOfSize:25]range:NSMakeRange(78, 21)];
    [as1 setUnderlineStyle:NSUnderlineStyleDouble underlineColor:[UIColor whiteColor] range:NSMakeRange(77, 21)];
    
    //通过属性字符串个来创建LWTextStorage对象
    LWTextStorage* ts2 = [LWTextStorage
                          lw_textStrageWithText:as1
                          frame:CGRectMake(ts1.left,
                                           ts1.bottom + 20.0f,
                                           ts1.width,
                                           CGFLOAT_MAX)];
    
    
    //在一个LWTextStorage对象后拼接一个LWTextStorage对象
    LWTextStorage* ts3 = [[LWTextStorage alloc] init];
    ts3.text = @"^_^ 我是那个尾巴~";
    ts3.textColor = [UIColor redColor];
    ts3.font = [UIFont systemFontOfSize:20];
    [ts2 lw_appendTextStorage:ts3];
    
    //将图片装换成属性字符串拼接到LWTextStorage对象后
    UIImage* image = [UIImage imageNamed:@"pic.jpeg"];
    NSMutableAttributedString* as2 = [NSMutableAttributedString
                                      lw_textAttachmentStringWithContent:image
                                      contentMode:UIViewContentModeScaleAspectFill
                                      ascent:50.0f
                                      descent:0.0f
                                      width:50.0f];
    LWTextStorage* ts4 = [LWTextStorage lw_textStrageWithText:as2 frame:CGRectZero];
    [ts2 lw_appendTextStorage:ts4];
    
    
    //创建LWLayout对象
    LWLayout* layout = [[LWLayout alloc] init];
    //将LWStorage对象添加到LWLayout对象
    [layout addStorages:@[ts1,ts2]];
    //对LWAsyncDisplayView对象赋值
    view.layout = layout;


```

3.LWImageStorage的使用方法

```
    //普通的加载网络图片
    LWImageStorage* is1 = [[LWImageStorage alloc] init];
    is1.frame = CGRectMake(SCREEN_WIDTH/2 - 50.0f, ts.bottom + 10.0f, 100.0f, 100.0f);
    is1.clipsToBounds = YES;
    is1.contents = [NSURL URLWithString:@"http://img.club.pchome.net/kdsarticle/2013/11small/21/fd548da909d64a988da20fa0ec124ef3_1000x750.jpg"];
    
    //设置圆角半径和模糊效果
    LWImageStorage* is2 = [[LWImageStorage alloc] init];
    is2.frame = CGRectMake(SCREEN_WIDTH/2 - 50.0f, is1.bottom + 10.0f, 100.0f, 100.0f);
    is2.contents = [NSURL URLWithString:@"http://img.club.pchome.net/kdsarticle/2013/11small/21/fd548da909d64a988da20fa0ec124ef3_1000x750.jpg"];
    is2.cornerRadius = 50.0f;
    is2.cornerBorderWidth = 10.0f;
    is2.cornerBorderColor = [UIColor orangeColor];
    is2.isBlur = YES;
    
    LWLayout* layout = [[LWLayout alloc] init];
    [layout addStorages:@[ts,is1,is2]];
    view.layout = layout;
    
    //也可以直接对CALayer对象使用
    UIView* view2 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 50,
                                                                  64.0f + is2.bottom + 10 ,
                                                                  100,
                                                                  100)];
    [self.view addSubview:view2];
    /**
     *  指定一个圆角半径、是否模糊处理和描边颜色和宽度，SDWebImage将额外缓存一份圆角半径版本的图片
     *
     */
    [view2.layer lw_setImageWithURL:
     [NSURL URLWithString:@"http://img.club.pchome.net/kdsarticle/2013/11small/21/fd548da909d64a988da20fa0ec124ef3_1000x750.jpg"]
                   placeholderImage:nil
                       cornerRadius:10.0f
              cornerBackgroundColor:RGB(255, 255, 255, 1.0f)
                        borderColor:[UIColor yellowColor]
                        borderWidth:10.0f
                               size:CGSizeMake(100.0f, 100)
                             isBlur:NO
                            options:0
                           progress:nil
                          completed:nil];



```

4.使用Gallop来进行HTML解析

```
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

XPath教程: http://www.w3school.com.cn/xpath/index.asp

* **如果需要更加详细的内容，请看各个头文件和Demo，有详细的注释**


# 正在不断完善中...
# 有任何问题请添加issue

# License

Gallop is available under the MIT license. See the LICENSE file for more info.

