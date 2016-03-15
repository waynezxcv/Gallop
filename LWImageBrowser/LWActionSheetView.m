//
//  LWActionSheetView.m
//  WarmerApp
//
//  Created by 刘微 on 16/3/2.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWActionSheetView.h"
#import "UIImage+ImageEffects.h"
#import "LWActionSheetTableViewCell.h"
#import "LWDefine.h"


const CGFloat cellHeight = 60.0f;


@interface LWActionSheetView ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIImageView* screenshotImageView;
@property (nonatomic,copy) NSArray* dataSource;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,assign) NSInteger titlesCount;

@end

@implementation LWActionSheetView

- (id)initTilesArray:(NSArray *)titles delegate:(id <LWActionSheetViewDelegate>)delegate {
    self = [super initWithFrame:SCREEN_BOUNDS];
    if (self) {
        self.delegate = delegate;
        self.titlesCount = titles.count;
        self.dataSource = titles;

        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        UIImage* screenshot = [self _screenshotFromView:window];

        self.screenshotImageView = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
        self.screenshotImageView.backgroundColor = [UIColor blackColor];
        self.screenshotImageView.image = [screenshot applyBlurWithRadius:20
                                                               tintColor:RGB(0, 0, 0, 0.5f)
                                                   saturationDeltaFactor:1.4
                                                               maskImage:nil];
        [self addSubview:self.screenshotImageView];

        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, SCREEN_HEIGHT  - cellHeight * self.titlesCount , SCREEN_WIDTH, cellHeight * self.titlesCount)
                                                      style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tableView];
//        UITapGestureRecognizer* tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
//        tapGesture.delegate = self;
//        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

#pragma mark -

- (void)show {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];

    NSArray* cells = [self.tableView visibleCells];
    for (NSInteger i = 0;i < cells.count;i ++) {
        LWActionSheetTableViewCell* cell = cells[i];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.09f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cell show];
        });
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"cellIdentifier";
    LWActionSheetTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[LWActionSheetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.title = self.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self _hide];
    if ([self.delegate respondsToSelector:@selector(lwActionSheet:didSelectedButtonWithIndex:)]
        &&[self.delegate conformsToProtocol:@protocol(LWActionSheetViewDelegate)]) {
        [self.delegate lwActionSheet:self didSelectedButtonWithIndex:indexPath.row];
    }
}

- (void)tapView {
    [self _hide];
}

- (void)_hide {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f animations:^{
        weakSelf.tableView.frame = CGRectMake(0.0f, SCREEN_HEIGHT, SCREEN_WIDTH,  cellHeight * self.titlesCount);
        weakSelf.screenshotImageView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}


- (UIImage *)_screenshotFromView:(UIView *)aView {
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size,NO,[UIScreen mainScreen].scale);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshotImage;
}

#pragma mark - UIGestrueDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
