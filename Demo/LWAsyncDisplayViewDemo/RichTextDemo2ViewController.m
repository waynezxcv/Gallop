/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/




#import "RichTextDemo2ViewController.h"
#import "Gallop.h"



@interface RichTextDemo2ViewController ()

@end

@implementation RichTextDemo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"富文本";
    
    LWAsyncDisplayView* view = [[LWAsyncDisplayView alloc]
                                initWithFrame:CGRectMake(0.0f,
                                                         64.0,
                                                         SCREEN_WIDTH,
                                                         SCREEN_HEIGHT - 64.0f)];
    [self.view addSubview:view];
    
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
    UIImage* image = [UIImage imageNamed:@"001"];
    NSMutableAttributedString* as2 = [NSMutableAttributedString
                                      lw_textAttachmentStringWithContent:image
                                      contentMode:UIViewContentModeScaleAspectFill
                                      ascent:30
                                      descent:0.0f
                                      width:30.0f];
    LWTextStorage* ts4 = [LWTextStorage lw_textStrageWithText:as2 frame:CGRectZero];
    [ts2 lw_appendTextStorage:ts4];
    
    
    //创建LWLayout对象
    LWLayout* layout = [[LWLayout alloc] init];
    //将LWStorage对象添加到LWLayout对象
    [layout addStorages:@[ts1,ts2]];
    //对LWAsyncDisplayView对象赋值
    view.layout = layout;
}





@end
