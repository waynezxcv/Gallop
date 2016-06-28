
/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/



#import "ArticleListTableViewCell.h"
#import "GallopUtils.h"
#import "UIImageView+WebCache.h"


@implementation ArticleListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView.backgroundColor = [UIColor grayColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(10, 10, 50, 50);
    self.textLabel.frame = CGRectMake(70.0f, 25.0f, SCREEN_WIDTH - 80.0f, 20.0f);
}

- (void)setModel:(ArticleListModel *)model {
    if (_model != model) {
        _model = model;
    }
    NSString* urlString = [self.model.images firstObject];
    NSURL* URL = [NSURL URLWithString:urlString];
    [self.imageView sd_setImageWithURL:URL];
    self.textLabel.text = self.model.title;
}

@end
