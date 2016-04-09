
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/waynezxcv/LWAsyncDisplayView/blob/master/LICENSE)&nbsp;


# Gallop V1.0
Gallop --- 异步绘制排版框架，支持布局预加载缓存、支持图文混排显示，支持添加链接、支持自定义排版，自动布局。
使用在UITableViewCell上时，构建复杂的界面,滚动时可以保持帧数在60。
<br>

## Features
* 支持文本布局绘制预加载，并使用异步绘制的方式，保持界面的流畅性
* 支持富文本，图文混排显示，支持行间距 字间距，设置行数，自适应高度
* 支持添加属性文本，自定义链接
* 支持通过设置约束的方式自动布局
* API简单，只需设置简单的属性，复杂的多线程绘制、自动布局交给Gallop就好啦。


使用Gallop实现网络图片加载部分依赖于SDWebImage（https://github.com/rs/SDWebImage）


## Usage

* **Class**

|Class | Function|
|--------|---------|
|LWAsyncDisplayView|在子线程中实现界面的渲染，保证主线程的流畅性|
|LWStorage、LWTextStorage、LWImageStorage|LWAsyncDisplayView的模型|
|LWConstraintManager|实现设置约束自动布局|


* **API Quickstart**
请看各个头文件和Demo，有详细的注释

### 使用示例
以微信朋友圈布局为例，使用LWAsyncDisplayView来构建UITableViewCell,示例多种API使用方式

