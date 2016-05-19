//
//  TableViewHeader.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/3/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "TableViewHeader.h"
#import "LWDefine.h"
#import "UIImageView+WebCache.h"


@interface TableViewHeader ()

@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,strong) UIView* avatarContainer;
@property (nonatomic,strong) UIImageView* avatarView;
@property (nonatomic,strong) UILabel* nameLabel;
@property (nonatomic,strong) UIImageView* loadingView;

@end

@implementation TableViewHeader

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.imageView];
        [self addSubview:self.avatarContainer];
        [self.avatarContainer addSubview:self.avatarView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.loadingView];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460"]];
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460"]];
        self.nameLabel.text = @"Waynezxcv";
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, - 60.0f, SCREEN_WIDTH, 240.0f)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = RGB(50, 50, 50, 1);
    }
    return _imageView;
}

- (UIView *)avatarContainer {
    if (!_avatarContainer) {
        _avatarContainer = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 75.0f, 200.0f, 65.0f, 65.0f)];
        _avatarContainer.backgroundColor = [UIColor whiteColor];
    }
    return _avatarContainer;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(2.5f, 2.5f, 60.0f, 60.0f)];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.clipsToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 235.0f, 215.0f, 150.0f, 20.0f)];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentRight;
    }
    return _nameLabel;
}

- (UIImageView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, -70.0f, 25.0f, 25.0f)];
        _loadingView.contentMode = UIViewContentModeScaleAspectFill;
        _loadingView.image = [UIImage imageNamed:@"loading"];
        _loadingView.clipsToBounds = YES;
        _loadingView.backgroundColor = [UIColor clearColor];
    }
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
