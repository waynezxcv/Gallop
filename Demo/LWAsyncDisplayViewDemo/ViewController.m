//
//  ViewController.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/3/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "ViewController.h"
#import "LWImageBrowser.h"
#import "TableViewCell.h"
#import "TableViewHeader.h"
#import "LWDefine.h"
#import "LWAlchemy.h"
#import "StatusModel.h"
#import "LWTextParser.h"
#import "CellLayout.h"


@interface ViewController () <UITableViewDataSource,UITableViewDelegate,TableViewCellDelegate>

@property (nonnull,strong) NSArray* fakeDatasource;
@property (nonatomic,strong) TableViewHeader* tableViewHeader;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,assign,getter = isNeedRefresh) BOOL needRefresh;

@end

const CGFloat kRefreshBoundary = 170.0f;

@implementation ViewController

#pragma mark - ViewControllerLifeCycle

- (void)loadView {
    [super loadView];
    [self setup];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshBegin];
}

- (void)setup {
    self.needRefresh = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    NSDictionary* attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    self.navigationItem.title = @"朋友圈";
}

#pragma mark - Actions

/**
 *  点击图片
 *
 */
- (void)tableViewCell:(TableViewCell *)cell didClickedImageWithCellLayout:(CellLayout *)layout atIndex:(NSInteger)index {
    NSMutableArray* tmp = [[NSMutableArray alloc] initWithCapacity:layout.imagePostionArray.count];
    for (NSInteger i = 0; i < layout.imagePostionArray.count; i ++) {
        LWImageBrowserModel* imageModel = [[LWImageBrowserModel alloc] initWithplaceholder:nil
                                                                              thumbnailURL:[NSURL URLWithString:[layout.statusModel.imgs objectAtIndex:i]]
                                                                                     HDURL:[NSURL URLWithString:[layout.statusModel.imgs objectAtIndex:i]]
                                                                        imageViewSuperView:cell.contentView
                                                                       positionAtSuperView:CGRectFromString(layout.imagePostionArray[i])
                                                                                     index:index];
        [tmp addObject:imageModel];
    }
    LWImageBrowser* imageBrowser = [[LWImageBrowser alloc] initWithParentViewController:self
                                                                                  style:LWImageBrowserAnimationStyleScale
                                                                            imageModels:tmp
                                                                           currentIndex:index];
    imageBrowser.view.backgroundColor = [UIColor blackColor];
    [imageBrowser show];
}

/**
 *  点击链接
 *
 */
- (void)tableViewCell:(TableViewCell *)cell didClickedLinkWithData:(id)data {
    UIViewController* vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.title = data;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

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



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellLayout* layout = self.dataSource[indexPath.row];
    return layout.cellHeight;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    [self.tableViewHeader loadingViewAnimateWithScrollViewContentOffset:offset];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    if (offset <= -kRefreshBoundary) {
        [self refreshBegin];
    }
}

- (void)refreshBegin {
    [UIView animateWithDuration:0.2f animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(kRefreshBoundary, 0.0f, 0.0f, 0.0f);
    } completion:^(BOOL finished) {
        [self.tableViewHeader refreshingAnimateBegin];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self downloadData];
        });
    }];
}

- (void)downloadData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.dataSource removeAllObjects];
        for (NSInteger i = 0; i < self.fakeDatasource.count; i ++) {
            StatusModel* statusModel = [StatusModel modelWithJSON:self.fakeDatasource[i]];
            LWLayout* layout = [self layoutWithStatusModel:statusModel];
            [self.dataSource addObject:layout];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataSource addObjectsFromArray:self.dataSource];
            [self refreshComplete];
        });
    });
}

/****************************************************************************/
/**
 *  在这里生成LWAsyncDisplayView的模型。
 */
/****************************************************************************/

