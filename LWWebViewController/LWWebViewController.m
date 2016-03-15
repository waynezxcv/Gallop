//
//  WebViewController.m
//  WarmerApp
//
//  Created by 刘微 on 16/2/26.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWWebViewController.h"
#import <WebKit/WebKit.h>
#import "LWWebViewProgress.h"
#import "LWWebTooBar.h"
#import "LWDefine.h"




static void* EstimatedProgressContext = &EstimatedProgressContext;
static void* CanForwardContext = &CanForwardContext;
static void* CanBackContext = &CanBackContext;



@interface WebViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic,strong) LWWebViewProgress* progressView;
@property (nonatomic,strong) NSURL* URL;
@property (nonatomic,strong) WKWebView* webView;
@property (nonatomic,strong) LWWebTooBar* tooBar;

@end

@implementation WebViewController

- (id)initWithURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        self.URL = URL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 44.0f)];
    self.webView.allowsBackForwardNavigationGestures =YES;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];

    self.progressView = [[LWWebViewProgress alloc] initWithFrame:CGRectMake(0.0f, 64.0f, SCREEN_WIDTH, 3.0f)];
    [self.view addSubview:self.progressView];

    self.tooBar = [[LWWebTooBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 44.0f, SCREEN_WIDTH,44.0f)];
    [self.view addSubview:self.tooBar];
    [self.tooBar.backButton addTarget:self action:@selector(didClickedBackButton) forControlEvents:UIControlEventTouchUpInside];
    [self.tooBar.forwardButton addTarget:self action:@selector(didClickedForwardButton) forControlEvents:UIControlEventTouchUpInside];
    [self.tooBar.reloadButton addTarget:self action:@selector(didClickedReloadButton) forControlEvents:UIControlEventTouchUpInside];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                      context:EstimatedProgressContext];
    [self.webView addObserver:self forKeyPath:@"canGoBack"
                      options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                      context:CanBackContext];
    [self.webView addObserver:self forKeyPath:@"canGoForward"
                      options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                      context:CanForwardContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView removeObserver:self
                      forKeyPath:@"estimatedProgress"
                         context:EstimatedProgressContext];

    [self.webView removeObserver:self
                      forKeyPath:@"canGoBack"
                         context:CanBackContext];

    [self.webView removeObserver:self
                      forKeyPath:@"canGoForward"
                         context:CanForwardContext];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}


#pragma mark - Actions

- (void)didClickedBackButton {
    [self.webView goBack];
}
- (void)didClickedForwardButton {
    [self.webView goForward];
}

- (void)didClickedReloadButton {
    [self.webView reload];
}

#pragma mark - EstimatedProgress Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id newValue = change[NSKeyValueChangeNewKey];
    if (context == EstimatedProgressContext) {
        if (newValue && newValue != [NSNull null]) {
            CGFloat progress = [newValue floatValue];
            self.progressView.progress = progress;
        }
    }
    else if (context == CanBackContext) {
        BOOL canBack = self.webView.canGoBack;
        self.tooBar.canGoBack = canBack;
    }
    else if (context == CanForwardContext) {
        BOOL canForward = self.webView.canGoForward;
        self.tooBar.canGoForward = canForward;

    }
}

#pragma mark - WKNavigationDelgate
/**
 * 准备开始加载页面
 *
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    self.progressView.hidden = NO;
}

/**
 *  已经开始准备开始加载页面
 *
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {

}

/**
 *  页面加载完成
 *

 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    self.title = self.webView.title;
    self.progressView.hidden = YES;
}

/**
 *  页面加载失败
 *
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {

}

/**
 *  页面加载失败
 *
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}

@end
