




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/









#import "TableViewCell.h"
#import "GallopUtils.h"
#import "LWImageStorage.h"
#import "Menu.h"
#import "LWAlertView.h"


@interface TableViewCell ()<LWAsyncDisplayViewDelegate>

@property (nonatomic,strong) LWAsyncDisplayView* asyncDisplayView;
@property (nonatomic,strong) UIButton* menuButton;
@property (nonatomic,strong) Menu* menu;
@property (nonatomic,strong) UIView* line;

@end

@implementation TableViewCell

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.asyncDisplayView];
        [self.contentView addSubview:self.menuButton];
        [self.contentView addSubview:self.menu];
        [self.contentView addSubview:self.line];
    }
    return self;
}


#pragma mark - Actions

/***  点击图片  ***/
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView
   didCilickedImageStorage:(LWImageStorage *)imageStorage
                     touch:(UITouch *)touch{
    NSLog(@"tag:%ld",imageStorage.tag);//这里可以通过判断Tag来执行相应的回调。
    CGPoint point = [touch locationInView:self];
    for (NSInteger i = 0; i < self.cellLayout.imagePostionArray.count; i ++) {
        CGRect imagePosition = CGRectFromString(self.cellLayout.imagePostionArray[i]);
        if (CGRectContainsPoint(imagePosition, point)) {
            if ([self.delegate respondsToSelector:@selector(tableViewCell:didClickedImageWithCellLayout:atIndex:)] &&
                [self.delegate conformsToProtocol:@protocol(TableViewCellDelegate)]) {
                [self.delegate tableViewCell:self didClickedImageWithCellLayout:self.cellLayout atIndex:i];
            }
        }
    }
}

/***  点击文本链接 ***/
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedTextStorage:(LWTextStorage *)textStorage linkdata:(id)data {
    if ([data isKindOfClass:[NSString class]]) {
        if ([data isEqualToString:@"close"]) {
            [self.delegate tableViewCellDidClickedCloseAtIndexPath:self.indexPath];
        }
        else if ([data isEqualToString:@"open"]) {
            [self.delegate tableViewCellDidClickedOpenAtIndexPath:self.indexPath];
        }
        else {
            [LWAlertView shoWithMessage:data];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(tableViewCell:didClickedLinkWithData:)] &&
            [self.delegate conformsToProtocol:@protocol(TableViewCellDelegate)]) {
            [self.delegate tableViewCell:self didClickedLinkWithData:data];
        }
    }
}

/***  点击菜单按钮  ***/
- (void)didClickedMenuButton {
    [self.menu clickedMenu];
}

/***  点击评论 ***/
- (void)didClickedCommentButton {
    if ([self.delegate respondsToSelector:@selector(tableViewCell:didClickedCommentWithCellLayout:atIndexPath:)]) {
        [self.delegate tableViewCell:self didClickedCommentWithCellLayout:self.cellLayout atIndexPath:self.indexPath];
        [self.menu menuHide];
    }
}

//** 点赞 **//
- (void)didclickedLikeButton:(LikeButton *)likeButton {
    __weak typeof(self) weakSelf = self;
    [likeButton likeButtonAnimationCompletion:^(BOOL isSelectd) {
        [weakSelf.menu menuHide];
        if ([weakSelf.delegate respondsToSelector:@selector(tableViewCell:didClickedLikeButtonWithIsLike:atIndexPath:)]) {
            [weakSelf.delegate tableViewCell:weakSelf didClickedLikeButtonWithIsLike:!weakSelf.cellLayout.statusModel.isLike atIndexPath:weakSelf.indexPath];
        }
    }];
}

#pragma mark - Draw and setup

- (void)setCellLayout:(CellLayout *)cellLayout {
    if (_cellLayout == cellLayout) {
        return;
    }
    _cellLayout = cellLayout;
    self.asyncDisplayView.layout = self.cellLayout;
    self.menu.statusModel = self.cellLayout.statusModel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.asyncDisplayView.frame = CGRectMake(0,0,SCREEN_WIDTH,self.cellLayout.cellHeight);
    self.menuButton.frame = self.cellLayout.menuPosition;
    self.menu.frame = CGRectMake(self.cellLayout.menuPosition.origin.x - 5.0f,
                                 self.cellLayout.menuPosition.origin.y - 9.0f + 14.5f,
                                 0,
                                 34);
    self.line.frame = self.cellLayout.lineRect;
}

- (void)extraAsyncDisplayIncontext:(CGContextRef)context size:(CGSize)size isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelled {
    if (!isCancelled()) {
        //绘制分割线
        CGContextMoveToPoint(context, 0.0f, self.bounds.size.height);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
        CGContextSetLineWidth(context, 0.2f);
        CGContextSetStrokeColorWithColor(context,RGB(220.0f, 220.0f, 220.0f, 1).CGColor);
        CGContextStrokePath(context);

        if ([self.cellLayout.statusModel.type isEqualToString:@"website"]) {
            CGContextAddRect(context, self.cellLayout.websiteRect);
            CGContextSetFillColorWithColor(context, RGB(240, 240, 240, 1).CGColor);
            CGContextFillPath(context);
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

- (UIButton *)menuButton {
    if (_menuButton) {
        return _menuButton;
    }
    _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_menuButton setImage:[UIImage imageNamed:@"[menu]"] forState:UIControlStateNormal];
    _menuButton.imageEdgeInsets = UIEdgeInsetsMake(14.5f, 12.0f, 14.5f, 12.0f);
    [_menuButton addTarget:self action:@selector(didClickedMenuButton) forControlEvents:UIControlEventTouchUpInside];
    return _menuButton;
}

- (Menu *)menu {
    if (_menu) {
        return _menu;
    }
    _menu = [[Menu alloc] initWithFrame:CGRectZero];
    _menu.backgroundColor = [UIColor whiteColor];
    _menu.opaque = YES;
    [_menu.commentButton addTarget:self action:@selector(didClickedCommentButton)
                  forControlEvents:UIControlEventTouchUpInside];
    [_menu.likeButton addTarget:self action:@selector(didclickedLikeButton:)
               forControlEvents:UIControlEventTouchUpInside];
    return _menu;
}

- (UIView *)line {
    if (_line) {
        return _line;
    }
    _line = [[UIView alloc] initWithFrame:CGRectZero];
    _line.backgroundColor = RGB(220.0f, 220.0f, 220.0f, 1);
    return _line;
}

@end
