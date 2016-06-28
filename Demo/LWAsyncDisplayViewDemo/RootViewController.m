/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/




#import "RootViewController.h"
#import "ViewController.h"
#import "CoreTextDemoViewController.h"
#import "ArticleListViewController.h"


@interface RootViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView* tableView;

@end

@implementation RootViewController

- (void)loadView {
    [super loadView];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    NSDictionary* attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Gallop";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"CoreText Demo";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Wechat moment Demo";
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"Zhihu Daily(HTML Parsing) Demo";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        CoreTextDemoViewController* vc = [[CoreTextDemoViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 1) {
        ViewController* vc = [[ViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2) {
        ArticleListViewController* vc = [[ArticleListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath NS_DEPRECATED_IOS(2_0, 3_0) __TVOS_PROHIBITED {
    return UITableViewCellAccessoryDisclosureIndicator;
}

@end
