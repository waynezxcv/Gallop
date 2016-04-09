
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






* **如果需要更加详细的内容，请看各个头文件和Demo，有详细的注释**

## 有任何问题请联系我 liuweiself@126.com

