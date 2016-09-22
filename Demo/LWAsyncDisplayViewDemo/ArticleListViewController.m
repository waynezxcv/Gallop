
/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/



#import "ArticleListViewController.h"
#import "ArticleListTableViewCell.h"
#import "HTMLParsingViewController.h"
#import "LWActiveIncator.h"

@interface ArticleListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,assign) BOOL isNeedRefresh;

@end

@implementation ArticleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ariticle list";
    self.isNeedRefresh = YES;
    self.dataSource = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"articlelist" ofType:@"plist"];
    NSArray* list = [[NSArray alloc] initWithContentsOfFile:plistPath];

    for (NSDictionary* dict in list) {
        @autoreleasepool {
            ArticleListModel* model = [ArticleListModel modelWithJSON:dict];
            [self.dataSource addObject:model];
        }
    }
    [self.tableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"cellID";
    ArticleListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ArticleListTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    ArticleListModel* model = [self.dataSource objectAtIndex:indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ArticleListModel* model = [self.dataSource objectAtIndex:indexPath.row];
    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://daily.zhihu.com/story/%@",model.idString]];
    HTMLParsingViewController* vc = [[HTMLParsingViewController alloc] init];
    vc.URL = URL;
    NSLog(@"%@",URL);
    [self.navigationController pushViewController:vc animated:YES];
}



@end
