




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/



#import "TableViewHeader.h"
#import "Gallop.h"


@interface TableViewHeader ()

@property (nonatomic,strong) UIImageView* loadingView;

@end

@implementation TableViewHeader

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        LWAsyncDisplayView* displayView =
        [[LWAsyncDisplayView alloc] initWithFrame:CGRectMake(0.0f,- 100.0f,SCREEN_WIDTH,350.0f)];
        [self addSubview:displayView];
        [self addSubview:self.loadingView];
        
        LWLayout* layout = [[LWLayout alloc] init];
        LWImageStorage* bg = [[LWImageStorage alloc] init];
        bg.contents = [NSURL URLWithString:@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460"];
        bg.frame = CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, displayView.bounds.size.height);
        bg.clipsToBounds = YES;
        [layout addStorage:bg];
        
        LWImageStorage* avtar = [[LWImageStorage alloc] init];
        avtar.contents = [NSURL URLWithString:@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460"];
        avtar.frame = CGRectMake(SCREEN_WIDTH - 90.0f, displayView.bounds.size.height - 40.0f, 80.0f, 80.0f);
        avtar.cornerRadius = 0.01f;
        avtar.cornerBorderColor = [UIColor whiteColor];
        avtar.cornerBorderWidth = 5.0f;
        [layout addStorage:avtar];
        
        
        displayView.layout = layout;
    }
    return self;
}


- (UIImageView *)loadingView {
    if (_loadingView) {
        return _loadingView;
    }
    _loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f,-70.0f,25.0f,25.0f)];
    _loadingView.contentMode = UIViewContentModeScaleAspectFill;
    _loadingView.image = [UIImage imageNamed:@"loading"];
    _loadingView.clipsToBounds = YES;
    _loadingView.backgroundColor = [UIColor clearColor];
    return _loadingView;
}

- (void)loadingViewAnimateWithScrollViewContentOffset:(CGFloat)offset {
    if (offset <= 0 && offset > - 200.0f) {
        self.loadingView.transform = CGAffineTransformMakeRotation(offset* 0.1);
    }
}

- (void)refreshingAnimateBegin {
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.duration = 0.5f;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    [self.loadingView.layer addAnimation:rotationAnimation forKey:@"rotationAnimations"];
}

- (void)refreshingAnimateStop {
    [self.loadingView.layer removeAllAnimations];
}


@end
