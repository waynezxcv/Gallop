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

#import "LWHTMLDisplayView.h"
#import "LWAsyncDisplayView.h"
#import "LWLayout.h"
#import "LWStorageBuilder.h"
#import "SDImageCache.h"
#import "LWHTMLLayout.h"




/*********** LWHTMLDisplayCellDelegate ****************/

@protocol LWHTMLDisplayCellDelegate <NSObject>

- (void)lwhtmlDisplayCellDidCilickedTextStorage:(LWTextStorage *)textStorage
                                       linkdata:(id)data
                                    atIndexPath:(NSIndexPath *)indexPath;

- (void)lwhtmlDisplayCellDidCilickedImageStorage:(LWImageStorage *)imageStorage
                                           touch:(UITouch *)touch
                                     atIndexPath:(NSIndexPath *)indexPath;

- (void)lwhtmlDisplayView:(LWStorage *)storage
     extraDisplayIncontext:(CGContextRef)context
                      size:(CGSize)size
         displayIdentifier:(NSString *)displayIdentifier;
@end


/*********** LWHTMLDisplayView ****************/

@interface LWHTMLDisplayView ()<UITableViewDelegate,UITableViewDataSource,LWHTMLDisplayCellDelegate>

@property (nonatomic,strong) LWStorageBuilder* storageBuilder;
@property (nonatomic,copy) NSArray* imageCallbacks;
@property (nonatomic,strong) NSMutableArray* items;
@property (nonatomic,strong) NSCache* cellCache;

@end

/************ LWHTMLCellLayout ***************/

@interface LWHTMLCellLayout : LWLayout

@property (nonatomic,assign) CGFloat cellHeight;

@end

/*********** LWHTMLDisplayCell ****************/

@interface LWHTMLDisplayCell : UITableViewCell<LWAsyncDisplayViewDelegate>

@property (nonatomic,weak) id <LWHTMLDisplayCellDelegate> delegate;
@property (nonatomic,strong) LWHTMLCellLayout* layout;
@property (nonatomic,strong) LWAsyncDisplayView* displayView;
@property (nonatomic,copy) LWAsyncDisplayViewAutoLayoutCallback autolayoutCallback;
@property (nonatomic,strong) NSIndexPath* indexPath;
@property (nonatomic,weak) UITableView* tableView;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
        inTableView:(UITableView *)tableView;

@end

@implementation LWHTMLDisplayView

- (id)init {
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.cellCache = [[NSCache alloc] init];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataSource = self;
    self.delegate = self;
}

