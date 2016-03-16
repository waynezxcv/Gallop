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
#import "StatusModel.h"
#import "TableViewHeader.h"
#import "LWDefine.h"
#import "CellLayout.h"


@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) TableViewHeader* tableViewHeader;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,assign,getter=isNeedRefresh) BOOL needRefresh;

@end

const CGFloat kRefreshBoundary = 170.0f;

@implementation ViewController

#pragma mark - ViewControllerLifeCycle


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isNeedRefresh) {
        [self refreshBegin];
    }
}

- (void)setup {
    self.needRefresh = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    NSDictionary* attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    self.navigationItem.title = @"朋友圈";
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CellLayout* cellLayout = self.dataSource[indexPath.row];
    cell.layout = cellLayout;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellLayout* cellLayout = self.dataSource[indexPath.row];
    return cellLayout.cellHeight;
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
        [self downloadData];
    }];
}

- (void)refreshComplete {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableViewHeader refreshingAnimateStop];
        [UIView animateWithDuration:0.35f animations:^{
            self.tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
        } completion:^(BOOL finished) {
            [self.tableView reloadData];
            self.needRefresh = NO;
        }];
    });
}

- (void)downloadData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* path = [bundle pathForResource:@"timeline" ofType:@"plist"];
        NSArray* dataArray = [NSArray arrayWithContentsOfFile:path];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.dataSource removeAllObjects];
            for (NSDictionary* dataDict in dataArray) {
                NSDictionary* mapDict = @{@"name":@"name",
                                          @"avatar":@"avatar",
                                          @"date":@"timeStamp",
                                          @"content":@"text",
                                          @"imgs":@"imgs"};
                StatusModel* statusModel = [[StatusModel alloc]
                                            initWithJSON:dataDict
                                            JSONKeyPathsByPropertyKey:mapDict];
                CellLayout* cellLayout = [[CellLayout alloc] initWithStatusModel:statusModel];
                    [self.dataSource addObject:cellLayout];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshComplete];
            });
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self refreshComplete];
            });
        });
    });
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


@end
