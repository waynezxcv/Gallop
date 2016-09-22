/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/




#import "RootViewController.h"
#import "RichTextDemo1ViewController.h"
#import "RichTextDemo2ViewController.h"
#import "CornerRadiusViewController.h"
#import "MomentsViewController.h"
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"LWTextStorage-图文混排和添加点击事件Demo";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"LWTextStorage-富文本Demo";
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"LWImageStorage-图片设置圆角半径和模糊效果Demo";
    }
    else if (indexPath.row == 3) {
        cell.textLabel.text = @"Gallop构建的顺滑的朋友圈Demo";
    }
    else if (indexPath.row == 4) {
        cell.textLabel.text = @"Gallop进行HTML解析的知乎日报Demo";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        RichTextDemo1ViewController* vc = [[RichTextDemo1ViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 1) {
        RichTextDemo2ViewController* vc = [[RichTextDemo2ViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2) {
        CornerRadiusViewController* vc = [[CornerRadiusViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 3) {
        MomentsViewController* vc = [[MomentsViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 4) {
        ArticleListViewController* vc = [[ArticleListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath NS_DEPRECATED_IOS(2_0, 3_0) __TVOS_PROHIBITED {
    return UITableViewCellAccessoryDisclosureIndicator;
}

@end