- (void)dealloc {
    [self.cellCache removeAllObjects];
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LWHTMLDisplayCell* cell = [self _preparedCellForIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LWHTMLDisplayCell *cell = (LWHTMLDisplayCell *)[self _preparedCellForIndexPath:indexPath];
    return cell;
}

- (LWHTMLDisplayCell *)_preparedCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdenfifier = @"LWHTMLCellIdentifier";
    NSString* key = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    LWHTMLDisplayCell *cell = [self.cellCache objectForKey:key];
    if (!cell) {
        cell = [[LWHTMLDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenfifier inTableView:self];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.cellCache setObject:cell forKey:key];
    }
    [self _confirgueCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)_confirgueCell:(LWHTMLDisplayCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    LWHTMLCellLayout* layout = [self.items objectAtIndex:indexPath.row];
    cell.layout = layout;
    cell.delegate = self;
    cell.indexPath = indexPath;
    __weak typeof(self) weakSelf = self;
    cell.autolayoutCallback = ^(LWImageStorage* imageStorage , CGFloat deltaHeight) {
        [weakSelf _resizeCellWithImageStorage:imageStorage deltaHeight:deltaHeight atIndexPath:indexPath];
    };
}

- (void)_resizeCellWithImageStorage:(LWImageStorage *)imageStorage
                        deltaHeight:(CGFloat)deltaHeight
                        atIndexPath:(NSIndexPath *)indexPath {
    imageStorage.needResize = NO;
    LWHTMLCellLayout* layout = [self.items objectAtIndex:indexPath.row];
    layout.cellHeight = [layout suggestHeightWithBottomMargin:imageStorage.htmlLayoutEdgeInsets.bottom];
    [UIView setAnimationsEnabled:NO];
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - LWHTMLDisplayCellDelegate

- (void)lwhtmlDisplayCellDidCilickedTextStorage:(LWTextStorage *)textStorage linkdata:(id)data atIndexPath:(NSIndexPath *)indexPath {
    if ([self.displayDelegate respondsToSelector:@selector(lw_htmlDisplayView:didCilickedTextStorage:linkdata:)] &&
        [self.displayDelegate conformsToProtocol:@protocol(LWHTMLDisplayViewDelegate)]) {
        [self.displayDelegate lw_htmlDisplayView:self didCilickedTextStorage:textStorage linkdata:data];
    }
}

- (void)lwhtmlDisplayCellDidCilickedImageStorage:(LWImageStorage *)imageStorage touch:(UITouch *)touch atIndexPath:(NSIndexPath *)indexPath {
    if ([self.displayDelegate respondsToSelector:@selector(lw_htmlDisplayView:didSelectedImageStorage:totalImages:superView:inSuperViewPosition:index:)]) {
        if ([self.imageCallbacks containsObject:imageStorage]) {
            NSInteger index = [self.imageCallbacks indexOfObject:imageStorage];
            LWHTMLDisplayCell* cell = [self cellForRowAtIndexPath:indexPath];
            [self.displayDelegate lw_htmlDisplayView:self
                             didSelectedImageStorage:imageStorage
                                         totalImages:self.imageCallbacks
                                           superView:cell.displayView
                                 inSuperViewPosition:imageStorage.frame
                                               index:index];
        }
    }
}

- (void)lwhtmlDisplayView:(LWStorage *)storage
    extraDisplayIncontext:(CGContextRef)context
                     size:(CGSize)size
        displayIdentifier:(NSString *)displayIdentifier {
    
    if ([self.displayDelegate respondsToSelector:@selector(lw_htmlDisplayView:extraDisplayIncontext:size:displayIdentifier:)] &&
        [self.displayDelegate conformsToProtocol:@protocol(LWHTMLDisplayViewDelegate)]) {
        
        [self.displayDelegate lw_htmlDisplayView:self
                           extraDisplayIncontext:context
                                            size:size
                               displayIdentifier:displayIdentifier];
    }
}

#pragma mark - Getter & Setter

- (void)setData:(NSData *)data {
    if (_data != data) {
        _data = data;
    }
    self.storageBuilder = [[LWStorageBuilder alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}

- (void)setLayout:(LWHTMLLayout *)layout {
    if (_layout != layout) {
        _layout = layout;
    }
    [self.items removeAllObjects];
    for (id object in self.layout.allItems) {
        LWHTMLCellLayout* cellLayout = [[LWHTMLCellLayout alloc] init];
        CGFloat bottomMarigin = 0.0f;
        if ([object isKindOfClass:[LWStorage class]]) {
            bottomMarigin = [(LWStorage *)object htmlLayoutEdgeInsets].bottom;
            [cellLayout addStorage:object];
        }
        else if ([object isKindOfClass:[NSArray class]]) {
            NSArray* arr = (NSArray *)object;
            for (LWStorage* storage in arr) {
                bottomMarigin =  storage.htmlLayoutEdgeInsets.bottom >= bottomMarigin ?
                storage.htmlLayoutEdgeInsets.bottom : bottomMarigin;
                [cellLayout addStorage:storage];
            }
        }
        cellLayout.cellHeight = [cellLayout suggestHeightWithBottomMargin:bottomMarigin];
        [self.items addObject:cellLayout];
    }
    [self reloadData];
}


- (NSArray *)imageCallbacks {
    return self.storageBuilder.imageCallbacks;
}

- (NSMutableArray *)items {
    if (_items) {
        return _items;
    }
    _items = [[NSMutableArray alloc] init];
    return _items;
}

@end

#pragma mark - Private

@implementation LWHTMLDisplayCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
        inTableView:(UITableView *)tableView {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tableView = tableView;
        self.backgroundColor = [UIColor whiteColor];
        self.displayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
        self.displayView.delegate = self;
        [self.contentView addSubview:self.displayView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.displayView.frame = self.bounds;
}

- (void)setLayout:(LWHTMLCellLayout *)layout {
    if (_layout != layout) {
        _layout = layout;
    }
    self.displayView.layout = self.layout;
    self.frame = CGRectMake(0, 0, self.tableView.bounds.size.width,self.layout.cellHeight);
}

- (void)setAutolayoutCallback:(LWAsyncDisplayViewAutoLayoutCallback)autolayoutCallback {
    if (_autolayoutCallback != autolayoutCallback) {
        _autolayoutCallback = [autolayoutCallback copy];
    }
    if (self.autolayoutCallback) {
        self.displayView.auotoLayoutCallback = self.autolayoutCallback;
    }
}

#pragma mark - LWAsyncDisplayViewDelegate

- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedTextStorage:(LWTextStorage *)textStorage linkdata:(id)data {
    if ([self.delegate respondsToSelector:@selector(lwhtmlDisplayCellDidCilickedImageStorage:touch:atIndexPath:)] &&
        [self.delegate conformsToProtocol:@protocol(LWHTMLDisplayCellDelegate)]) {
        [self.delegate lwhtmlDisplayCellDidCilickedTextStorage:textStorage linkdata:data atIndexPath:self.indexPath];
    }
}

- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedImageStorage:(LWImageStorage *)imageStorage touch:(UITouch *)touch {
    if ([self.delegate respondsToSelector:@selector(lwhtmlDisplayCellDidCilickedImageStorage:touch:atIndexPath:)] &&
        [self.delegate conformsToProtocol:@protocol(LWHTMLDisplayCellDelegate)]) {
        [self.delegate lwhtmlDisplayCellDidCilickedImageStorage:imageStorage touch:touch atIndexPath:self.indexPath];
    }
}

- (void)extraAsyncDisplayIncontext:(CGContextRef)context size:(CGSize)size isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelled {
    if (self.layout.totalStorages.count) {
        LWStorage* storage = self.layout.totalStorages.firstObject;
        if (!storage.extraDisplayIdentifier) {
            return;
        }
        if ([self.delegate respondsToSelector:@selector(lwhtmlDisplayView:extraDisplayIncontext:size:displayIdentifier:)] && [self.delegate conformsToProtocol:@protocol(LWHTMLDisplayCellDelegate)]) {
            [self.delegate lwhtmlDisplayView:storage
                       extraDisplayIncontext:context
                                        size:size
                           displayIdentifier:storage.extraDisplayIdentifier];
        }
    }
}



@end

@implementation LWHTMLCellLayout

@end



