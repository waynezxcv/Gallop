//
//  DiscoverTableViewCell.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "DiscoverTableViewCell.h"
#import "CALayer+LWWebImage.h"

@interface DiscoverTableViewCell ()

@property (nonatomic,strong) BackgroundImageView* backgroundImageView;
@property (nonatomic,strong) UIImageView* avatarImageView;
@property (nonatomic,strong) MenuView* menuView;
@property (nonatomic,assign,getter=isMenuShow) BOOL menuShow;

@end

@implementation DiscoverTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.menuShow = NO;
        
        self.backgroundColor = [UIColor whiteColor];
        self.backgroundImageView = [[BackgroundImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.backgroundImageView];
        
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.avatarImageView];
        
        self.menuView = [[MenuView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.menuView];
    }
    return self;
}

- (void)setLayout:(DiscoverLayout *)layout {
    if (_layout != layout) {
        _layout = layout;
    }
    [self drawContent];
}


- (void)drawContent {
    self.backgroundImageView.frame = CGRectMake(0, 0, ScreenWidth, self.layout.cellHeight);
    [self.backgroundImageView drawContentWithLayout:self.layout];
    
    self.avatarImageView.frame = self.layout.avatarPosition;
    [self.avatarImageView.layer lw_setImageWithURL:self.layout.statusModel.user.avatarURL
                                           options:0
                                          progress:nil
                                         transform:nil
                                   completionBlock:^{}];
    
    self.menuView.frame = CGRectMake(self.layout.menuPosition.origin.x, self.layout.menuPosition.origin.y - 12.5f, 0.0f, 40.0f);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.layout.menuPosition, point)) {
        if (!self.isMenuShow) {
            [self menuViewShow];
        }
        else {
            [self menuViewHide];
        }
    }
}

- (void)menuViewShow {
    [UIView animateWithDuration:0.2f animations:^{
        self.menuView.frame = CGRectMake(self.layout.menuPosition.origin.x - 170.0f, self.layout.menuPosition.origin.y - 12.5f, 165.0f, 40.0f);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)menuViewHide {
    [UIView animateWithDuration:0.2f animations:^{
        self.menuView.frame = CGRectMake(self.layout.menuPosition.origin.x, self.layout.menuPosition.origin.y - 12.5f, 0.0f, 40.0f);
    } completion:^(BOOL finished) {
        
    }];
}

@end



@implementation BackgroundImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}


- (void)drawContentWithLayout:(DiscoverLayout *)layout {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, ![self.backgroundColor isEqual:[UIColor clearColor]], 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == NULL) {
            return;
        }
        if (![self.backgroundColor isEqual:[UIColor clearColor]]) {
            [self.backgroundColor set];
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height));
        }
        if (isDebug == 1) {
            CGContextAddRect(context, layout.nameTextLayout.boundsRect);
            CGContextAddRect(context, layout.textTextLayout.boundsRect);
            CGContextAddRect(context, layout.timeStampTextLayout.boundsRect);
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextFillPath(context);
        }
        
        [layout.nameTextLayout drawTextLayoutIncontext:context];
        [layout.textTextLayout drawTextLayoutIncontext:context];
        [layout.timeStampTextLayout drawTextLayoutIncontext:context];
        [self drawImage:[UIImage imageNamed:@"menu"] rect:layout.menuPosition context:context];
        
        CGContextAddRect(context,layout.avatarPosition);
        CGContextMoveToPoint(context, 0.0f, self.bounds.size.height);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
        CGContextSetLineWidth(context, 0.3f);
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextStrokePath(context);
        
        UIImage* screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            self.layer.contents = (__bridge id)screenshotImage.CGImage;
        });
    });
}


- (void)drawImage:(UIImage *)image rect:(CGRect)rect context:(CGContextRef)context {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextRestoreGState(context);
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
