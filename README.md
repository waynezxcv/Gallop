
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/waynezxcv/LWAsyncDisplayView/blob/master/LICENSE)&nbsp;

# Gallop v0.6.2

## About 

Gallop is a powerful rich text framework that support Asynchronous display.
It encapsulates CoreText's rich text functions and commonly used image processing capabilities.
just need use LWTextStorage object instead of UILabel object and use LWImageStorage object instead of UIImageView object,Gallop will make sure your app scroll smoothly.
You can also use Gallop to parse HTML pages and customize machining to parse HTML pages into iOS native pages.


## Architecture

![](https://github.com/waynezxcv/Gallop/raw/master/pics/architecture.png)


## Features

* use Gallop Building complex rich text interface application, can get a great experience.
* you can easy to insert local images,web images or UIView object in the text.
* easily add click and long press events to the text.
* easily draw text frame bouding, drawing the hollow words, sets the text vertical Alignment property, etc
* easy to parse the expression in the text, like http(s) link, @ user, # theme #, phone number.
* fast to sets the image corner radius property and blur processing, can be processed directly after the image to provide a cache, without repeated processing, improve performance.
* support GIF.


## Requirements

* iOS 8.0 or later


## Dependency

* web image download and cache depends on [SDWebImage](https://github.com/rs/SDWebImage) 'SDWebImage', '~> 4.0'.
* HTML parsing depends on the libxml2 library.

## Installation

1. Add the libxml2.tbd library to XCode's Build Phases-> Link Binary With Libraries.
2. Add '/ usr / include / libxml2' to XCode's Build Setting-> Header Search Paths.
3. Install [SDWebImage](https://github.com/rs/SDWebImage).
4. Add the .h and .m files under the Gallop folder to your project.
5. #import "Gallop.h".



## Modifications

v0.6.2

* fixed bug 


v0.6.0

* depend on SDWebImage 4.0
* fixed bugs.

v0.5.1

* Use "- (id)initWithCallbackQueue:(dispatch_queue_t)callbackQueue" istead of "- (LWTransaction *)initWithCallbackQueue:(dispatch_queue_t)callbackQueue".
* Use "+ (id)mainTransactionGroup;" instead of "+ (LWTransactionGroup *)mainTransactionGroup;".
* modifies the return value type ,because it's conflict with FMDB


v0.3.7
* Fixed an issue where the LWImageStorage object "contentMode" property setting was invalid.


v0.3.6

* You can set the number of lines of text by property "maxNumberOfLines" of LWTextStorage object.
* You can use the LWTextStorage property "VericalAlignment" to set the text vertical alignment.


v0.3.5
* LWImageStorage add blur property.


v0.3.4
* Support cache layout model by CoreData.


v0.3.3
* Changed the integration, to solve the problem with the SDWebImage part of the file conflict.

v0.3.2
* Now, set the corner radius of the web image will be an additional cache, to solve the problem of excessive memory consumption.

v0.3.1
* Parsing HTML rendering to generate native iOS webpage, the image can be adjusted according to the original image height.

v0.3.0 
* Added the ability to parse HTML rendering to generate native iOS pages.

v0.2.5
* Optimized for image loading.

v0.2.4
* add classed TransactionGroup，LWTransaction，CALayer+LWTransaction.

v0.2.2 
* Now, LWAsyncDisplayView internal will automatically maintain a reuse pool, you can set  LWStorage a Identifier property,To reuse the internal associated UIView object.
* Fixed a bug that caused the link to overlap with the text.


## API Quickstart

1.Use LWTextStorage object to insert a image in the text and add a click event.


```objc

//create a LWAsyncDisplayView object
LWAsyncDisplayView* view = [[LWAsyncDisplayView alloc] initWithFrame:CGRectMake(0.0f,64.0,SCREEN_WIDTH,SCREEN_HEIGHT - 64.0f)];
view.delegate = self;
[self.view addSubview:view];

//create a LWTextStorage object
LWTextStorage* ts = [[LWTextStorage alloc] init];
ts.frame = CGRectMake(20, 50.0f,SCREEN_WIDTH - 40.0f, ts.suggestSize.height);
ts.text = @"Gallop支持图文混排,可以在文字中插入本地图片→和网络图片→UIView的子类→.给指定位置文字添加链接.快来试试吧。";
ts.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
UIImage* image = [UIImage imageNamed:@"pic.jpeg"];
UISwitch* switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];

//insert a local image in the text
[ts lw_replaceTextWithImage:image
contentMode:UIViewContentModeScaleAspectFill
imageSize:CGSizeMake(40, 40)
alignment:LWTextAttachAlignmentTop
range:NSMakeRange(26, 0)];

//insert a web image in the text
[ts lw_replaceTextWithImageURL:[NSURL URLWithString:@"http://joymepic.joyme.com/article/uploads/20163/81460101559518330.jpeg?imageView2/1"]
contentMode:UIViewContentModeScaleAspectFill
imageSize:CGSizeMake(80, 40)
alignment:LWTextAttachAlignmentTop
range:NSMakeRange(33, 0)];


//inser a UIView object in the text
[ts lw_replaceTextWithView:switchView
contentMode:UIViewContentModeScaleAspectFill
size:switchView.frame.size
alignment:LWTextAttachAlignmentTop
range:NSMakeRange(44, 0)];

//add a click event in the text
[ts lw_addLinkWithData:@"链接 ：）"
range:NSMakeRange(53,4)
linkColor:[UIColor blueColor]
highLightColor:RGB(0, 0, 0, 0.15)];

[ts lw_addLinkForWholeTextStorageWithData:@"整段文字"
highLightColor:RGB(0, 0, 0, 0.15)];

//add a long press event in the text

[ts lw_addLongPressActionWithData:@"longPress"
highLightColor:RGB(0, 0, 0, 0.25f)];


//create a LWLayout object
LWLayout* layout = [[LWLayout alloc] init];
[layout addStorage:ts];

//set LWLayout object to the LWAsyncDisplayView object
view.layout = layout;



//click and long press event call back
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView
didCilickedTextStorage:(LWTextStorage *)textStorage
linkdata:(id)data {
if ([data isKindOfClass:[NSString class]]) {
[LWAlertView shoWithMessage:data];
}
}


```


2.More usage about LWTextStorage

```objc

//create a LWTextStorage object with NSMutableAttributedString object

NSMutableAttributedString* as1 = [[NSMutableAttributedString alloc] initWithString:@"世界对着它的爱人，把它浩翰的面具揭下了。它变小了，小如一首歌，小如一回永恒的接吻。"];
[as1 setTextBackgroundColor:[UIColor orangeColor] range:NSMakeRange(0, 9)];
[as1 setTextColor:[UIColor whiteColor] range:NSMakeRange(0, 9)];
[as1 setTextColor:[UIColor blackColor] range:NSMakeRange(9, as1.length - 9)];
[as1 setUnderlineStyle:NSUnderlineStyleDouble underlineColor:[UIColor blueColor]
range:NSMakeRange(9, as1.length - 9)];

LWTextStorage* ts1 = [LWTextStorage lw_textStrageWithText:as1
frame:CGRectMake(20.0f,
ts.bottom + 20.0f,
SCREEN_WIDTH - 40.0f,
CGFLOAT_MAX)];
ts1.font = [UIFont fontWithName:@"Heiti SC" size:18.0f];
ts1.linespacing = 3.0f;


LWTextStorage* ts2 = [[LWTextStorage alloc] initWithFrame:CGRectMake(20.0f,
ts1.bottom + 20.0f,
SCREEN_WIDTH - 40.0f,
CGFLOAT_MAX)];
ts2.text = @"The world puts off its mask of vastness to its lover.It becomes small as one song, as one kiss of the eternal.";
ts2.textDrawMode = LWTextDrawModeStroke;
ts2.strokeColor = [UIColor redColor];
ts2.font = [UIFont fontWithName:@"Heiti SC" size:18.0f];
ts2.linespacing = 5.0f;
ts2.textBoundingStrokeColor = [UIColor grayColor];


//append a LWTextStorage object after another one

LWTextStorage* ts3 = [[LWTextStorage alloc] init];
ts3.text = @"^_^ 我是那个尾巴~";
ts3.textColor = [UIColor redColor];
ts3.font = [UIFont systemFontOfSize:20];
[ts2 lw_appendTextStorage:ts3];


UIImage* image = [UIImage imageNamed:@"pic.jpeg"];
NSMutableAttributedString* as2 = [NSMutableAttributedString
lw_textAttachmentStringWithContent:image
contentMode:UIViewContentModeScaleAspectFill
ascent:50.0f
descent:0.0f
width:50.0f];
LWTextStorage* ts4 = [LWTextStorage lw_textStrageWithText:as2 frame:CGRectZero];
[ts2 lw_appendTextStorage:ts4];


```

3.Usage of LWImageStorage

```objc

//down load web image with LWImageStorage object

LWImageStorage* is1 = [[LWImageStorage alloc] init];
is1.frame = CGRectMake(SCREEN_WIDTH/2 - 50.0f, ts.bottom + 10.0f, 100.0f, 100.0f);
is1.clipsToBounds = YES;
is1.contents = [NSURL URLWithString:@"http://img.club.pchome.net/kdsarticle/2013/11small/21/fd548da909d64a988da20fa0ec124ef3_1000x750.jpg"];


//set corner radius and blur property

LWImageStorage* is2 = [[LWImageStorage alloc] init];
is2.frame = CGRectMake(SCREEN_WIDTH/2 - 50.0f, is1.bottom + 10.0f, 100.0f, 100.0f);
is2.contents = [NSURL URLWithString:@"http://img.club.pchome.net/kdsarticle/2013/11small/21/fd548da909d64a988da20fa0ec124ef3_1000x750.jpg"];
is2.cornerRadius = 50.0f;
is2.cornerBorderWidth = 10.0f;
is2.cornerBorderColor = [UIColor orangeColor];
is2.isBlur = YES;

```

4.Use Gallop to parsing HTML

```objc

//create a LWHTMLDisplayView object

LWHTMLDisplayView* htmlView = [[LWHTMLDisplayView alloc] initWithFrame:self.view.bounds];
htmlView.parentVC = self;
htmlView.displayDelegate = self;
[self.view addSubview:htmlView];

// get LWStorageBuilder object
LWStorageBuilder* builder = htmlView.storageBuilder;

// create a LWLayout object
LWLayout* layout = [[LWLayout alloc] init];

//create a LWHTMLTextConfig object
LWHTMLTextConfig* contentConfig = [[LWHTMLTextConfig alloc] init];
contentConfig.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
contentConfig.textColor = RGB(50, 50, 50, 1);
contentConfig.linkColor = RGB(232, 104, 96,1.0f);
contentConfig.linkHighlightColor = RGB(0, 0, 0, 0.35f);


//create LWStorage object with XPath

[builder createLWStorageWithXPath:@"//div[@class='content']/p"
edgeInsets:UIEdgeInsetsMake([layout suggestHeightWithBottomMargin:10.0f], 10.0f, 10.0, 10.0f)
configDictionary:@{@"p":contentConfig,
@"strong":strongConfig,
@"em":strongConfig}];

NSArray* storages = builder.storages;
[layout addStorages:storages];

htmlView.layout = layout;


```



## License

* Gallop is available under the MIT license. See the LICENSE file for more info.





*** 





