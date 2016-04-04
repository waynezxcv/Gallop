
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/waynezxcv/LWAsyncDisplayView/blob/master/LICENSE)&nbsp;


# LWAsyncDisplayView V0.2
LWAsyncDisplayView 轻量级的属性文本 异步绘制 的控件，支持布局预加载缓存、支持图文混排显示，支持添加链接、支持自定义排版。使用在UITableViewCell上时，滚动时可以保持帧数在60<br>

## Features
* 支持文本布局绘制预加载，并使用异步绘制的方式，保持界面的流畅性
* 支持富文本，图文混排显示，支持行间距 字间距，设置行数，自适应高度
* 支持添加属性文本，自定义链接



## Usage
### API Quickstart

* **Class**

|Class | Function|
|--------|---------|
|LWTextLayout|文本布局的预加载类，缓存起来，把计算布局的时间提前，减少绘制图片时的计算时间|
|LWAsyncDisplayView、LWAsyncDisplayLayer|在子线程中实现界面的渲染，保证主线程的流畅性|
|LWTextAttach|图文混排时的图片附件|


* **简单的使用示例**

```objc
    //创建一个LWTextLayout实例（要实现更多的布局，可以继承LWTextLayout，并添加相关属性）
    LWTextLayout* textLayout = [[LWTextLayout alloc] init];
    textLayout.text = @"使用LWAsyncDisplayView来实现图文混排[微笑]，和点击链接，很简单。并且异步绘制与预加载缓存布局，能保证界面滚动的流畅性~";
    textLayout.font = [UIFont systemFontOfSize:15.0f];
    textLayout.textColor = RGB(40, 40, 40, 1);
    textLayout.boundsRect = CGRectMake(60.0f,50.0f,SCREEN_WIDTH - 80.0f,MAXFLOAT);
    //生成CTFrameRef
    [textLayout creatCTFrameRef];
    //图文混排
    [textLayout replaceTextWithImage:[UIImage imageNamed:@"微笑"] inRange:NSMakeRange(27, 4)];
    //点击链接
    [textLayout addLinkWithData:@"点击链接"
                                 inRange:NSMakeRange(30,4)
                               linkColor:[UIColor redColor]
                          highLightColor:[UIColor grayColor]
                          UnderLineStyle:NSUnderlineStyleSingle];
    //创建一个LWAsyncDisplayView实例
    LWAsyncDisplayView* view = [[LWAsyncDisplayView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,textLayout.textHeight)];
    //赋值，开始异步绘制
    view.layouts = @[textLayout];
    [self.view addSubview:self.label];
    
    //Delegate
    //点击链接文本回调
    - (void)lwAsyncDicsPlayView:(LWAsyncDisplayView *)lwLabel didCilickedLinkWithfData:(id)data {
      //something you want to do with data...
     }
     //额外的绘制可以使用UIGraphics写在这里...
  - (void)extraAsyncDisplayIncontext:(CGContextRef)context size:(CGSize)size {
      //一些额外的绘制工作
     }

```

* **如果需要更加详细的内容，请看各个头文件和Demo，有详细的注释**

## 如果觉得有帮助，请点个Star~谢谢。。 有任何问题请联系我 liuweiself@126.com

