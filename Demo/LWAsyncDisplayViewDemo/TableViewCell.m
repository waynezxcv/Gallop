




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

#pragma mark - LWAsyncDisplayViewDelegate

//额外的绘制
- (void)extraAsyncDisplayIncontext:(CGContextRef)context size:(CGSize)size isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelled {
    if (!isCancelled()) {
        CGContextMoveToPoint(context, 0.0f, self.bounds.size.height);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
        CGContextSetLineWidth(context, 0.2f);
        CGContextSetStrokeColorWithColor(context,RGB(220.0f, 220.0f, 220.0f, 1).CGColor);
        CGContextStrokePath(context);
        if ([self.cellLayout.statusModel.type isEqualToString:MESSAGE_TYPE_WEBSITE]) {
            CGContextAddRect(context, self.cellLayout.websitePosition);
            CGContextSetFillColorWithColor(context, RGB(240, 240, 240, 1).CGColor);
            CGContextFillPath(context);
        }
    }
}
//点击LWImageStorage
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView
   didCilickedImageStorage:(LWImageStorage *)imageStorage
                     touch:(UITouch *)touch{
    NSInteger tag = imageStorage.tag;
    //tag 0~8 是图片，9是头像
    switch (tag) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:{
            if (self.clickedImageCallback) {
                self.clickedImageCallback(self,tag);
            }
        }break;
        case 9: {
            if (self.clickedAvatarCallback) {
                self.clickedAvatarCallback(self);
            }
        }break;
    }
}

//点击LWTextStorage
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView
    didCilickedTextStorage:(LWTextStorage *)textStorage
                  linkdata:(id)data {
    //回复评论
    if ([data isKindOfClass:[CommentModel class]]) {
        if (self.clickedReCommentCallback) {
            self.clickedReCommentCallback(self,data);
        }
    }
    else if ([data isKindOfClass:[NSString class]]) {
        //折叠Cell
        if ([data isEqualToString:@"close"]) {
            if (self.clickedCloseCellCallback) {
                self.clickedCloseCellCallback(self);
            }
        }
        //展开Cell
        else if ([data isEqualToString:@"open"]) {
            if (self.clickedOpenCellCallback) {
                self.clickedOpenCellCallback(self);
            }
        }
        //其他
        else {
            [LWAlertView shoWithMessage:data];
        }
    }
}

#pragma mark - Actions
//点击菜单按钮
- (void)didClickedMenuButton {
    [self.menu clickedMenu];
}

//点击评论
- (void)didClickedCommentButton {
    if (self.clickedCommentButtonCallback) {
        self.clickedCommentButtonCallback(self);
        [self.menu menuHide];
    }
}

//点赞
- (void)didclickedLikeButton:(LikeButton *)likeButton {
    __weak typeof(self) weakSelf = self;
    [likeButton likeButtonAnimationCompletion:^(BOOL isSelectd) {
        __strong typeof(weakSelf) sself = weakSelf;
        [sself.menu menuHide];
        if (sself.clickedLikeButtonCallback) {
            sself.clickedLikeButtonCallback(sself,!sself.cellLayout.statusModel.isLike);
        }
    }];
}

#pragma mark -


- (void)layoutSubviews {
    [super layoutSubviews];
    self.asyncDisplayView.frame = CGRectMake(0,0,SCREEN_WIDTH,self.cellLayout.cellHeight);
    self.menuButton.frame = self.cellLayout.menuPosition;
    self.menu.frame = CGRectMake(self.cellLayout.menuPosition.origin.x - 5.0f,
                                 self.cellLayout.menuPosition.origin.y - 9.0f + 14.5f,0.0f,34.0f);
    self.line.frame = self.cellLayout.lineRect;
}

- (void)setCellLayout:(CellLayout *)cellLayout {
    if (_cellLayout != cellLayout) {
        _cellLayout = cellLayout;
        self.asyncDisplayView.layout = self.cellLayout;
        self.menu.statusModel = self.cellLayout.statusModel;
    }
}

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
    [_menuButton addTarget:self action:@selector(didClickedMenuButton)
          forControlEvents:UIControlEventTouchUpInside];
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
    _line.backgroundColor = RGB(220.0f, 220.0f, 220.0f, 1.0f);
    return _line;
}

@end
