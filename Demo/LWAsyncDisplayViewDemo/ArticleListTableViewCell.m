
/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/



#import "ArticleListTableViewCell.h"
#import "GallopUtils.h"
#import "UIImageView+WebCache.h"

@interface ArticleListTableViewCell ()

@property (nonatomic,strong) UIImageView* coverImageView;

@end


@implementation ArticleListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.coverImageView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:self.coverImageView];
        self.textLabel.numberOfLines = 0;
        self.textLabel.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.coverImageView.frame = CGRectMake(10, 10, 50, 50);
    self.textLabel.frame = CGRectMake(70.0f, 10.0f, SCREEN_WIDTH - 80.0f, 50.0f);
}

- (void)setModel:(ArticleListModel *)model {
    if (_model != model) {
        _model = model;
    }
    NSString* urlString = [self.model.images firstObject];
    NSURL* URL = [NSURL URLWithString:urlString];
    [self.coverImageView sd_setImageWithURL:URL];
    self.textLabel.text = self.model.title;
}

@end
