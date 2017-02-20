/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/






#import "ImageDemoTableViewCell.h"


@interface ImageDemoTableViewCell ()

@property (nonatomic,strong) LWAsyncDisplayView* displayView;

@end


@implementation ImageDemoTableViewCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.displayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.displayView];
        
    }
    return self ;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.displayView.frame = self.bounds;
}

- (void)setLayout:(LWLayout *)layout {
    if (_layout != layout) {
        _layout = layout;
        
        self.displayView.layout = self.layout;
    }
}

@end
