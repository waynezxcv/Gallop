/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/




#import "RichTextDemo1ViewController.h"
#import "Gallop.h"
#import "LWAlertView.h"


@interface RichTextDemo1ViewController ()<LWAsyncDisplayViewDelegate>

@property (nonatomic,strong) LWAsyncDisplayView* asyncView;
@property (nonatomic,copy) NSString* preCopyText;

@end

@implementation RichTextDemo1ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"属性文本";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //创建LWAsyncDisplayView对象
    self.asyncView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectMake(0.0f,
                                                                          64.0,
                                                                          SCREEN_WIDTH,
                                                                          SCREEN_HEIGHT - 64.0f)];
    //设置代理
    self.asyncView.delegate = self;
    [self.view addSubview:self.asyncView];
    
    
    //创建LWTextStorage对象
    LWTextStorage* ts = [[LWTextStorage alloc] init];
    ts.frame = CGRectMake(20, 30.0f,SCREEN_WIDTH - 40.0f, CGFLOAT_MAX);
    ts.text = @"Gallop支持图文混排,可以在文字中插入本地图片→和网络图片→UIView的子类→.给指定位置文字添加链接.快来试试吧。";
    ts.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
    
    UIImage* image = [UIImage imageNamed:@"test"];
    UISwitch* switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    
    //在文字中插入本地图片
    [ts lw_replaceTextWithImage:image
                    contentMode:UIViewContentModeScaleToFill
                      imageSize:CGSizeMake(50.0f, 50.0f)
                      alignment:LWTextAttachAlignmentTop
                          range:NSMakeRange(26, 0)];
    
    //在文字中插入网络图片
    [ts lw_replaceTextWithImageURL:[NSURL URLWithString:@"http://ww2.sinaimg.cn/mw690/6d0bb361gw1f2jim2hgxij20lo0egwgc.jpg"]
                       contentMode:UIViewContentModeScaleAspectFill
                         imageSize:CGSizeMake(80, 50.0f)
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
    
    //给整段文本添加点击事件
    [ts lw_addLinkForWholeTextStorageWithData:@"第一段"
                               highLightColor:RGB(0, 0, 0, 0.15f)];
    
    //给文本添加长按事件
    [ts lw_addLongPressActionWithData:ts.text
                       highLightColor:RGB(0, 0, 0, 0.25f)];
    
    
    //用属性字符串创建LWTextStorage
    NSMutableAttributedString* as1 = [[NSMutableAttributedString alloc] initWithString:@"世界对着它的爱人，把它浩翰的面具揭下了。它变小了，小如一首歌，小如一回永恒的接吻。"];
    [as1 setFont:[UIFont fontWithName:@"Heiti SC" size:13.0f] range:NSMakeRange(0, as1.length)];
    [as1 setTextBackgroundColor:[UIColor orangeColor] range:NSMakeRange(0, 9)];
    [as1 setTextColor:[UIColor whiteColor] range:NSMakeRange(0, 9)];
    [as1 setTextColor:[UIColor blackColor] range:NSMakeRange(9, as1.length - 9)];
    [as1 setUnderlineStyle:NSUnderlineStyleDouble underlineColor:[UIColor blueColor]
                     range:NSMakeRange(9, as1.length - 20.0f)];
    
    [as1 setTextBackgroundColor:RGB(43, 187, 228, 0.9f) range:NSMakeRange(as1.length - 10, 10)];
    [as1 setTextColor:[UIColor whiteColor] range:NSMakeRange(as1.length - 10, 10)];
    
    LWTextStorage* ts1 = [LWTextStorage lw_textStorageWithText:as1
                                                         frame:CGRectMake(20.0f,
                                                                          ts.bottom + 20.0f,
                                                                          SCREEN_WIDTH - 40.0f,
                                                                          CGFLOAT_MAX)];
    ts1.linespacing = 3.0f;
    
    
    LWTextStorage* ts2 = [[LWTextStorage alloc] init];
    ts2.text = @"世界对着它的爱人，把它浩翰的面具揭下了。它变小了，小如一首歌，小如一回永恒的接吻。The world puts off its mask of vastness to its lover.It becomes small as one song, as one kiss of the eternal.";
    ts2.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
    ts2.textAlignment = NSTextAlignmentCenter;//设置居中
    ts2.needDebug = YES;//设置为调试模式
    ts2.frame = CGRectMake(20.0f,
                           ts1.bottom + 20.0f,
                           SCREEN_WIDTH - 40.0f,
                           200.0f);
    ts2.linespacing = 8.0f;
    ts2.vericalAlignment = LWTextVericalAlignmentCenter;//垂直方向居中对齐
    
    
    //创建LWLayout对象
    LWLayout* layout = [[LWLayout alloc] init];
    //将LWTextStorage对象添加到LWLayout对象中
    [layout addStorages:@[ts,ts1,ts2]];
    //将LWLayout对象赋值给LWAsyncDisplayView对象
    self.asyncView.layout = layout;
}

//给文字添加点击事件后，若触发事件，会在这个代理方法中收到回调
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView
    didCilickedTextStorage:(LWTextStorage *)textStorage
                  linkdata:(id)data {
    NSLog(@"点击:%@",data);
    if ([data isKindOfClass:[NSString class]]) {
        [LWAlertView shoWithMessage:data];
    }
}

//给文字添加长按事件后，触发后，会在这个代理方法中收到回调
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView
 didLongpressedTextStorage:(LWTextStorage *)textStorage
                  linkdata:(id)data {
    
    [asyncDisplayView becomeFirstResponder];
    UIMenuItem* copyLink = [[UIMenuItem alloc] initWithTitle:@"复制"
                                                      action:@selector(copyText)];
    
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyLink, nil]];
    CGRect rect = CGRectMake(textStorage.center.x - 50.0f, textStorage.top - 50.0f, 100.0f, 50.0f);
    [UIMenuController sharedMenuController].arrowDirection = UIMenuControllerArrowDown;
    [[UIMenuController sharedMenuController] setTargetRect:rect inView:asyncDisplayView];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    self.preCopyText = data;
}

//复制
- (void)copyText {
    NSLog(@"复制了:%@",self.preCopyText);
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.preCopyText;
    
    [self.asyncView resignFirstResponder];
    [self.asyncView removeAllHighlights];
    
}

@end
