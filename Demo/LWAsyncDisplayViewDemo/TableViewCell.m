




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/









#import "TableViewCell.h"
#import "LWDefine.h"
#import "LWImageStorage.h"
#import "Menu.h"


@interface TableViewCell ()<LWAsyncDisplayViewDelegate>

@property (nonatomic,strong) LWAsyncDisplayView* asyncDisplayView;
@property (nonatomic,strong) Menu* menu;

@end

@implementation TableViewCell


#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.asyncDisplayView];
        [self.contentView addSubview:self.menu];
        
    }
    return self;
}


#pragma mark - Actions

- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView
   didCilickedImageStorage:(LWImageStorage *)imageStorage
                     touch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self];
    for (NSInteger i = 0; i < self.cellLayout.imagePostionArray.count; i ++) {
        CGRect imagePosition = CGRectFromString(self.cellLayout.imagePostionArray[i]);
        //点击查看大图
        if (CGRectContainsPoint(imagePosition, point)) {
            if ([self.delegate respondsToSelector:@selector(tableViewCell:didClickedImageWithCellLayout:atIndex:)] &&
                [self.delegate conformsToProtocol:@protocol(TableViewCellDelegate)]) {
                [self.delegate tableViewCell:self didClickedImageWithCellLayout:self.cellLayout atIndex:i];
            }
        }
        
    }
    //点击菜单按钮
    if (CGRectContainsPoint(CGRectMake(self.cellLayout.menuPosition.origin.x - 10,
                                       self.cellLayout.menuPosition.origin.y - 10,
                                       self.cellLayout.menuPosition.size.width + 20,
                                       self.cellLayout.menuPosition.size.height + 20), point)) {
        [self.menu clickedMenu];
    }
}


/**
 *  点击链接回调
 *
 */
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedLinkWithfData:(id)data {
    if ([self.delegate respondsToSelector:@selector(tableViewCell:didClickedLinkWithData:)] &&
        [self.delegate conformsToProtocol:@protocol(TableViewCellDelegate)]) {
        [self.delegate tableViewCell:self didClickedLinkWithData:data];
    }
}


/**
 *  点击评论
 *
 */
- (void)didClickedCommentButton {
    if ([self.delegate respondsToSelector:@selector(tableViewCell:didClickedCommentWithCellLayout:atIndexPath:)]) {
        [self.delegate tableViewCell:self didClickedCommentWithCellLayout:self.cellLayout atIndexPath:self.indexPath];
        [self.menu menuHide];
    }
}


#pragma mark - Draw and setup

- (void)setCellLayout:(CellLayout *)cellLayout {
    if (_cellLayout == cellLayout) {
        return;
    }
    _cellLayout = cellLayout;
    self.asyncDisplayView.layout = cellLayout;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.asyncDisplayView.frame = CGRectMake(0,
                                             0,
                                             SCREEN_WIDTH,
                                             self.cellLayout.cellHeight);
    self.menu.frame = CGRectMake(self.cellLayout.menuPosition.origin.x - 5.0f,
                                 self.cellLayout.menuPosition.origin.y - 9.0f,
                                 0,
                                 34);
}

- (void)extraAsyncDisplayIncontext:(CGContextRef)context size:(CGSize)size {
    //绘制分割线
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

#pragma mark - Getter

- (LWAsyncDisplayView *)asyncDisplayView {
    if (!_asyncDisplayView) {
        _asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero maxImageStorageCount:10];
        _asyncDisplayView.delegate = self;
    }
    return _asyncDisplayView;
}

- (Menu *)menu {
    if (_menu) {
        return _menu;
    }
    _menu = [[Menu alloc] initWithFrame:CGRectZero];
    [_menu.commentButton addTarget:self action:@selector(didClickedCommentButton)
                  forControlEvents:UIControlEventTouchUpInside];
    return _menu;
}

@end
