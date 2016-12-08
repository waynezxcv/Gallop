/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/




#import "RootViewController.h"
#import "RichTextDemo1ViewController.h"
#import "CornerRadiusViewController.h"
#import "MomentsViewController.h"
#import "ArticleListViewController.h"



@interface RootViewController ()

<UITableViewDelegate,UITableViewDataSource>

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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"LWTextStorage使用示例";
            break;
        case 1:
            cell.textLabel.text = @"LWImageStorage使用示例";
            break;
        case 2:
            cell.textLabel.text = @"使用Gallop构建Feeds示例";
            break;
        case 3:
            cell.textLabel.text = @"使用Gallop进行HTML解析示例";
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:{
            RichTextDemo1ViewController* vc = [[RichTextDemo1ViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:{
            CornerRadiusViewController* vc = [[CornerRadiusViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:{
            MomentsViewController* vc = [[MomentsViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:{
            ArticleListViewController* vc = [[ArticleListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
    }
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath NS_DEPRECATED_IOS(2_0, 3_0) __TVOS_PROHIBITED {
    return UITableViewCellAccessoryDisclosureIndicator;
}

@end
