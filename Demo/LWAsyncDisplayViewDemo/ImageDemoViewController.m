/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/






#import "ImageDemoViewController.h"
#import "ImageDemoTableViewCell.h"






@interface ImageDemoViewController () <UITableViewDelegate,UITableViewDataSource>


@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;

@end

@implementation ImageDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.title = @"LWImageStorage使用示例";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"cellIdentifier";
    ImageDemoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ImageDemoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    LWLayout* layout = [self.dataSource objectAtIndex:indexPath.row];
    cell.layout = layout;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130.0f;
}

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (_dataSource) {
        return _dataSource;
    }
    _dataSource = [[NSMutableArray alloc] init];
    
    {
        
        LWTextStorage* textStorage = [[LWTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f,100.0f);
        textStorage.text = @"加载本地图片,默认图片会直接绘制在LWAsyncDisplayView上，减少View的层级。";
        textStorage.vericalAlignment = LWTextVericalAlignmentCenter;
        
        
        LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
        imageStorage.contents = [UIImage imageNamed:@"test"];
        imageStorage.backgroundColor = [UIColor grayColor];
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width/2 + 15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f, 100.0f);
        
        
        LWLayout* layout = [[LWLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
    }
    
    
    {
        
        LWTextStorage* textStorage = [[LWTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width/2- 30.0f,100.0f);
        textStorage.text = @"加载本地图片，并设置圆角半径";
        textStorage.vericalAlignment = LWTextVericalAlignmentCenter;
        
        
        LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
        imageStorage.contents = [UIImage imageNamed:@"test"];
        imageStorage.backgroundColor = [UIColor grayColor];
        imageStorage.cornerRadius = 50.0f;
        imageStorage.cornerBackgroundColor = [UIColor whiteColor];
        imageStorage.cornerBorderColor = [UIColor redColor];
        imageStorage.cornerBorderWidth = 5.0f;
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width/2 + 15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f, 100.0f);
        
        
        LWLayout* layout = [[LWLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
    }
    
    {
        LWTextStorage* textStorage = [[LWTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width/2- 30.0f,100.0f);
        textStorage.text = @"加载本地图片，并进行模糊处理";
        textStorage.vericalAlignment = LWTextVericalAlignmentCenter;
        
        
        LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
        imageStorage.contents = [UIImage imageNamed:@"test"];
        imageStorage.backgroundColor = [UIColor grayColor];
        imageStorage.isBlur = YES;
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width/2 + 15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f, 100.0f);
        
        
        LWLayout* layout = [[LWLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
    }
    
    {
        LWTextStorage* textStorage = [[LWTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f,100.0f);
        textStorage.text = @"加载网络图片";
        textStorage.vericalAlignment = LWTextVericalAlignmentCenter;
        
        
        LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width/2 + 15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f, 100.0f);
        imageStorage.contents = [NSURL URLWithString:@"http://img4.bitautoimg.com/autoalbum/files/20101220/862/13374086240035_1469891_15.JPG"];
        imageStorage.clipsToBounds = YES;
        
        
        LWLayout* layout = [[LWLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
    }
    
    {
        
        LWTextStorage* textStorage = [[LWTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f,100.0f);
        textStorage.text = @"加载网络图片,并设置圆角半径，处理后的图片将直接缓存，下次加载时就无需再次处理而是直接读取缓存了。";
        textStorage.vericalAlignment = LWTextVericalAlignmentCenter;
        
        
        LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width/2 + 15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f, 100.0f);
        imageStorage.contents = [NSURL URLWithString:@"http://img4.bitautoimg.com/autoalbum/files/20101220/862/13374086240035_1469891_15.JPG"];
        imageStorage.clipsToBounds = YES;
        imageStorage.cornerRadius = 50.0f;
        imageStorage.cornerBorderColor = [UIColor orangeColor];
        imageStorage.cornerBorderWidth = 5.0f;
        
        
        
        LWLayout* layout = [[LWLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
        
    }
    
    {
        
        LWTextStorage* textStorage = [[LWTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f,100.0f);
        textStorage.text = @"加载网络图片,并进行模糊处理，处理后的图片将直接缓存，下次加载时就无需再次处理而是直接读取缓存了。";
        textStorage.vericalAlignment = LWTextVericalAlignmentCenter;
        
        
        LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width/2 + 15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f, 100.0f);
        imageStorage.contents = [NSURL URLWithString:@"http://img4.bitautoimg.com/autoalbum/files/20101220/862/13374086240035_1469891_15.JPG"];
        imageStorage.clipsToBounds = YES;
        imageStorage.isBlur = YES;
        
        LWLayout* layout = [[LWLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
        
    }
    
    {
        
        LWTextStorage* textStorage = [[LWTextStorage alloc] init];
        textStorage.frame = CGRectMake(15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f,100.0f);
        textStorage.text = @"加载网络GIF图片";
        textStorage.vericalAlignment = LWTextVericalAlignmentCenter;
        
        LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
        imageStorage.contentMode = UIViewContentModeScaleAspectFill;
        imageStorage.frame = CGRectMake(self.view.bounds.size.width/2 + 15.0f, 15.0f, self.view.bounds.size.width/2 - 30.0f, 100.0f);
        imageStorage.contents = [NSURL URLWithString:@"http://wx2.sinaimg.cn/bmiddle/784fda03gy1fcw8zl4zqrg209h04x7wi.gif"];
        imageStorage.clipsToBounds = YES;
        
        LWLayout* layout = [[LWLayout alloc] init];
        [layout addStorage:imageStorage];
        [layout addStorage:textStorage];
        [_dataSource addObject:layout];
        
    }
    
    return _dataSource;
}


@end
