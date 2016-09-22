/*
 https://github.com/waynezxcv/Gallop
 
 Copyright (c) 2016 waynezxcv <liuweiself@126.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


#import "LWActionSheetView.h"
#import "UIImage+ImageEffects.h"
#import "LWActionSheetTableViewCell.h"
#import "LWImageBrowserDefine.h"


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
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                       SCREEN_HEIGHT  - cellHeight * self.titlesCount ,
                                                                       SCREEN_WIDTH,
                                                                       cellHeight * self.titlesCount)
                                                      style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tableView];
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.09f * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [cell show];
                       });
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(CGRectMake(0.0f,
                                       0.0f,
                                       SCREEN_WIDTH,
                                       SCREEN_HEIGHT - cellHeight * self.titlesCount ),
                            point)) {
        [self _hide];
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
        weakSelf.tableView.frame = CGRectMake(0.0f,
                                              SCREEN_HEIGHT,
                                              SCREEN_WIDTH,
                                              cellHeight * self.titlesCount);
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
