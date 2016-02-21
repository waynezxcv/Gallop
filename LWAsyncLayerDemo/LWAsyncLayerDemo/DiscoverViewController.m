//
//  DiscoverViewController.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "DiscoverViewController.h"
#import "DiscoverTableViewCell.h"
#import "LWFPSLabel.h"
#import "DiscoverHeader.h"
#import "ProfileModel.h"
#import "DiscoverStatuModel.h"
#import "DiscoverLayout.h"
#import "LWImageBrowser.h"

@interface DiscoverViewController ()<UITableViewDataSource,UITableViewDelegate,DiscoverTableViewCellDelegate>

@property (nonatomic,strong) LWFPSLabel* fpsLabel;
@property (nonatomic,strong) DiscoverHeader* discoverHeader;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,strong) NSDateFormatter* dateFormatter;
@property (nonatomic,assign,getter=isNeedRefresh) BOOL needRefresh;

@end

@implementation DiscoverViewController

#pragma mark - Setup
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:SCREEN_BOUNDS style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.discoverHeader;
        _tableView.decelerationRate = 1.0f;
    }
    return _tableView;
}

- (LWFPSLabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [[LWFPSLabel alloc] initWithFrame:CGRectMake(10.0f, SCREEN_HEIGHT - 30.0f, 55.0f, 20.0f)];
    }
    return _fpsLabel;
}

- (DiscoverHeader *)discoverHeader {
    if (!_discoverHeader) {
        _discoverHeader = [[DiscoverHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, 270.0f)];
    }
    return _discoverHeader;
}

- (void)setupNavigationBar {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    NSDictionary* attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    self.navigationItem.title = @"朋友圈";
}


- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM月dd日"];
    }
    return _dateFormatter;
}


#pragma mark - FakeDataSource
- (void)parseDataWithDataArray:(NSArray *)dataArray {
    [self.dataSource removeAllObjects];
    for (NSDictionary* dataDict in dataArray) {
        //发布者
        NSDictionary* userDict = [dataDict objectForKey:@"user"];
        UserModel* userModel = [[UserModel alloc] init];
        userModel.name = userDict[@"name"];
        userModel.avatarURL = [NSURL URLWithString:userDict[@"avatar"]];
        //评论
        NSArray* commentArray = [dataDict objectForKey:@"comments"];
        NSMutableArray* comments = [[NSMutableArray alloc] initWithCapacity:commentArray.count];
        for (NSDictionary* commentDict in commentArray) {
            DiscoverCommentModel* commentModel = [[DiscoverCommentModel alloc] init];
            commentModel.content = commentDict[@"content"];
            NSDictionary* fromUserDict = [dataDict objectForKey:@"fromUser"];
            UserModel* fromUserModel = [[UserModel alloc] init];
            fromUserModel.name = fromUserDict[@"name"];
            fromUserModel.avatarURL = fromUserDict[@"avatar"];
            commentModel.fromUser = fromUserModel;
            NSDictionary* toUserDict = [dataDict objectForKey:@"toUser"];
            UserModel* toUserModel = [[UserModel alloc] init];
            toUserModel.name = toUserDict[@"name"];
            toUserModel.avatarURL = toUserDict[@"avatar"];
            commentModel.toUser = toUserModel;
            [comments addObject:commentModel];
        }
        //点赞
        NSArray* likesArray = [dataDict objectForKey:@"likes"];
        NSMutableArray* likes = [[NSMutableArray alloc] initWithCapacity:likesArray.count];
        for (NSDictionary* likeDict in likesArray) {
            UserModel* likeUser = [[UserModel alloc] init];
            likeUser.name = likeDict[@"name"];
            likeUser.avatarURL = likeDict[@"avatar"];
            [likes addObject:likeUser];
        }
        //图片
        NSArray* imgs = [dataDict objectForKey:@"imgs"];
        NSMutableArray* imageModels = [[NSMutableArray alloc] initWithCapacity:imgs.count];
        for (NSString* url in imgs) {
            ImageModels* imageModel = [[ImageModels alloc] init];
            imageModel.thumbnailURL = [NSURL URLWithString:url];
            imageModel.HDURL = [NSURL URLWithString:url];
            [imageModels addObject:imageModel];
        }
        DiscoverStatuModel* statuModel = [[DiscoverStatuModel alloc] init];
        statuModel.imageModels = imageModels;
        statuModel.user = userModel;
        statuModel.comments = comments;
        statuModel.likedUsers = likes;
        statuModel.text = dataDict[@"text"];
        NSTimeInterval timeInterval = [dataDict[@"timeStamp"] floatValue];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        statuModel.timeStamp = [self.dateFormatter stringFromDate:date];
        switch ([dataDict[@"type"] integerValue]) {
            case 0:
                statuModel.statuType = DiscoverStatuTypeNormal;
                break;
            case 1:
                statuModel.statuType = DiscoverStatuTypeShare;
                break;
            case 2:
                statuModel.statuType = DiscoverStatuTypeVideo;
                break;
            case 3:
                statuModel.statuType = DiscoverStatuTypeAdvertising;
                break;
            default:
                statuModel.statuType = DiscoverStatuTypeNormal;
                break;
        }
        DiscoverLayout* layout = [[DiscoverLayout alloc] initWithStatusModel:statuModel];
        [self.dataSource addObject:layout];
        [self.dataSource addObjectsFromArray:self.dataSource];
    }
}

