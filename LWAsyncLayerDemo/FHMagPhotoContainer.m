//
//  FHMagPhotoContainer.m
//  FHMagProject
//
//  Created by 刘微 on 15/10/4.
//  Copyright © 2015年 WayneInc. All rights reserved.
//

#import "FHMagPhotoContainer.h"
#import "LWImageView.h"


@interface FHMagPhotoContainer ()

@end

static const CGFloat gap = 5.0f;

@implementation FHMagPhotoContainer

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        NSInteger row = 0;
        NSInteger column = 0;
        self.imageWidth = (SCREENWIDTH - 130.0f)/3;
        for (NSInteger i = 0; i < 9; i ++) {
            LWImageView* imageView = [[LWImageView alloc] initWithFrame:CGRectMake(column * (self.imageWidth + gap), row * (self.imageWidth + gap), self.imageWidth, self.imageWidth)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.tag = 10 + i;
            [self addSubview:imageView];
            
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedImageView:)];
            [imageView addGestureRecognizer:tapGesture];
            
            UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            effectView.frame = imageView.bounds;
            effectView.alpha = 0.95f;
            effectView.tag = 20 + i;
            [imageView addSubview:effectView];
            
            column = column + 1;
            if (column > 2) {
                column = 0;
                row = row + 1;
            }
        }
    }
    return self;
}


#pragma mark - Setter

- (void)setURLArray:(NSArray *)URLArray {
    if (_URLArray != URLArray) {
        _URLArray = URLArray;
        [self setupImage];
    }
}

- (void)setupImage {
    NSInteger row = 0;
    NSInteger column = 0;
    __weak FHMagPhotoContainer* weakSelf = self;
    for (NSInteger i = 0; i < self.itemModel.totalPhotoCount; i ++) {
        LWImageView* imageView = (LWImageView *)[self viewWithTag:10 + i];
        UIVisualEffectView* effectView = (UIVisualEffectView *)[imageView viewWithTag:i + 20];
        SDWebImageManager* manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[self.URLArray objectAtIndex:i] options:SDWebImageLowPriority
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                 if (finished) {
                                     if (weakSelf.itemModel.totalPhotoCount == 1) {
                                         imageView.frame = CGRectMake(0, 0, image.size.width / image.size.height * weakSelf.imageWidth * 2.5f, weakSelf.imageWidth * 2.5f);
                                     } else {
                                         imageView.frame = CGRectMake(column * (weakSelf.imageWidth + gap), row * (weakSelf.imageWidth + gap), weakSelf.imageWidth, weakSelf.imageWidth);
                                     }
                                     imageView.image = image;
//                                     imageView.hidden = NO;
                                     [UIView animateWithDuration:0.2f animations:^{
                                         imageView.alpha = 1.0f;
                                     }];
                                     if (i < weakSelf.itemModel.showPhotoCount) {
                                         effectView.hidden = YES;
                                     }
                                     else {
                                         effectView.hidden = NO;
                                     }
                                 }
                             }];
        column = column + 1;
        if (column > 2) {
            column = 0;
            row = row + 1;
        }
    }
    
}


- (void)cleanUp {
    for (NSInteger i = 0; i < 9; i ++) {
        UIImageView* imageView = (UIImageView *)[self viewWithTag:10 + i];
        imageView.frame = CGRectZero;
//        imageView.hidden = YES;
        imageView.alpha = 0.0f;
    }
}

- (void)didClickedImageView:(UITapGestureRecognizer *)tapGesutre {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    NSInteger index = tapGesutre.view.tag - 10;
    NSMutableArray* modelArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0 ; i < self.itemModel.totalPhotoCount; i ++) {
        UIImageView* imageView = (UIImageView *)[self viewWithTag:10 + i];
        CGRect originRect = [self convertRect:imageView.frame toView:window];
        LWImageModel* model = [[LWImageModel alloc] initWithplaceholder:nil thumbnailURL:[self.itemModel.thumbnailArray objectAtIndex:i] HDURL:[self.itemModel.imageArray objectAtIndex:i] originRect:originRect index:index];
        if (imageView.image != nil) {
            model.thumbnailImage = imageView.image;
        }
        [modelArray addObject:model];
    }
    if ([self.delegate respondsToSelector:@selector(didSelectedImageAtIndex:imageModelArray:itemModel:)]) {
        if (index < self.itemModel.showPhotoCount) {
            LWImageModel* model = [modelArray objectAtIndex:index];
            if (model.thumbnailImage != nil) {
                [self.delegate didSelectedImageAtIndex:index imageModelArray:modelArray itemModel:self.itemModel];
            }
        }
        else {
//            if ([[NSUserDefaults standardUserDefaults] stringForKey:@"uid"] == nil) {
//                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你目前是游客身份,登陆才能查看更多照片哦~" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//                [alertView show];
//            } else {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你目前是普通会员,升级VIP才能查看更多照片哦~" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
//            }
        }
    }
}

@end
