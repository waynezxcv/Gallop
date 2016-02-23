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
#import "LWLabel.h"

@interface DiscoverTableViewCell ()

@property (nonatomic,strong) ContainerView* backgroundImageView;
@property (nonatomic,strong) LWLabel* label;
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

        self.label = [[LWLabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.label];

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
    }
    [self.backgroundImageView cleanUp];
}

- (void)drawContent {
    self.backgroundImageView.frame = CGRectMake(0,0,SCREEN_WIDTH,self.layout.cellHeight);
    self.label.frame = CGRectMake(0,0,SCREEN_WIDTH,self.layout.cellHeight);
    self.label.layouts = @[self.layout.nameTextLayout,self.layout.textTextLayout,self.layout.timeStampTextLayout] ;
    self.avatarImageView.frame = self.layout.avatarPosition;
    [self.avatarImageView sd_setImageWithURL:self.layout.statusModel.user.avatarURL];
    //懒加载图片
    LWRunLoopObserver* obeserver = [LWRunLoopObserver observerWithTarget:self
                                                                selector:@selector(setupImages)
                                                                  object:nil];
    [obeserver commit];
    [self.backgroundImageView drawConent];
}

- (void)setupImages {
    for (NSInteger i = 0; i < self.layout.imagePostionArray.count; i ++) {
        UIImageView* imageView = [self.imageViews objectAtIndex:i];
        imageView.frame = CGRectFromString([self.layout.imagePostionArray objectAtIndex:i]);
        ImageModels* imageModel = [self.layout.statusModel.imageModels objectAtIndex:i];
        NSURL* URL = imageModel.thumbnailURL;
        [imageView sd_setImageWithURL:URL
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self touchMenuHandlerIfNeedWithPoint:point];
    [self touchImageHandlerIfNeedWithPoint:point];
}

//点击菜单按钮
- (void)touchMenuHandlerIfNeedWithPoint:(CGPoint)point {
    if (CGRectContainsPoint(self.layout.menuPosition, point)) {

    }
}

//点击图片
- (void)touchImageHandlerIfNeedWithPoint:(CGPoint)point {
    for (NSInteger i = 0; i < self.layout.imagePostionArray.count; i ++) {
        CGRect imagePosition = CGRectFromString(self.layout.imagePostionArray[i]);
        if (CGRectContainsPoint(imagePosition, point)) {
            if ([self.delegate respondsToSelector:@selector(discoverTableViewCell:didClickedImageWithLayout:atIndex:)]) {
                [self.delegate discoverTableViewCell:self didClickedImageWithLayout:self.layout atIndex:i];
            }
        }
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
