
/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/




#import "HTMLParsingViewController.h"
#import "LWAlertView.h"
#import "Gallop.h"
#import "WebViewController.h"
#import "LWActiveIncator.h"
#import "LWImageBrowser.h"



@interface HTMLParsingViewController ()<LWHTMLDisplayViewDelegate>

@property (nonatomic,strong) LWHTMLDisplayView* htmlView;
@property (nonatomic,strong) UILabel* coverTitleLabel;
@property (nonatomic,strong) UILabel* coverDesLabel;
@property (nonatomic,assign) BOOL isNeedRefresh;

@end

@implementation HTMLParsingViewController

#pragma mark - ViewControllerLifeCycle

- (void)loadView {
    [super loadView];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 80.0f, 30.0f);
    [button setTitle:@"UIWebView" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button.titleLabel.textAlignment = NSTextAlignmentRight;
    [button addTarget:self action:@selector(UIWebView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

    self.isNeedRefresh = YES;
    self.title = @"HTML Parsing";
    self.view.backgroundColor = [UIColor whiteColor];
    self.htmlView = [[LWHTMLDisplayView alloc] initWithFrame:self.view.bounds parentVC:self];
    self.htmlView.displayDelegate = self;
    [self.view addSubview:self.htmlView];

    UIView* mskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250.0f)];
    mskView.backgroundColor = RGB(0, 0, 0, 0.15f);
    [self.htmlView addSubview:mskView];

    self.coverTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 150.0f, SCREEN_WIDTH - 20.0f, 80.0f)];
    self.coverTitleLabel.textColor = [UIColor whiteColor];
    self.coverTitleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20.0f];
    self.coverTitleLabel.numberOfLines = 0;
    self.coverTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.htmlView addSubview:self.coverTitleLabel];

    self.coverDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 230.0f, SCREEN_WIDTH - 20.0f, 20.0f)];
    self.coverDesLabel.textColor = [UIColor whiteColor];
    self.coverDesLabel.font = [UIFont fontWithName:@"Heiti SC" size:10.0f];
    self.coverDesLabel.numberOfLines = 0;
    self.coverDesLabel.textAlignment = NSTextAlignmentRight;
    [self.htmlView addSubview:self.coverDesLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isNeedRefresh) {
        self.isNeedRefresh = NO;
        [self _parsing];
    }
}


#pragma mark - Data
- (void)downloadDataCompletion:(void(^)(NSData* data))completion {
    NSURLSession* session = [NSURLSession sessionWithConfiguration:
                             [NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:self.URL];
    NSURLSessionDataTask* task =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData * _Nullable data,
                                   NSURLResponse * _Nullable response,
                                   NSError * _Nullable error) {
                   completion(data);
               }];
    [task resume];
}