- (CellLayout *)layoutWithStatusModel:(StatusModel *)statusModel {
    //avatarImageStorage
    LWImageStorage* avatarStorage = [[LWImageStorage alloc] init];
    avatarStorage.type = LWImageStorageWebImage;
    avatarStorage.URL = statusModel.avatar;
    avatarStorage.boundsRect = CGRectMake(10.0f, 20.0f,40.0f, 40.0f);
    //nameTextStorage
    LWTextStorage* nameTextStorage = [[LWTextStorage alloc] init];
    nameTextStorage.text = statusModel.name;
    nameTextStorage.font = [UIFont systemFontOfSize:15.0f];
    nameTextStorage.textAlignment = NSTextAlignmentLeft;
    nameTextStorage.linespace = 2.0f;
    nameTextStorage.textColor = RGB(113, 129, 161, 1);
    nameTextStorage.boundsRect = CGRectMake(60, 20, SCREEN_WIDTH, 20);
    [nameTextStorage creatCTFrameRef];
    [nameTextStorage addLinkWithData:[NSString stringWithFormat:@"%@",statusModel.name]
                             inRange:NSMakeRange(0,statusModel.name.length)
                           linkColor:nil
                      highLightColor:[UIColor grayColor]
                      UnderLineStyle:NSUnderlineStyleNone];
    //contentTextStorage
    LWTextStorage* contentTextStorage = [[LWTextStorage alloc] init];
    contentTextStorage.text = statusModel.content;
    contentTextStorage.font = [UIFont systemFontOfSize:15.0f];
    contentTextStorage.textColor = RGB(40, 40, 40, 1);
    contentTextStorage.boundsRect = CGRectMake(60.0f,nameTextStorage.bottom,SCREEN_WIDTH - 80.0f,MAXFLOAT);
    contentTextStorage.linespace = 2.0f;
    [contentTextStorage creatCTFrameRef];
    [LWTextParser parseEmojiWithTextStorage:contentTextStorage];
    [LWTextParser parseTopicWithLWTextStorage:contentTextStorage
                                    linkColor:RGB(113, 129, 161, 1)
                               highlightColor:nil
                               underlineStyle:NSUnderlineStyleNone];
    //imgsStorage
    NSInteger imageCount = [statusModel.imgs count];
    NSMutableArray* imageStorageArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
    NSMutableArray* imagePositionArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
    NSInteger row = 0;
    NSInteger column = 0;
    for (NSInteger i = 0; i < statusModel.imgs.count; i ++) {
        CGRect imageRect = CGRectMake(60.0f + (column * 85.0f),
                                      60.0f + contentTextStorage.textHeight + (row * 85.0f),
                                      80.0f,
                                      80.0f);

        NSString* imagePositionString = NSStringFromCGRect(imageRect);
        [imagePositionArray addObject:imagePositionString];

        LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
        imageStorage.boundsRect = imageRect;
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
    //timeStamp
    LWTextStorage* dateTextStorage = [[LWTextStorage alloc] init];
    dateTextStorage.text = [[self dateFormatter] stringFromDate:statusModel.date];
    dateTextStorage.font = [UIFont systemFontOfSize:13.0f];
    dateTextStorage.textColor = [UIColor grayColor];
    dateTextStorage.boundsRect = CGRectMake(60, 20.0f + imagesHeight + contentTextStorage.bottom,SCREEN_WIDTH - 80,20.0f);
    [dateTextStorage creatCTFrameRef];
    //menu
    CGRect menuPosition = CGRectMake(SCREEN_WIDTH - 40.0f,20.0f + imagesHeight + contentTextStorage.bottom,20.0f,15.0f);
    //comment
    NSArray* commentTextStorages = @[];
    CGRect commentBgPosition = CGRectZero;
    CGRect rect = CGRectMake(60.0f,dateTextStorage.bottom + 5.0f, SCREEN_WIDTH - 80, 20);
    CGFloat offsetY = 0.0f;
    if (statusModel.commentList.count != 0 && statusModel.commentList != nil) {
        NSMutableArray* tmp = [[NSMutableArray alloc] initWithCapacity:statusModel.commentList.count];
        for (NSDictionary* commentDict in statusModel.commentList) {
            NSString* to = commentDict[@"to"];
            if (to.length != 0) {
                NSString* commentString = [NSString stringWithFormat:@"%@回复%@:%@",commentDict[@"from"],commentDict[@"to"],commentDict[@"content"]];
                LWTextStorage* commentTextStorage = [[LWTextStorage alloc] init];
                commentTextStorage.text = commentString;
                commentTextStorage.font = [UIFont systemFontOfSize:14.0f];
                commentTextStorage.textAlignment = NSTextAlignmentLeft;
                commentTextStorage.linespace = 2.0f;
                commentTextStorage.textColor = RGB(40, 40, 40, 1);
                commentTextStorage.boundsRect = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY,SCREEN_WIDTH - 95.0f, 20.0f);
                [commentTextStorage creatCTFrameRef];
                [commentTextStorage addLinkWithData:[NSString stringWithFormat:@"%@",commentDict[@"from"]]
                                            inRange:NSMakeRange(0,[(NSString *)commentDict[@"from"] length])
                                          linkColor:RGB(113, 129, 161, 1)
                                     highLightColor:[UIColor grayColor]
                                     UnderLineStyle:NSUnderlineStyleNone];

                [commentTextStorage addLinkWithData:[NSString stringWithFormat:@"%@",commentDict[@"to"]]
                                            inRange:NSMakeRange([(NSString *)commentDict[@"from"] length] + 2,[(NSString *)commentDict[@"to"] length])
                                          linkColor:RGB(113, 129, 161, 1)
                                     highLightColor:[UIColor grayColor]
                                     UnderLineStyle:NSUnderlineStyleNone];

                [LWTextParser parseEmojiWithTextStorage:commentTextStorage];
                [LWTextParser parseTopicWithLWTextStorage:commentTextStorage
                                                linkColor:RGB(113, 129, 161, 1)
                                           highlightColor:nil
                                           underlineStyle:NSUnderlineStyleNone];
                [tmp addObject:commentTextStorage];
                offsetY += commentTextStorage.textHeight;
            } else {
                NSString* commentString = [NSString stringWithFormat:@"%@:%@",commentDict[@"from"],commentDict[@"content"]];
                LWTextStorage* commentTextStorage = [[LWTextStorage alloc] init];
                commentTextStorage.text = commentString;
                commentTextStorage.font = [UIFont systemFontOfSize:14.0f];
                commentTextStorage.textAlignment = NSTextAlignmentLeft;
                commentTextStorage.linespace = 2.0f;
                commentTextStorage.textColor = RGB(40, 40, 40, 1);
                commentTextStorage.boundsRect = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY,SCREEN_WIDTH - 95.0f, 20.0f);
                [commentTextStorage creatCTFrameRef];
                [commentTextStorage addLinkWithData:[NSString stringWithFormat:@"%@",commentDict[@"from"]]
                                            inRange:NSMakeRange(0,[(NSString *)commentDict[@"from"] length])
                                          linkColor:RGB(113, 129, 161, 1)
                                     highLightColor:[UIColor grayColor]
                                     UnderLineStyle:NSUnderlineStyleNone];
                [LWTextParser parseEmojiWithTextStorage:commentTextStorage];
                [LWTextParser parseTopicWithLWTextStorage:commentTextStorage
                                                linkColor:RGB(113, 129, 161, 1)
                                           highlightColor:nil
                                           underlineStyle:NSUnderlineStyleNone];
                [tmp addObject:commentTextStorage];
                offsetY += commentTextStorage.textHeight;
            }
        }
        commentTextStorages = tmp;
        commentBgPosition = CGRectMake(60.0f,dateTextStorage.bottom + 5.0f, SCREEN_WIDTH - 80, offsetY + 15.0f);
    }
    /****************************************************************************/
    NSMutableArray* textStorages = [[NSMutableArray alloc] init];
    [textStorages addObject:nameTextStorage];
    [textStorages addObject:contentTextStorage];
    [textStorages addObject:dateTextStorage];
    [textStorages addObjectsFromArray:commentTextStorages];
    NSMutableArray* imageStorages = [[NSMutableArray alloc] init];
    [imageStorages addObjectsFromArray:imageStorageArray];
    [imageStorages addObject:avatarStorage];
    //生成Layout
    CellLayout* layout = [[CellLayout alloc] initWithTextStorages:textStorages imageStorages:imageStorages];
    //一些其他属性
    layout.menuPosition = menuPosition;
    layout.commentBgPosition = commentBgPosition;
    layout.cellHeight = dateTextStorage.bottom + commentBgPosition.size.height + 15.0f;
    layout.imagePostionArray = imagePositionArray;
    layout.statusModel = statusModel;
    return layout;
}

