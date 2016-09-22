
/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/


#import "WebViewController.h"
#import "LWActiveIncator.h"

@interface WebViewController ()<UIWebViewDelegate>

@property (nonatomic,strong) UIWebView* webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [LWActiveIncator showInView:self.view];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [LWActiveIncator hideInViwe:self.view];
}


@end
