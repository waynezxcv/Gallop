//
//  DiscoverTableViewCell.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "DiscoverTableViewCell.h"
#import "ContainerView.h"
#import "LWRunLoopObserver.h"
#import "UIImageView+WebCache.h"



@interface DiscoverTableViewCell ()

@property (nonatomic,strong) ContainerView* backgroundImageView;
@property (nonatomic,strong) UIImageView* avatarImageView;
@property (nonatomic,strong) MenuView* menuView;
@property (nonatomic,strong) NSMutableArray* imageViews;


@end



@implementation DiscoverTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        self.backgroundImageView = [[ContainerView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.backgroundImageView];

        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.avatarImageView];

        self.menuView = [[MenuView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.menuView];

        self.imageViews = [[NSMutableArray alloc] initWithCapacity:9];
        for (NSInteger i = 0 ; i < 9; i ++) {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.contentView addSubview:imageView];
            [self.imageViews addObject:imageView];
        }
    }
    return self;
}


- (void)setLayout:(DiscoverLayout *)layout {
    if (_layout != layout) {
        _layout = layout;
    }
    self.backgroundImageView.layout = self.layout;
}


- (void)cleanUp {
    for (NSInteger i = 0; i < 9; i ++) {
        UIImageView* imageView = [self.imageViews objectAtIndex:i];
        imageView.frame = CGRectZero;
        imageView.hidden = YES;
    }
    [self.backgroundImageView cleanUp];
}

- (void)drawContent {
    self.backgroundImageView.frame = CGRectMake(0,
                                                0,
                                                SCREEN_WIDTH,
                                                self.layout.cellHeight);
    self.avatarImageView.frame = self.layout.avatarPosition;
    [self.avatarImageView sd_setImageWithURL:self.layout.statusModel.user.avatarURL];
    self.menuView.frame = CGRectMake(self.layout.menuPosition.origin.x,
                                     self.layout.menuPosition.origin.y - 12.5f,
                                     0.0f,
                                     40.0f);
    [self setupImages];
    [self.backgroundImageView drawConent];

}

- (void)setupImages {
    NSInteger row = 0;
    NSInteger column = 0;
    for (NSInteger i = 0; i < self.layout.statusModel.imageModels.count; i ++) {
        UIImageView* imageView = [self.imageViews objectAtIndex:i];
        imageView.frame = CGRectMake(self.layout.imagesPosition.origin.x + (column * 85.0f),
                                     self.layout.imagesPosition.origin.y + (row * 85.0f),
                                     80.0f,
                                     80.0f);
        ImageModels* imageModel = [self.layout.statusModel.imageModels objectAtIndex:i];
        NSURL* URL = imageModel.thumbnailURL;
        [imageView sd_setImageWithURL:URL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            imageView.hidden = NO;
        }];
        column = column + 1;
        if (column > 2) {
            column = 0;
            row = row + 1;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.layout.menuPosition, point)) {
        
    }
}

- (void)menuViewShow {
    [UIView animateWithDuration:0.2f animations:^{
        self.menuView.frame = CGRectMake(self.layout.menuPosition.origin.x - 170.0f,
                                         self.layout.menuPosition.origin.y - 12.5f,
                                         165.0f,
                                         40.0f);
    } completion:^(BOOL finished) {}];
}

- (void)menuViewHide {
    [UIView animateWithDuration:0.2f animations:^{
        self.menuView.frame = CGRectMake(self.layout.menuPosition.origin.x,
                                         self.layout.menuPosition.origin.y - 12.5f,
                                         0.0f,
                                         40.0f);
    } completion:^(BOOL finished) {

    }];
}




@end


@implementation MenuView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGB(76, 81, 84, 0.85);
        self.layer.cornerRadius = 3.0f;
        self.layer.masksToBounds = YES;
    }
    return self;
}
@end
