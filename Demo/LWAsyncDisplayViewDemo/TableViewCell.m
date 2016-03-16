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
#import "UIImageView+WebCache.h"


@interface TableViewCell ()<LWAsyncDisplayViewDelegate>

@property (nonatomic,strong) LWAsyncDisplayView* asyncDisplayView;
@property (nonatomic,strong) UIImageView* avatarImageView;
@property (nonatomic,strong) NSMutableArray* imageViews;
@property (nonatomic,assign,getter=isNeedLayoutImageViews) BOOL needLayoutImageViews;

@end

@implementation TableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.needLayoutImageViews = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.asyncDisplayView];
        [self.contentView addSubview:self.avatarImageView];

        for (NSInteger i = 0; i < 9;i ++) {
            UIImageView* imageView = [self.imageViews objectAtIndex:i];
            [self.contentView addSubview:imageView];
        }
    }
    return self;
}

- (void)setLayout:(CellLayout *)layout {
    if (_layout == layout || [_layout isEqual:layout]) {
        return;
    }
    _layout = layout;
    [self setupCell];
}

- (void)setupCell {
    self.avatarImageView.frame = self.layout.avatarPosition;
    self.asyncDisplayView.frame = CGRectMake(0,0,SCREEN_WIDTH,self.layout.cellHeight);
    [self.avatarImageView sd_setImageWithURL:self.layout.statusModel.avatar];
    self.asyncDisplayView.layouts = @[self.layout.nameTextLayout,
                                      self.layout.contentTextLayout,
                                      self.layout.dateTextLayout];
    [self resetImageView];
    LWRunLoopObserver* obeserver = [LWRunLoopObserver observerWithTarget:self
                                                                selector:@selector(setupImages)
                                                                  object:nil];
    [obeserver commit];
}

- (void)extraAsyncDisplayIncontext:(CGContextRef)context size:(CGSize)size {
    [self _drawImage:[UIImage imageNamed:@"menu"] rect:_layout.menuPosition context:context];
    CGContextAddRect(context,_layout.avatarPosition);
    CGContextMoveToPoint(context, 0.0f, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextSetLineWidth(context, 0.3f);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextStrokePath(context);
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

- (void)resetImageView {
    for (NSInteger i = 0; i < 9; i ++) {
        UIImageView* imageView = [self.imageViews objectAtIndex:i];
        imageView.frame = CGRectZero;
    }
}

- (void)setupImages {
    NSLog(@"setupImages");
    for (NSInteger i = 0; i < self.layout.imagePostionArray.count; i ++) {
        UIImageView* imageView = [self.imageViews objectAtIndex:i];
        imageView.frame = CGRectFromString([self.layout.imagePostionArray objectAtIndex:i]);
        NSString* img = [self.layout.statusModel.imgs objectAtIndex:i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:img]];
    }
}

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

#pragma mark - Getter

- (LWAsyncDisplayView *)asyncDisplayView {
    if (!_asyncDisplayView) {
        _asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
        _asyncDisplayView.delegate = self;
    }
    return _asyncDisplayView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatarImageView;
}

- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [[NSMutableArray alloc] initWithCapacity:9];
        for (NSInteger i = 0; i < 9; i ++) {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.backgroundColor = [UIColor grayColor];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(didClickedImageView:)]];
            [_imageViews addObject:imageView];
        }
    }
    return _imageViews;
}

@end