/****************************************************************************/

- (void)refreshComplete {
    [self.tableViewHeader refreshingAnimateStop];
    [UIView animateWithDuration:0.35f animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
        self.needRefresh = NO;
    }];
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:SCREEN_BOUNDS style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.tableViewHeader;
        _tableView.decelerationRate = 1.0f;
    }
    return _tableView;
}

- (TableViewHeader *)tableViewHeader {
    if (!_tableViewHeader) {
        _tableViewHeader = [[TableViewHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f,SCREEN_WIDTH, 270.0f)];
    }
    return _tableViewHeader;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}


- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter* dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM月dd日 hh:mm"];
    });
    return dateFormatter;
}







































/**
 *  模拟数据
 *
 */
- (NSArray *)fakeDatasource {
    if (_fakeDatasource) {
        return _fakeDatasource;
    }
    _fakeDatasource = @[@{@"name":@"SIZE潮流生活",
                          @"avatar":@"http://tp2.sinaimg.cn/1829483361/50/5753078359/1",
                          @"content":@"近日[心]，adidas Originals为经典鞋款Stan Smith打造Primeknit版本，并带来全新的“OG”系列。简约的鞋身采用白色透气Primeknit针织材质制作，再将Stan Smith代表性的绿、红、深蓝三个元年色调融入到鞋舌和后跟点缀，最后搭载上米白色大底来保留其复古风味。据悉该鞋款将在今月登陆全球各大adidas Originals指定店舖。",
                          @"date":@"1459668442",
                          @"imgs":@[@"http://ww2.sinaimg.cn/mw690/6d0bb361gw1f2jim2hgxij20lo0egwgc.jpg",
                                    @"http://ww3.sinaimg.cn/mw690/6d0bb361gw1f2jim2hsg6j20lo0egwg2.jpg",
                                    @"http://ww1.sinaimg.cn/mw690/6d0bb361gw1f2jim2d7nfj20lo0eg40q.jpg",
                                    @"http://ww1.sinaimg.cn/mw690/6d0bb361gw1f2jim2hka3j20lo0egdhw.jpg",
                                    @"http://ww2.sinaimg.cn/mw690/6d0bb361gw1f2jim2hq61j20lo0eg769.jpg"],
                          @"statusID":@"1",
                          @"commentList":@[@{@"from":@"SIZE潮流生活",
                                             @"to":@"",
                                             @"content":@"使用LWAsyncDisplay来实现图文混排。享受如丝般顺滑的滚动体验。"},
                                           @{@"from":@"waynezxcv",
                                             @"to":@"SIZE潮流生活",
                                             @"content":@"哈哈哈哈"},
                                           @{@"from":@"SIZE潮流生活",
                                             @"to":@"waynezxcv",
                                             @"content":@"nice~使用LWAsyncDisplayView。支持异步绘制，让滚动如丝般顺滑。并且支持图文混排[心]和点击链接#LWAsyncDisplayView#"}]},
                        @{@"name":@"妖妖小精",
                          @"avatar":@"http://tp2.sinaimg.cn/2185608961/50/5714822219/0",
                          @"content":@"出国留学的儿子为思念自己的家人们寄来一个用自己照片做成的人形立牌",
                          @"date":@"1459668442",
                          @"imgs":@[@"http://ww3.sinaimg.cn/mw690/8245bf01jw1f2jhh2ohanj20jg0yk418.jpg",
                                    @"http://ww4.sinaimg.cn/mw690/8245bf01jw1f2jhh34q9rj20jg0px77y.jpg",
                                    @"http://ww1.sinaimg.cn/mw690/8245bf01jw1f2jhh3grfwj20jg0pxn13.jpg",
                                    @"http://ww4.sinaimg.cn/mw690/8245bf01jw1f2jhh3ttm6j20jg0el76g.jpg",
                                    @"http://ww3.sinaimg.cn/mw690/8245bf01jw1f2jhh43riaj20jg0pxado.jpg",
                                    @"http://ww2.sinaimg.cn/mw690/8245bf01jw1f2jhh4mutgj20jg0ly0xt.jpg",
                                    @"http://ww3.sinaimg.cn/mw690/8245bf01jw1f2jhh4vc7pj20jg0px41m.jpg",
                                    @"http://ww4.sinaimg.cn/mw690/8245bf01jw1f2jhh2mgkgj20jg0pxn2z.jpg"],
                          @"statusID":@"2",
                          @"commentList":@[@{@"from":@"waynezxcv",
                                             @"to":@"妖妖小精",
                                             @"content":@"[心]"}]},
                        @{@"name":@"Instagram热门",
                          @"avatar":@"http://tp4.sinaimg.cn/5074408479/50/5706839595/0",
                          @"content":@"Austin Butler & Vanessa Hudgens  想试试看扑到一个一米八几的人怀里是有多舒服[心]",
                          @"date":@"1459668442",
                          @"imgs":@[@"http://ww1.sinaimg.cn/mw690/005xpHs3gw1f2jg132p3nj309u0goq62.jpg",
                                    @"http://ww3.sinaimg.cn/mw690/005xpHs3gw1f2jg14per3j30b40ctmzp.jpg",
                                    @"http://ww3.sinaimg.cn/mw690/005xpHs3gw1f2jg14vtjjj30b40b4q5m.jpg",
                                    @"http://ww1.sinaimg.cn/mw690/005xpHs3gw1f2jg15amskj30b40f1408.jpg",
                                    @"http://ww3.sinaimg.cn/mw690/005xpHs3gw1f2jg16f8vnj30b40g4q4q.jpg",
                                    @"http://ww4.sinaimg.cn/mw690/005xpHs3gw1f2jg178dxdj30am0gowgv.jpg",
                                    @"http://ww2.sinaimg.cn/mw690/005xpHs3gw1f2jg17c5urj30b40ghjto.jpg",
                                    @"http://ww4.sinaimg.cn/mw690/005xpHs3gw1f2jg18p02pj30b40fdmz4.jpg"],
                          @"statusID":@"3"},
                        @{@"name":@"头条新闻",
                          @"avatar":@"http://tp1.sinaimg.cn/1618051664/50/5735009977/0",
                          @"content":@"#万象# 【熊孩子！4名小学生铁轨上设障碍物逼停火车】4名小学生打赌，1人认为火车会将石头碾成粉末，其余3人不信，认为只会碾碎，于是他们将道碴摆放在铁轨上。火车司机发现前方不远处的铁轨上，摆放了影响行车安全的障碍物，于是紧急采取制动，列车中途停车13分钟。O4名学生铁轨上设障碍物逼停火车",
                          @"date":@"1459668442",
                          @"imgs":@[@"http://ww2.sinaimg.cn/mw690/60718250jw1f2jg46smtmj20go0go77r.jpg"],
                          @"statusID":@"4"},
                        @{@"name":@"优酷",
                          @"avatar":@"http://tp2.sinaimg.cn/1642904381/50/5749093752/1",
                          @"content":@"1000杯拿铁，幻化成一生挚爱。两个人，不远万里来相遇、相识、相知，直至相守，小小拿铁却是大大的世界。 L如何用 1000 杯拿铁表达爱",
                          @"date":@"1459668442",
                          @"imgs":@[@"http://ww1.sinaimg.cn/mw690/61ecbb3dgw1f2jfeqmwskg208w04wwvj.gif"],
                          @"statusID":@"5"},
                        @{@"name":@"Kindle中国",
                          @"avatar":@"http://tp1.sinaimg.cn/3262223112/50/5684307907/1",
                          @"content":@"#只限今日#《简单的逻辑学》作者D.Q.麦克伦尼在书中提出了28种非逻辑思维形式，抛却了逻辑学一贯的刻板理论，转而以轻松的笔触带领我们畅游这个精彩无比的逻辑世界；《蝴蝶梦》我错了，我曾以为付出自己就是爱你。全球公认20世纪伟大的爱情经典，大陆独家合法授权。",
                          @"date":@"",
                          @"imgs":@[@"http://ww2.sinaimg.cn/mw690/c2719308gw1f2hav54htyj20dj0l00uk.jpg",
                                    @"http://ww4.sinaimg.cn/mw690/c2719308gw1f2hav47jn7j20dj0j341h.jpg"],
                          @"statusID":@"6"},
                        @{@"name":@"G-SHOCK",
                          @"avatar":@"http://tp3.sinaimg.cn/1595142730/50/5691224157/1",
                          @"content":@"就算平时没有时间，周末也要带着G-SHOCK到户外走走，感受大自然的满满正能量！",
                          @"date":@"1459668442",
                          @"imgs":@[@"http://ww2.sinaimg.cn/mw690/5f13f24ajw1f2hc1r6j47j20dc0dc0t4.jpg"],
                          @"statusID":@"7"},
                        @{@"name":@"型格志style",
                          @"avatar":@"http://tp4.sinaimg.cn/5747171147/50/5741401933/0",
                          @"content":@"春天卫衣的正确打开方式~",
                          @"date":@"1459668442",
                          @"imgs":@[@"http://ww2.sinaimg.cn/mw690/006gWxKPgw1f2jeloxwhnj30fu0g0ta5.jpg",
                                    @"http://ww3.sinaimg.cn/mw690/006gWxKPgw1f2jelpn9bdj30b40gkgmh.jpg",
                                    @"http://ww1.sinaimg.cn/mw690/006gWxKPgw1f2jelriw1bj30fz0g175g.jpg",
                                    @"http://ww3.sinaimg.cn/mw690/006gWxKPgw1f2jelt1kh5j30b10gmt9o.jpg",
                                    @"http://ww4.sinaimg.cn/mw690/006gWxKPgw1f2jeluxjcrj30fw0fz0tx.jpg",
                                    @"http://ww3.sinaimg.cn/mw690/006gWxKPgw1f2jelzxngwj30b20godgn.jpg",
                                    @"http://ww2.sinaimg.cn/mw690/006gWxKPgw1f2jelwmsoej30fx0fywfq.jpg",
                                    @"http://ww4.sinaimg.cn/mw690/006gWxKPgw1f2jem32ccrj30xm0sdwjt.jpg",
                                    @"http://ww4.sinaimg.cn/mw690/006gWxKPgw1f2jelyhutwj30fz0fxwfr.jpg",],
                          @"statusID":@"8"},
                        @{@"name":@"数字尾巴",
                          @"avatar":@"http://tp1.sinaimg.cn/1726544024/50/5630520790/1",
                          @"content":@"外媒 AndroidAuthority 日前曝光诺基亚首款回归作品 NOKIA A1 的渲染图，手机的外形很 N 记，边框控制的不错。这是一款纯正的 Android 机型，传闻手机将采用 5.5 英寸 1080P 屏幕，搭载骁龙 652，Android 6.0 系统，并使用了诺基亚自家的 Z 启动器，不过具体发表的时间还是未知。尾巴们你会期待吗？",
                          @"date":@"1459668442",
                          @"imgs":@[@"http://ww3.sinaimg.cn/mw690/66e8f898gw1f2jck6jnckj20go0fwdhb.jpg"],
                          @"statusID":@"9"},
                        @{@"name":@"欧美街拍XOXO",
                          @"avatar":@"http://tp4.sinaimg.cn/1708004923/50/1283204657/0",
                          @"content":@"3.31～4.2 肯豆",
                          @"date":@"1459668442",
                          @"imgs":@[@"http://ww2.sinaimg.cn/mw690/65ce163bjw1f2jdkd2hgjj20cj0gota8.jpg",
                                    @"http://ww1.sinaimg.cn/mw690/65ce163bjw1f2jdkjdm96j20bt0gota9.jpg",
                                    @"http://ww2.sinaimg.cn/mw690/65ce163bjw1f2jdkvwepij20go0clgnd.jpg",
                                    @"http://ww4.sinaimg.cn/mw690/65ce163bjw1f2jdl2ao77j20ci0gojsw.jpg",],
                          @"statusID":@"10"},];
    return _fakeDatasource;
}

@end