#pragma mark - ViewControllerLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.fpsLabel];
    ProfileModel* profileModel = [[ProfileModel alloc] init];
    profileModel.backgroundImageURL = @"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460";
    profileModel.avatarURL = @"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460";
    profileModel.name = @"Waynezxcv";
    self.discoverHeader.profileModel = profileModel;
    self.needRefresh = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isNeedRefresh == YES) {
        [self refreshBegin];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    [self.discoverHeader loadingViewAnimateWithScrollViewContentOffset:offset];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    if (offset <= - 170.0f) {
        [self refreshBegin];
    }
}

- (void)refreshBegin {
    [UIView animateWithDuration:0.2f animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(160.0f, 0.0f, 0.0f, 0.0f);
    } completion:^(BOOL finished) {
        [self.discoverHeader refreshingAnimateBegin];
        [self downloadData];
    }];
}

- (void)refreshComplete {
    [self.discoverHeader refreshingAnimateStop];
    [UIView animateWithDuration:0.35f animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
        self.needRefresh = NO;
    }];
}

- (void)downloadData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* path = [bundle pathForResource:@"discoverTimeline" ofType:@"plist"];
        NSArray* dataArray = [NSArray arrayWithContentsOfFile:path];
        [self parseDataWithDataArray:dataArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self refreshComplete];
            });
        });
    });
}

#pragma mark - UITableViewDataSource/UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"discoverCellIdentifier";
    DiscoverTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[DiscoverTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell cleanUp];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layout = [self.dataSource objectAtIndex:indexPath.row];
    [cell drawContent];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiscoverLayout* layout = [self.dataSource objectAtIndex:indexPath.row];
    return layout.cellHeight;
}

#pragma mark - TableViewCellDelegate
- (void)discoverTableViewCell:(DiscoverTableViewCell *)cell
    didClickedImageWithLayout:(DiscoverLayout *)layout
                      atIndex:(NSInteger)index {
    NSMutableArray* tmpArray = [[NSMutableArray alloc] initWithCapacity:layout.statusModel.imageModels.count];
    for (NSInteger i = 0; i < layout.statusModel.imageModels.count; i ++) {
        ImageModels* m = layout.statusModel.imageModels[i];
        CGRect originPosition = CGRectFromString(layout.imagePostionArray[i]);
        LWImageBrowserModel* model = [[LWImageBrowserModel alloc] initWithplaceholder:nil
                                                                         thumbnailURL:m.thumbnailURL.absoluteString
                                                                                HDURL:m.HDURL.absoluteString imageViewSuperView:cell positionAtSuperView:originPosition
                                                                                index:i];
        
        [tmpArray addObject:model];
    }
    LWImageBrowser* browser = [[LWImageBrowser alloc] initWithParentViewController:self
                                                                             style:LWImageBrowserStyleDefault
                                                                   backgroundStyle:LWImageBrowserBackgroundStyleBlack                                                                        imageModels:tmpArray
                                                                      currentIndex:index];
    [browser show];
}

@end
