/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/





#import "CoreTextDemoViewController.h"
#import "Gallop.h"
#import "LWAlertView.h"
#import "LWImageBrowser.h"

@interface CoreTextDemoViewController ()<LWAsyncDisplayViewDelegate>

@property (nonatomic,strong) LWAsyncDisplayView* asyncDisplayView;

@end

@implementation CoreTextDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CoreText";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.asyncDisplayView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LWLayout* layout = [[LWLayout alloc] init];
        
        LWTextStorage* textStorage1 = [[LWTextStorage alloc] init];
        textStorage1.frame = CGRectMake(20, 10.0f, self.view.bounds.size.width - 40.0f, CGFLOAT_MAX);
        textStorage1.text = @"Gallop支持图文混排,可以在文字中插入本地图片→和网络图片→UIView的子类→.给指定位置文字添加链接.快来试试吧。";
        textStorage1.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
        
        UIImage* image1 = [UIImage imageNamed:@"[心].png"];
        UIImage* image2 = [UIImage imageNamed:@"[face].png"];
        UIImage* image3 = [UIImage imageNamed:@"pic.jpeg"];
        UISwitch* switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];

        [textStorage1 lw_replaceTextWithImage:image1
                                  contentMode:UIViewContentModeScaleAspectFill
                                    imageSize:image1.size
                                    alignment:LWTextAttachAlignmentTop
                                        range:NSMakeRange(12, 0)];
        
        [textStorage1 lw_replaceTextWithImage:image2
                                  contentMode:UIViewContentModeScaleAspectFill
                                    imageSize:CGSizeMake(20, 20)
                                    alignment:LWTextAttachAlignmentTop
                                        range:NSMakeRange(12, 0)];
        
        [textStorage1 lw_replaceTextWithImage:image3
                                  contentMode:UIViewContentModeScaleAspectFill
                                    imageSize:CGSizeMake(40, 40)
                                    alignment:LWTextAttachAlignmentTop
                                        range:NSMakeRange(28, 0)];
        
        [textStorage1 lw_replaceTextWithImageURL:[NSURL URLWithString:@"http://joymepic.joyme.com/article/uploads/20163/81460101559518330.jpeg?imageView2/1"]
                                     contentMode:UIViewContentModeScaleAspectFill
                                       imageSize:CGSizeMake(80, 40)
                                       alignment:LWTextAttachAlignmentTop
                                           range:NSMakeRange(35, 0)];
        
        [textStorage1 lw_replaceTextWithView:switchView
                                 contentMode:UIViewContentModeScaleAspectFill
                                        size:switchView.frame.size
                                   alignment:LWTextAttachAlignmentTop
                                       range:NSMakeRange(46, 0)];
        
        [textStorage1 lw_addLinkWithData:@"链接 ：）"
                                   range:NSMakeRange(55,4)
                               linkColor:[UIColor blueColor]
                          highLightColor:RGB(0, 0, 0, 0.15)];
        
        [textStorage1 lw_addLinkForWholeTextStorageWithData:@"整段文字"
                                                  linkColor:nil
                                             highLightColor:RGB(0, 0, 0, 0.15)];
        
        LWTextStorage* textStorage2 = [[LWTextStorage alloc] init];
        textStorage2.textDrawMode = LWTextDrawModeStroke;
        textStorage2.text = @"可以用描边的形式进行绘制,添加图片时，可以方便的设置圆角半径和填充颜色。";
        textStorage2.font = [UIFont fontWithName:@"Heiti SC" size:18.0f];
        textStorage2.strokeColor = [UIColor redColor];
        textStorage2.frame = CGRectMake(textStorage1.left, textStorage1.bottom+10, textStorage1.width/2, CGFLOAT_MAX);
        
        LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
        imageStorage.contents = [UIImage imageNamed:@"pic.jpeg"];
        imageStorage.cornerRadius = textStorage1.width/4;
        imageStorage.frame = CGRectMake(textStorage2.right + 10, textStorage1.bottom+10, textStorage1.width/2, textStorage1.width/2);
        imageStorage.cornerBorderColor = [UIColor orangeColor];
        imageStorage.cornerBorderWidth = 3.0f;
        
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:@"A framework for build a smooth asynchronous feed list app.you can also use it as a rich text label."];
        [attributedString setLineSpacing:7.0f range:NSMakeRange(0, attributedString.length)];
        [attributedString setFont:[UIFont systemFontOfSize:15.0f] range:NSMakeRange(0, attributedString.length)];
        [attributedString setTextColor:[UIColor yellowColor] range:NSMakeRange(0, 11)];
        [attributedString setTextBackgroundColor:[UIColor redColor] range:NSMakeRange(12, 19)];
        [attributedString setUnderlineStyle:NSUnderlineStyleSingle underlineColor:[UIColor greenColor] range:NSMakeRange(31, 26)];
        [attributedString setFont:[UIFont systemFontOfSize:20.0f] range:NSMakeRange(31, 26)];
        [attributedString setCharacterSpacing:10 range:NSMakeRange(62, 3)];
        [attributedString setFont:[UIFont systemFontOfSize:20.0f] range:NSMakeRange(62, 3)];
        [attributedString setTextColor:[UIColor redColor] range:NSMakeRange(62, 3)];
        [attributedString setStrokeColor:[UIColor blueColor] strokeWidth:2.0f range:NSMakeRange(66, 11)];
        [attributedString setFont:[UIFont systemFontOfSize:18.0f] range:NSMakeRange(66, 11)];
        [attributedString setTextColor:[UIColor whiteColor] range:NSMakeRange(78, 21)];
        [attributedString setTextBackgroundColor:[UIColor blackColor] range:NSMakeRange(78, 21)];
        [attributedString setFont:[UIFont systemFontOfSize:25]range:NSMakeRange(78, 21)];
        [attributedString setUnderlineStyle:NSUnderlineStyleDouble underlineColor:[UIColor whiteColor] range:NSMakeRange(77, 21)];

        LWTextStorage* textStorage3 = [LWTextStorage lw_textStrageWithText:attributedString
                                                                     frame:CGRectMake(textStorage1.left, textStorage2.bottom + 50.0f, textStorage1.width, CGFLOAT_MAX)];
        [layout addStorage:textStorage1];
        [layout addStorage:textStorage2];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage3];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.asyncDisplayView.layout = layout;
        });
    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.asyncDisplayView.frame = CGRectMake(0, 64.0f, self.view.bounds.size.width, self.view.bounds.size.height - 64.0f);
    self.asyncDisplayView.delegate = self;
}

- (LWAsyncDisplayView *)asyncDisplayView {
    if (_asyncDisplayView) {
        return _asyncDisplayView;
    }
    _asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
    _asyncDisplayView.backgroundColor = [UIColor whiteColor];
    return _asyncDisplayView;
}

- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedTextStorage:(LWTextStorage *)textStorage linkdata:(id)data {
    if ([data isKindOfClass:[NSString class]]) {
        [LWAlertView shoWithMessage:data];
    }
}

@end
