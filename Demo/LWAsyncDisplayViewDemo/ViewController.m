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
#import "LWAlchemy.h"
#import "CDStatus.h"


@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) TableViewHeader* tableViewHeader;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,assign,getter=isNeedRefresh) BOOL needRefresh;
@property (nonatomic,assign) NSInteger index;
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
    self.index = 0;
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
    
    self.index ++;
    
    NSString* content1 = [NSString stringWithFormat:@"statusID == 1...下拉刷新更新内容。。%ld",self.index];
    NSString* content2 = [NSString stringWithFormat:@"statusID == 2...下拉刷新更新内容。。%ld",self.index + 1];
    NSString* content3 = [NSString stringWithFormat:@"statusID == 3...下拉刷新更新内容。。%ld",self.index + 2];
    NSString* content4 = [NSString stringWithFormat:@"statusID == 4...下拉刷新更新内容。。%ld",self.index + 3];
    NSString* content5 = [NSString stringWithFormat:@"statusID == 5...下拉刷新更新内容。。%ld",self.index + 4];

    NSArray* arr = @[@{@"name":@"waynezxcv",
                       @"avatar":@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460",
                       @"content":content1,
                       @"date":@"1458666454",
                       @"imgs":@[@"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg"],
                       @"statusID":@1},
                     
                     @{@"name":@"waynezxcv",
                       @"avatar":@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460",
                       @"content":content1,
                       @"date":@"1458666454",
                       @"imgs":@[@"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg"],
                       @"statusID":@2},
                     
                     
                     @{@"name":@"waynezxcv",
                       @"avatar":@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460",
                       @"content":content3,
                       @"date":@"1458666454",
                       @"imgs":@[@"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg"],
                       @"statusID":@3},
                     
                     
                     @{@"name":@"waynezxcv",
                       @"avatar":@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460",
                       @"content":content4,
                       @"date":@"1458666454",
                       @"imgs":@[@"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg"],
                       @"statusID":@4},
                     
                     @{@"name":@"waynezxcv",
                       @"avatar":@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460",
                       @"content":content5,
                       @"date":@"1458666454",
                       @"imgs":@[@"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg",
                                 @"http://cdn.duitang.com/uploads/item/201308/30/20130830011805_dCHBT.jpeg"],
                       @"statusID":@5},
                     ];
    NSMutableArray* tmp = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i <100000; i ++) {
        [tmp addObjectsFromArray:arr];
    }
    [self.dataSource removeAllObjects];
    LWAlchemyCoreDataManager* manager = [LWAlchemyCoreDataManager sharedManager];
    [manager insertNSManagedObjectWithObjectClass:[CDStatus class] JSONsArray:tmp uiqueAttributesName:@"statusID"];
    [manager saveContext:^{
        NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"statusID" ascending:YES];
        [manager fetchNSManagedObjectWithObjectClass:[CDStatus class] predicate:nil sortDescriptor:@[sort] fetchOffset:0 fetchLimit:0 fetchReults:^(NSArray *results, NSError *error) {
            for (CDStatus* status in results) {
                CellLayout* cellLayout = [[CellLayout alloc] initWithCDStatusModel:status];
                [self.dataSource addObject:cellLayout];
            }
            [self refreshComplete];
        }];
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


@end