```objc
    /********生成Storage 相当于模型***********/
    /********LWAsyncDisplayView用将所有文本跟图片的模型都抽象成LWStorage，方便你能预先将所有的需要计算的布局内容直接缓存起来***/
    /*******而不是在渲染的时候才进行计算,提高性能，以空间换时间*********/
    //头像模型 avatarImageStorage
    LWImageStorage* avatarStorage = [[LWImageStorage alloc] init];
    avatarStorage.type = LWImageStorageWebImage;
    avatarStorage.URL = statusModel.avatar;

    //名字模型 nameTextStorage
    LWTextStorage* nameTextStorage = [[LWTextStorage alloc] init];
    nameTextStorage.text = statusModel.name;
    nameTextStorage.font = [UIFont systemFontOfSize:15.0f];
    nameTextStorage.textAlignment = NSTextAlignmentLeft;
    nameTextStorage.linespace = 2.0f;
    nameTextStorage.textColor = RGB(113, 129, 161, 1);


    //正文内容模型 contentTextStorage
    LWTextStorage* contentTextStorage = [[LWTextStorage alloc] init];
    contentTextStorage.text = statusModel.content;
    contentTextStorage.font = [UIFont systemFontOfSize:15.0f];
    contentTextStorage.textColor = RGB(40, 40, 40, 1);
    contentTextStorage.linespace = 2.0f;

    /***********************************  设置约束 自动布局 *********************************************/
    [LWConstraintManager lw_makeConstraint:avatarStorage.constraint.leftMargin(10).topMargin(20).widthLength(40.0f).heightLength(40.0f)];
    [LWConstraintManager lw_makeConstraint:nameTextStorage.constraint.leftMarginToStorage(avatarStorage,10).topMargin(20).widthLength(SCREEN_WIDTH)];
    [LWConstraintManager lw_makeConstraint:contentTextStorage.constraint.leftMarginToStorage(avatarStorage,10).topMarginToStorage(nameTextStorage,10).rightMargin(20)];

    /***********************************  添加点击Link 解析表情*********************************************/
    [nameTextStorage addLinkWithData:[NSString stringWithFormat:@"%@",statusModel.name]
                             inRange:NSMakeRange(0,statusModel.name.length)
                           linkColor:nil
                      highLightColor:[UIColor grayColor]
                      UnderLineStyle:NSUnderlineStyleNone];

    [LWTextParser parseEmojiWithTextStorage:contentTextStorage];
    [LWTextParser parseTopicWithLWTextStorage:contentTextStorage
                                    linkColor:RGB(113, 129, 161, 1)
                               highlightColor:nil
                               underlineStyle:NSUnderlineStyleNone];

    //发布的图片模型 imgsStorage
    NSInteger imageCount = [statusModel.imgs count];
    NSMutableArray* imageStorageArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
    NSMutableArray* imagePositionArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
    NSInteger row = 0;
    NSInteger column = 0;
    for (NSInteger i = 0; i < statusModel.imgs.count; i ++) {
        CGRect imageRect = CGRectMake(60.0f + (column * 85.0f),
                                      60.0f + contentTextStorage.height + (row * 85.0f),
                                      80.0f,
                                      80.0f);
        NSString* imagePositionString = NSStringFromCGRect(imageRect);
        [imagePositionArray addObject:imagePositionString];
        LWImageStorage* imageStorage = [[LWImageStorage alloc] init];

        /*********** 也可以不使用设置约束的方式来布局，而是直接设置frame属性的方式来布局********************/
        imageStorage.frame = imageRect;
        /***********************************/

        NSString* URLString = [statusModel.imgs objectAtIndex:i];
        imageStorage.URL = [NSURL URLWithString:URLString];
        imageStorage.type = LWImageStorageWebImage;
        imageStorage.fadeShow = YES;
        [imageStorageArray addObject:imageStorage];
        column = column + 1;
        if (column > 2) {
            column = 0;
            row = row + 1;
        }
    }
    CGFloat imagesHeight = 0.0f;
    row < 3 ? (imagesHeight = (row + 1) * 85.0f):(imagesHeight = row  * 85.0f);

    //获取最后一张图片的模型
    LWImageStorage* lastImageStorage = (LWImageStorage *)[imageStorageArray lastObject];

    //生成时间的模型 dateTextStorage
    LWTextStorage* dateTextStorage = [[LWTextStorage alloc] init];
    dateTextStorage.text = [[self dateFormatter] stringFromDate:statusModel.date];
    dateTextStorage.font = [UIFont systemFontOfSize:13.0f];
    dateTextStorage.textColor = [UIColor grayColor];

    /***********************************  设置约束 自动布局 *********************************************/
    [LWConstraintManager lw_makeConstraint:dateTextStorage.constraint.leftEquelToStorage(contentTextStorage).topMarginToStorage(lastImageStorage,10)];
    
        /**************************将要在同一个LWAsyncDisplayView上显示的Storage要全部放入同一个LWLayout中***************************************/
    /**************************我们将尽量通过合并绘制的技术将所有在同一个View显示的内容全都异步绘制在同一个AsyncDisplayView上**************************/
    /**************************这样的做法能最大限度的节省系统的开销**************************/
    NSMutableArray* textStorages = [[NSMutableArray alloc] init];
    [textStorages addObject:nameTextStorage];
    [textStorages addObject:contentTextStorage];
    [textStorages addObject:dateTextStorage];
    [textStorages addObjectsFromArray:commentTextStorages];

    NSMutableArray* imageStorages = [[NSMutableArray alloc] init];
    [imageStorages addObjectsFromArray:imageStorageArray];
    [imageStorages addObject:avatarStorage];

    //生成Layout 继承自LWLayout
    CellLayout* layout = [[CellLayout alloc] initWithTextStorages:textStorages imageStorages:imageStorages];

      //如果是使用在UITableViewCell上面，可以通过以下方法快速的得到Cell的高度
    layout.cellHeight = [layout suggestHeightWithBottomMargin:15.0f];
    


//然后将这个Layout赋值给LWAsyncDisplayView的实例对象即可
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"cellIdentifier";
    TableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CellLayout* cellLayout = self.dataSource[indexPath.row];
    cell.cellLayout = cellLayout;
    return cell;
}

//Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellLayout* layout = self.dataSource[indexPath.row];
    return layout.cellHeight;
}

```

* **如果需要更加详细的内容，请看各个头文件和Demo，有详细的注释**
*  下载Demo真机调试查看效果

## 正在不断完善中...  Enjoy~
## 有任何问题请联系我 liuweiself@126.com