#pragma mark - Parsing
- (void)_parsing {
    [LWActiveIncator showInView:self.view];
    __weak typeof(self) weakSelf = self;
    [self downloadDataCompletion:^(NSData *data) {
        __strong typeof(weakSelf) swself = weakSelf;
        swself.htmlView.data = data;

        LWHTMLLayout* htmlLayout = [[LWHTMLLayout alloc] init];

        LWStorageBuilder* builder = swself.htmlView.storageBuilder;
        /** cover  **/
        LWHTMLImageConfig* coverConfig = [[LWHTMLImageConfig alloc] init];
        coverConfig.size = CGSizeMake(SCREEN_WIDTH, 250.0f);
        [builder createLWStorageWithXPath:@"//div[@class='img-wrap']/img"
                               edgeInsets:UIEdgeInsetsMake(0.0f, 0, 5.0f, 0)
                         configDictionary:@{@"img":coverConfig}];
        [htmlLayout addStorages:builder.storages];

        /** cover title **/
        [builder createLWStorageWithXPath:@"//div[@class='img-wrap']/h1"];
        NSString* coverTitle = [builder contents];

        /** cover description **/
        [builder createLWStorageWithXPath:@"//div[@class='img-wrap']/span[@class='img-source']"];
        NSString* coverDes = [builder contents];

        /** title  **/
        LWHTMLTextConfig* titleConfig = [[LWHTMLTextConfig alloc] init];
        titleConfig.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:18.0];
        titleConfig.textColor = [UIColor blackColor];
        [builder createLWStorageWithXPath:@"//div[@class='question']/h2"
                               edgeInsets:UIEdgeInsetsMake(10.0f, 20.0f, 15.0f, 20.0f)
                         configDictionary:@{@"h2":titleConfig}];
        [htmlLayout addStorages:builder.storages];//使用add方法添加的storage将另起一行

        /** avatar  **/
        LWHTMLImageConfig* avatarConfig = [[LWHTMLImageConfig alloc] init];
        avatarConfig.size = CGSizeMake(20.0f, 20.0f);
        [builder createLWStorageWithXPath:@"//div[@class='meta']/img"
                               edgeInsets:UIEdgeInsetsMake(10.0f, 20.0f, 10.0, 20.0f)
                         configDictionary:@{@"img":avatarConfig}];
        [htmlLayout addStorages:builder.storages];

        /** name  **/
        LWHTMLTextConfig* nameConfig = [[LWHTMLTextConfig alloc] init];
        nameConfig.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.0f];
        nameConfig.textColor = [UIColor blackColor];
        [builder createLWStorageWithXPath:@"//div[@class='meta']/span[@class='author']"
                               edgeInsets:UIEdgeInsetsMake(10.0f, 50.0f, 15.0f, 20.0f)
                         configDictionary:@{@"span":nameConfig}];

        LWTextStorage* nameStorage = (LWTextStorage*)builder.firstStorage;
        /** description  **/
        LWHTMLTextConfig* desConfig = [[LWHTMLTextConfig alloc] init];
        desConfig.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
        desConfig.textColor = [UIColor grayColor];
        [builder createLWStorageWithXPath:@"//div[@class='meta']/span[@class='bio']"
                               edgeInsets:UIEdgeInsetsMake(10.0f, 50.0f, 15.0f, 20.0f)
                         configDictionary:@{@"span":desConfig}];
        LWTextStorage* desStorage =(LWTextStorage*)builder.firstStorage;
        [nameStorage lw_appendTextStorage:desStorage];
        [htmlLayout appendStorage:nameStorage];//使用apend方法添加的storage将不会另起一行，而是拼接在上一个storage后面

        /** content  **/
        LWHTMLTextConfig* contentConfig = [[LWHTMLTextConfig alloc] init];
        contentConfig.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
        contentConfig.textColor = RGB(50, 50, 50, 1);
        contentConfig.linkColor = RGB(232, 104, 96,1.0f);
        contentConfig.linkHighlightColor = RGB(0, 0, 0, 0.35f);

        LWHTMLTextConfig* strongConfig = [[LWHTMLTextConfig alloc] init];
        strongConfig.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.0f];
        strongConfig.textColor = [UIColor blackColor];

        LWHTMLImageConfig* imageConfig = [[LWHTMLImageConfig alloc] init];
        imageConfig.size = CGSizeMake(SCREEN_WIDTH - 20.0f, 240.0f);
        imageConfig.needAddToImageBrowser = YES;//将这个图片加入照片浏览器
        imageConfig.autolayoutHeight = YES;//自动按照图片的大小匹配一个适合的高度

        [builder createLWStorageWithXPath:@"//div[@class='content']/p"
                               edgeInsets:UIEdgeInsetsMake(10.0f, 20.0f, 10.0, 20.0f)
                         configDictionary:@{@"p":contentConfig,
                                            @"strong":strongConfig,
                                            @"em":strongConfig,
                                            @"img":imageConfig}];

        [htmlLayout addStorages:builder.storages];

        dispatch_async(dispatch_get_main_queue(), ^{
            swself.htmlView.layout = htmlLayout;
            swself.coverTitleLabel.text = coverTitle;
            swself.coverDesLabel.text = coverDes;
            [LWActiveIncator hideInViwe:swself.view];
        });
    }];
}

#pragma mark - Actions
- (void)UIWebView {
    WebViewController* vc = [[WebViewController alloc] init];
    vc.URL = self.URL;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - LWHTMLDisplayViewDelegate

- (void)lw_htmlDisplayView:(LWHTMLDisplayView *)asyncDisplayView
    didCilickedTextStorage:(LWTextStorage *)textStorage
                  linkdata:(id)data {
    if ([data isKindOfClass:[NSString class]]) {
        NSString* string = (NSString *)data;
        if ([string hasPrefix:@"http://daily.zhihu.com/story/"]) {
            [LWAlertView shoWithMessage:@"使用Gallop渲染HTML页面"];
            HTMLParsingViewController* vc = [[HTMLParsingViewController alloc] init];
            vc.URL = [NSURL URLWithString:string];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [LWAlertView shoWithMessage:@"缺少模板，UIWebView打开页面"];
            WebViewController* vc = [[WebViewController alloc] init];
            vc.URL = [NSURL URLWithString:string];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)lw_htmlDisplayView:(LWHTMLDisplayView *)asyncDisplayView
   didSelectedImageStorage:(LWImageStorage *)imageStorage
               totalImages:(NSArray *)images
                 superView:(UIView *)superView
       inSuperViewPosition:(CGRect)position
                     index:(NSUInteger)index {

    NSMutableArray* tmp = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (NSInteger i = 0; i < images.count; i ++) {
        @autoreleasepool {
            LWImageStorage* imageStorage = [images objectAtIndex:i];
            LWImageBrowserModel* imageModel = [[LWImageBrowserModel alloc] initWithplaceholder:nil
                                                                                  thumbnailURL:(NSURL *)imageStorage.contents
                                                                                         HDURL:(NSURL *)imageStorage.contents
                                                                            imageViewSuperView:superView
                                                                           positionAtSuperView:imageStorage.frame
                                                                                         index:index];
            [tmp addObject:imageModel];
        }
    }
    LWImageBrowser* imageBrowser = [[LWImageBrowser alloc] initWithParentViewController:self
                                                                            imageModels:tmp
                                                                           currentIndex:index];
    imageBrowser.isScalingToHide = NO ;
    imageBrowser.isShowPageControl = NO;
    [imageBrowser show];
    
}

@end
