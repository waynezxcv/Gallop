//
//  TableViewCell.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/3/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "TableViewCell.h"
#import "LWAsyncDisplayView.h"
#import "LWDefine.h"
#import "LWRunLoopObserver.h"
#import "CALayer+WebCache.h"


@interface TableViewCell ()<LWAsyncDisplayViewDelegate>

@property (nonatomic,strong) CALayer* avatarLayer;
@property (nonatomic,strong) NSMutableArray* imageLayers;
@property (nonatomic,strong) LWAsyncDisplayView* asyncDisplayView;
@property (nonatomic,assign,getter=isNeedLayoutImageViews) BOOL needLayoutImageViews;

@end

@implementation TableViewCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.needLayoutImageViews = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.asyncDisplayView];
        [self.asyncDisplayView.layer addSublayer:self.avatarLayer];
        [self.asyncDisplayView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedImageView:)]];
    }
    return self;
}

#pragma mark - Actions

//点击图片
- (void)didClickedImageView:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    for (NSInteger i = 0; i < self.layout.imagePostionArray.count; i ++) {
        CGRect imagePosition = CGRectFromString(self.layout.imagePostionArray[i]);
        if (CGRectContainsPoint(imagePosition, point)) {
            if ([self.delegate respondsToSelector:@selector(tableViewCell:didClickedImageWithCellLayout:atIndex:)] &&
                [self.delegate conformsToProtocol:@protocol(TableViewCellDelegate)]) {
                [self.delegate tableViewCell:self didClickedImageWithCellLayout:self.layout atIndex:i];
            }
        }
    }
}

/**
 *  点击链接回调
 *
 */
- (void)lwAsyncDicsPlayView:(LWAsyncDisplayView *)lwLabel didCilickedLinkWithfData:(id)data {
    if ([self.delegate respondsToSelector:@selector(tableViewCell:didClickedLinkWithData:)] &&
        [self.delegate conformsToProtocol:@protocol(TableViewCellDelegate)]) {
        [self.delegate tableViewCell:self didClickedLinkWithData:data];
    }
}

#pragma mark - Draw and setup

- (void)setLayout:(CellLayout *)layout {
    if (_layout == layout) {
        return;
    }
    if (_layout.imagePostionArray.count != layout.imagePostionArray.count) {
        self.needLayoutImageViews = YES;
    }
    else {
        self.needLayoutImageViews = NO;
    }
    _layout = layout;
    [self setupCell];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.asyncDisplayView.frame = CGRectMake(0,0,SCREEN_WIDTH,self.layout.cellHeight);
    self.avatarLayer.frame = self.layout.avatarPosition;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];//设置是否启动隐式动画
    if (self.isNeedLayoutImageViews) {
        [self resetImageLayers];
    }
    for (NSInteger i = 0; i < self.layout.imagePostionArray.count; i ++) {
        CALayer* imageLayer = [self.imageLayers objectAtIndex:i];
        imageLayer.frame = CGRectFromString([self.layout.imagePostionArray objectAtIndex:i]);
    }
    [CATransaction commit];
}

- (void)setupCell {
    [self.avatarLayer sd_setImageWithURL:self.layout.statusModel.avatar
                        placeholderImage:nil
                                 options:SDWebImageDelaySetContents];

    self.asyncDisplayView.layouts = @[self.layout.nameTextLayout,
                                      self.layout.contentTextLayout,
                                      self.layout.dateTextLayout];
    [self setupImages];
}

- (void)extraAsyncDisplayIncontext:(CGContextRef)context size:(CGSize)size {
    [self _drawImage:[UIImage imageNamed:@"menu"] rect:_layout.menuPosition context:context];
    CGContextAddRect(context,_layout.avatarPosition);
    CGContextMoveToPoint(context, 0.0f, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextSetLineWidth(context, 0.3f);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextStrokePath(context);
    
    [self _drawImage:[[UIImage imageNamed:@"comment"]
                      resizableImageWithCapInsets:UIEdgeInsetsMake(15, 55, 5, 5)]
                rect:_layout.commentBgPosition
             context:context];
}

- (void)_drawImage:(UIImage *)image rect:(CGRect)rect context:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextRestoreGState(context);
}

- (void)resetImageLayers {
    for (NSInteger i = 0; i < 9; i ++) {
        CALayer* imageLayer = [self.imageLayers objectAtIndex:i];
        imageLayer.frame = CGRectZero;
    }
}

- (void)setupImages {
    for (NSInteger i = 0; i < self.layout.imagePostionArray.count; i ++) {
        CALayer* imageLayer = [self.imageLayers objectAtIndex:i];
        NSString* img = [self.layout.statusModel.imgs objectAtIndex:i];
        [imageLayer sd_setImageWithURL:[NSURL URLWithString:img] placeholderImage:nil options:SDWebImageDelaySetContents];
    }
}

#pragma mark - Getter

- (LWAsyncDisplayView *)asyncDisplayView {
    if (!_asyncDisplayView) {
        _asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
        _asyncDisplayView.delegate = self;
    }
    return _asyncDisplayView;
}

- (NSMutableArray *)imageLayers {
    if (_imageLayers) {
        return _imageLayers;
    }
    _imageLayers = [[NSMutableArray alloc] initWithCapacity:9];
    for (NSInteger i = 0; i < 9; i ++) {
        CALayer* imageLayer = [CALayer layer];
        imageLayer.contentsScale = [UIScreen mainScreen].scale;
        imageLayer.contentsGravity = kCAGravityResizeAspectFill;
        imageLayer.masksToBounds = YES;
        [self.asyncDisplayView.layer addSublayer:imageLayer];
        [_imageLayers addObject:imageLayer];
    }
    return _imageLayers ;
}

- (CALayer *)avatarLayer {
    if (_avatarLayer) {
        return _avatarLayer;
    }
    _avatarLayer = [CALayer layer];
    _avatarLayer.contentsScale = [UIScreen mainScreen].scale;
    _avatarLayer.contentsGravity = kCAGravityResizeAspect;
    return _avatarLayer;
}

@end
