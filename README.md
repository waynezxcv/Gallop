# LWAsyncDisplayView
LWAsyncDisplayView 轻量级的属性文本 异步绘制 的控件，支持布局预加载缓存、支持图文混排显示，支持添加链接、支持自定义排版显示，<br>

## Features
* 支持文本布局绘制预加载，并使用异步绘制的方式，保持界面的流畅性
* 支持富文本，图文混排显示，支持行间距 字间距，设置行数，自适应高度
* 支持添加属性文本，自定义链接


## Usage
### API Quickstart

* **Class  **

|Class | Function|
|--------|---------|
|LWRunLoopObserver、CALayer+LazySetContents、UIImageView+LazySetContents|把设置Contents的操作尽量推后，只在主线程RunLoop空闲的时候设置Contents，来满足滚动的流畅性|
|LWTextLayout|文本布局的预加载类，缓存起来，把计算布局的时间提前，减少绘制图片时的计算时间|
|LWAsyncDisplayView、LWAsyncDisplayLayer|在子线程中实现界面的渲染，保证主线程的流畅性|
|LWTextAttach|图文混排时的图片附件|

如果需要更加详细的内容，请看各个头文件，有详细的注释

* **Example**




### Delegate
