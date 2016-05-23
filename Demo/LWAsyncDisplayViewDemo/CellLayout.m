




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/




#import "CellLayout.h"
#import "LWTextParser.h"
#import "CommentModel.h"
#import "LWDefine.h"


@implementation CellLayout

- (id)initWithStatusModel:(StatusModel *)statusModel
                    index:(NSInteger)index
            dateFormatter:(NSDateFormatter *)dateFormatter {
    self = [super init];
    if (self) {
        /****************************生成Storage 相当于模型*************************************/
        /*********LWAsyncDisplayView用将所有文本跟图片的模型都抽象成LWStorage，方便你能预先将所有的需要计算的布局内容直接缓存起来***/
        /*******而不是在渲染的时候才进行计算*******************************************/
        //头像模型 avatarImageStorage
        LWImageStorage* avatarStorage = [[LWImageStorage alloc] init];
        avatarStorage.contents = statusModel.avatar;
        avatarStorage.cornerRadius = 20.0f;
        avatarStorage.cornerBackgroundColor = [UIColor whiteColor];
        avatarStorage.fadeShow = YES;
        avatarStorage.clipsToBounds = NO;
        avatarStorage.frame = CGRectMake(10, 20, 40, 40);
        
        //名字模型 nameTextStorage
        LWTextStorage* nameTextStorage = [[LWTextStorage alloc] init];
        nameTextStorage.text = statusModel.name;
        nameTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
        nameTextStorage.textAlignment = NSTextAlignmentLeft;
        nameTextStorage.frame = CGRectMake(60.0f, 20.0f, SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
        [nameTextStorage lw_addLinkWithData:[NSString stringWithFormat:@"%@",statusModel.name]
                                      range:NSMakeRange(0,statusModel.name.length)
                                  linkColor:RGB(113, 129, 161, 1)
                             highLightColor:RGB(0, 0, 0, 0.15)];
        
        //正文内容模型 contentTextStorage
        LWTextStorage* contentTextStorage = [[LWTextStorage alloc] init];
        contentTextStorage.text = statusModel.content;
        contentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
        contentTextStorage.textColor = RGB(40, 40, 40, 1);
        contentTextStorage.frame = CGRectMake(60.0f, nameTextStorage.bottom + 10.0f, SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
        [LWTextParser parseEmojiWithTextStorage:contentTextStorage];
        [LWTextParser parseTopicWithLWTextStorage:contentTextStorage
                                        linkColor:RGB(113, 129, 161, 1)
                                   highlightColor:RGB(0, 0, 0, 0.15)];
        
        //发布的图片模型 imgsStorage
        NSInteger imageCount = [statusModel.imgs count];
        NSMutableArray* imageStorageArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
        NSMutableArray* imagePositionArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
        NSInteger row = 0;
        NSInteger column = 0;
        for (NSInteger i = 0; i < imageCount; i ++) {
            CGRect imageRect = CGRectMake(60.0f + (column * 85.0f),
                                          60.0f + contentTextStorage.height + (row * 85.0f),
                                          80.0f,
                                          80.0f);
            NSString* imagePositionString = NSStringFromCGRect(imageRect);
            [imagePositionArray addObject:imagePositionString];
            LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
            imageStorage.frame = imageRect;
            NSString* URLString = [statusModel.imgs objectAtIndex:i];
            imageStorage.contents = [NSURL URLWithString:URLString];
            imageStorage.fadeShow = YES;
            imageStorage.clipsToBounds = YES;
            [imageStorageArray addObject:imageStorage];
            
            column = column + 1;
            if (column > 2) {
                column = 0;
                row = row + 1;
            }
        }
        //获取最后一张图片的模型
        LWImageStorage* lastImageStorage = (LWImageStorage *)[imageStorageArray lastObject];
        //生成时间的模型 dateTextStorage
        LWTextStorage* dateTextStorage = [[LWTextStorage alloc] init];
        dateTextStorage.text = [dateFormatter stringFromDate:statusModel.date];
        dateTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:13.0f];
        dateTextStorage.textColor = [UIColor grayColor];
        
        //生成菜单图片的模型 dateTextStorage
        LWImageStorage* menuStorage = [[LWImageStorage alloc] init];
        menuStorage.contents = [UIImage imageNamed:@"[menu]"];
        CGRect menuPosition;
        if (lastImageStorage) {
            menuPosition = CGRectMake(SCREEN_WIDTH - 40.0f,10.0f + lastImageStorage.bottom,20.0f,15.0f);
            dateTextStorage.frame = CGRectMake(60.0f, lastImageStorage.bottom + 10.0f, SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
            
        } else {
            menuPosition = CGRectMake(SCREEN_WIDTH - 40.0f,10.0f + contentTextStorage.bottom,20.0f,15.0f);
            dateTextStorage.frame = CGRectMake(60.0f, contentTextStorage.bottom + 10.0f, SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
        }
        menuStorage.frame = menuPosition;
        //生成评论背景Storage
        LWImageStorage* commentBgStorage = [[LWImageStorage alloc] init];
        NSArray* commentTextStorages = @[];
        CGRect commentBgPosition = CGRectZero;
        CGRect rect = CGRectMake(60.0f,dateTextStorage.bottom + 5.0f, SCREEN_WIDTH - 80, 20);
        CGFloat offsetY = 0.0f;
        if (statusModel.commentList.count != 0 && statusModel.commentList != nil) {
            NSMutableArray* tmp = [[NSMutableArray alloc] initWithCapacity:statusModel.commentList.count];
            for (NSDictionary* commentDict in statusModel.commentList) {
                NSString* to = commentDict[@"to"];
                if (to.length != 0) {
                    NSString* commentString = [NSString stringWithFormat:@"%@回复%@:%@",commentDict[@"from"],commentDict[@"to"],commentDict[@"content"]];
                    LWTextStorage* commentTextStorage = [[LWTextStorage alloc] init];
                    commentTextStorage.text = commentString;
                    commentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                    commentTextStorage.textAlignment = NSTextAlignmentLeft;
                    commentTextStorage.linespacing = 2.0f;
                    commentTextStorage.textColor = RGB(40, 40, 40, 1);
                    commentTextStorage.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY,SCREEN_WIDTH - 95.0f, CGFLOAT_MAX);
                    
                    CommentModel* commentModel_1 = [[CommentModel alloc] init];
                    commentModel_1.to = commentDict[@"from"];
                    commentModel_1.index = index;
                    [commentTextStorage lw_addLinkWithData:commentModel_1
                                                     range:NSMakeRange(0,[(NSString *)commentDict[@"from"] length])
                                                 linkColor:RGB(113, 129, 161, 1)
                                            highLightColor:RGB(0, 0, 0, 0.15)];
                    
                    CommentModel* commentModel_2 = [[CommentModel alloc] init];
                    commentModel_2.to = [NSString stringWithFormat:@"%@",commentDict[@"to"]];
                    commentModel_2.index = index;
                    
                    [commentTextStorage lw_addLinkWithData:commentModel_2
                                                     range:NSMakeRange([(NSString *)commentDict[@"from"] length] + 2,[(NSString *)commentDict[@"to"] length])
                                                 linkColor:RGB(113, 129, 161, 1)
                                            highLightColor:RGB(0, 0, 0, 0.15)];
                    
                    [LWTextParser parseTopicWithLWTextStorage:commentTextStorage
                                                    linkColor:RGB(113, 129, 161, 1)
                                               highlightColor:RGB(0, 0, 0, 0.15)];
                    [LWTextParser parseEmojiWithTextStorage:commentTextStorage];
                    [tmp addObject:commentTextStorage];
                    offsetY += commentTextStorage.height;
                } else {
                    NSString* commentString = [NSString stringWithFormat:@"%@:%@",commentDict[@"from"],commentDict[@"content"]];
                    LWTextStorage* commentTextStorage = [[LWTextStorage alloc] init];
                    commentTextStorage.text = commentString;
                    commentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                    commentTextStorage.textAlignment = NSTextAlignmentLeft;
                    commentTextStorage.linespacing = 2.0f;
                    commentTextStorage.textColor = RGB(40, 40, 40, 1);
                    commentTextStorage.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY,SCREEN_WIDTH - 95.0f, CGFLOAT_MAX);
                    
                    CommentModel* commentModel = [[CommentModel alloc] init];
                    commentModel.to = commentDict[@"from"];
                    commentModel.index = index;
                    [commentTextStorage lw_addLinkWithData:commentModel
                                                     range:NSMakeRange(0,[(NSString *)commentDict[@"from"] length])
                                                 linkColor:RGB(113, 129, 161, 1)
                                            highLightColor:RGB(0, 0, 0, 0.15)];
                    
                    [LWTextParser parseTopicWithLWTextStorage:commentTextStorage
                                                    linkColor:RGB(113, 129, 161, 1)
                                               highlightColor:RGB(0, 0, 0, 0.15)];
                    [LWTextParser parseEmojiWithTextStorage:commentTextStorage];
                    [tmp addObject:commentTextStorage];
                    offsetY += commentTextStorage.height;
                }
            }
            //如果有评论，设置评论背景Storage
            commentTextStorages = tmp;
            commentBgPosition = CGRectMake(60.0f,dateTextStorage.bottom + 5.0f, SCREEN_WIDTH - 80, offsetY + 15.0f);
            commentBgStorage.frame = commentBgPosition;
            commentBgStorage.contents = [UIImage imageNamed:@"comment"];
            [commentBgStorage stretchableImageWithLeftCapWidth:40 topCapHeight:15];
        }
        /**************************将要在同一个LWAsyncDisplayView上显示的Storage要全部放入同一个LWLayout中***************************************/
        /**************************我们将尽量通过合并绘制的方式将所有在同一个View显示的内容全都异步绘制在同一个AsyncDisplayView上**************************/
        /**************************这样的做法能最大限度的节省系统的开销**************************/
        [self addStorage:nameTextStorage];
        [self addStorage:contentTextStorage];
        [self addStorage:dateTextStorage];
        [self addStorages:commentTextStorages];
        [self addStorage:avatarStorage];
        [self addStorage:menuStorage];
        [self addStorage:commentBgStorage];
        [self addStorages:imageStorageArray];
        //一些其他属性
        self.menuPosition = menuPosition;
        self.commentBgPosition = commentBgPosition;
        self.imagePostionArray = imagePositionArray;
        self.statusModel = statusModel;
        //如果是使用在UITableViewCell上面，可以通过以下方法快速的得到Cell的高度
        self.cellHeight = [self suggestHeightWithBottomMargin:15.0f];
        /********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
        /***************  https://github.com/waynezxcv/Gallop 持续更新完善，如果觉得有帮助，给个Star~[]***************************/
        /******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/
    }
    return self;
}

@end
