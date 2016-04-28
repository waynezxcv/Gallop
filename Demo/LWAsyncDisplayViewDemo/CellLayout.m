




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/









#import "CellLayout.h"
#import "LWTextParser.h"
#import "LWStorage+Constraint.h"
#import "LWConstraintManager.h"
#import "CommentModel.h"
#import "LWDefine.h"


@implementation CellLayout

- (id)initWithContainer:(LWStorageContainer *)container
            statusModel:(StatusModel *)statusModel
                  index:(NSInteger)index
          dateFormatter:(NSDateFormatter *)dateFormatter {
    self = [super initWithContainer:container];
    if (self) {
        /****************************生成Storage 相当于模型*************************************/
        /*********LWAsyncDisplayView用将所有文本跟图片的模型都抽象成LWStorage，方便你能预先将所有的需要计算的布局内容直接缓存起来***/
        /*******而不是在渲染的时候才进行计算*******************************************/
        
        //头像模型 avatarImageStorage
        LWImageStorage* avatarStorage = [[LWImageStorage alloc] init];
        avatarStorage.type = LWImageStorageWebImage;
        avatarStorage.URL = statusModel.avatar;
        avatarStorage.cornerRadius = 20.0f;
        avatarStorage.cornerBackgroundColor = [UIColor whiteColor];
        avatarStorage.fadeShow = YES;
        avatarStorage.masksToBounds = NO;
        
        //名字模型 nameTextStorage
        LWTextStorage* nameTextStorage = [[LWTextStorage alloc] init];
        nameTextStorage.text = statusModel.name;
        nameTextStorage.font = [UIFont systemFontOfSize:15.0f];
        nameTextStorage.textAlignment = NSTextAlignmentLeft;
        nameTextStorage.linespace = 2.0f;
        nameTextStorage.textColor = RGB(40, 40, 40, 1);

        //正文内容模型 contentTextStorage
        LWTextStorage* contentTextStorage = [[LWTextStorage alloc] init];
        contentTextStorage.text = statusModel.content;
        contentTextStorage.font = [UIFont systemFontOfSize:15.0f];
        contentTextStorage.textColor = RGB(40, 40, 40, 1);
        contentTextStorage.linespace = 2.0f;
        
        /***********************************  设置约束 自动布局 *********************************************/
        [LWConstraintManager lw_makeConstraint:avatarStorage.constraint.leftMargin(10).topMargin(20).widthLength(40.0f).heightLength(40.0f)];
        [LWConstraintManager lw_makeConstraint:nameTextStorage.constraint.leftMarginToStorage(avatarStorage,10).topMargin(20).widthLength(SCREEN_WIDTH)];
        [LWConstraintManager lw_makeConstraint:contentTextStorage.constraint.leftMarginToStorage(avatarStorage,10).topMarginToStorage(nameTextStorage,10).rightMargin(20)];
        
        /***********************************  添加点击Link 解析表情*********************************************/
        [nameTextStorage addLinkWithData:[NSString stringWithFormat:@"%@",statusModel.name]
                                 inRange:NSMakeRange(0,statusModel.name.length)
                               linkColor:RGB(113, 129, 161, 1)
                          highLightColor:RGB(0, 0, 0, 0.15)
                          UnderLineStyle:NSUnderlineStyleNone];
        
        [LWTextParser parseEmojiWithTextStorage:contentTextStorage];
        [LWTextParser parseTopicWithLWTextStorage:contentTextStorage
                                        linkColor:RGB(113, 129, 161, 1)
                                   highlightColor:RGB(0, 0, 0, 0.15)
                                   underlineStyle:NSUnderlineStyleNone];

        //发布的图片模型 imgsStorage
        NSInteger imageCount = [statusModel.imgs count];
        NSMutableArray* imageStorageArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
        NSMutableArray* imagePositionArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
        NSInteger row = 0;
        NSInteger column = 0;
        for (NSInteger i = 0; i < statusModel.imgs.count; i ++) {
            CGRect imageRect = CGRectMake(60.0f + (column * 85.0f),
                                          60.0f + contentTextStorage.height + (row * 85.0f),
                                          80.0f,
                                          80.0f);
            NSString* imagePositionString = NSStringFromCGRect(imageRect);
            [imagePositionArray addObject:imagePositionString];
            /***************** 也可以不使用设置约束的方式来布局，而是直接设置frame属性的方式来布局*************************************/
            LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
            imageStorage.frame = imageRect;
            /***********************************/
            NSString* URLString = [statusModel.imgs objectAtIndex:i];
            imageStorage.URL = [NSURL URLWithString:URLString];
            imageStorage.type = LWImageStorageWebImage;
            imageStorage.fadeShow = YES;
            imageStorage.masksToBounds = YES;
            imageStorage.contentMode = kCAGravityResizeAspectFill;
            
            [imageStorageArray addObject:imageStorage];
            
            column = column + 1;
            if (column > 2) {
                column = 0;
                row = row + 1;
            }
        }
        CGFloat imagesHeight = 0.0f;
        row < 3 ? (imagesHeight = (row + 1) * 85.0f):(imagesHeight = row  * 85.0f);
        
        //获取最后一张图片的模型
        LWImageStorage* lastImageStorage = (LWImageStorage *)[imageStorageArray lastObject];
        //生成时间的模型 dateTextStorage
        LWTextStorage* dateTextStorage = [[LWTextStorage alloc] init];
        dateTextStorage.text = [dateFormatter stringFromDate:statusModel.date];
        dateTextStorage.font = [UIFont systemFontOfSize:13.0f];
        dateTextStorage.textColor = [UIColor grayColor];

        /***********************************  设置约束 自动布局 *********************************************/
        [LWConstraintManager lw_makeConstraint:dateTextStorage.constraint.leftEquelToStorage(contentTextStorage).topMarginToStorage(lastImageStorage,10)];
        
        //生成菜单图片的模型 dateTextStorage
        CGRect menuPosition = CGRectMake(SCREEN_WIDTH - 40.0f,20.0f + imagesHeight + contentTextStorage.bottom,20.0f,15.0f);
        LWImageStorage* menuStorage = [[LWImageStorage alloc] init];
        menuStorage.type = LWImageStorageLocalImage;
        menuStorage.frame = menuPosition;
        menuStorage.image = [UIImage imageNamed:@"[menu]"];
        
        //comment
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
                    commentTextStorage.font = [UIFont systemFontOfSize:14.0f];
                    commentTextStorage.textAlignment = NSTextAlignmentLeft;
                    commentTextStorage.linespace = 2.0f;
                    commentTextStorage.textColor = RGB(40, 40, 40, 1);
                    commentTextStorage.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY,SCREEN_WIDTH - 95.0f, 20.0f);
                    
                    CommentModel* commentModel_1 = [[CommentModel alloc] init];
                    commentModel_1.to = commentDict[@"from"];
                    commentModel_1.index = index;
                    [commentTextStorage addLinkWithData:commentModel_1
                                         highLightColor:RGB(0, 0, 0, 0.15)];
                    
                    
                    CommentModel* commentModel_2 = [[CommentModel alloc] init];
                    commentModel_2.to = commentDict[@"from"];
                    commentModel_2.index = index;
                    [commentTextStorage addLinkWithData:commentModel_2
                                                inRange:NSMakeRange(0,[(NSString *)commentDict[@"from"] length])
                                              linkColor:RGB(113, 129, 161, 1)
                                         highLightColor:RGB(0, 0, 0, 0.15)
                                         UnderLineStyle:NSUnderlineStyleNone];
                    
                    
                    CommentModel* commentModel_3 = [[CommentModel alloc] init];
                    commentModel_3.to = [NSString stringWithFormat:@"%@",commentDict[@"to"]];
                    commentModel_3.index = index;
                    [commentTextStorage addLinkWithData:commentModel_3
                                                inRange:NSMakeRange([(NSString *)commentDict[@"from"] length] + 2,[(NSString *)commentDict[@"to"] length])
                                              linkColor:RGB(113, 129, 161, 1)
                                         highLightColor:RGB(0, 0, 0, 0.15)
                                         UnderLineStyle:NSUnderlineStyleNone];
                    
                    
                    
                    [LWTextParser parseEmojiWithTextStorage:commentTextStorage];
                    [LWTextParser parseTopicWithLWTextStorage:commentTextStorage
                                                    linkColor:RGB(113, 129, 161, 1)
                                               highlightColor:RGB(0, 0, 0, 0.15)
                                               underlineStyle:NSUnderlineStyleNone];
                    
                    [tmp addObject:commentTextStorage];
                    offsetY += commentTextStorage.height;
                } else {
                    NSString* commentString = [NSString stringWithFormat:@"%@:%@",commentDict[@"from"],commentDict[@"content"]];
                    LWTextStorage* commentTextStorage = [[LWTextStorage alloc] init];
                    commentTextStorage.text = commentString;
                    commentTextStorage.font = [UIFont systemFontOfSize:14.0f];
                    commentTextStorage.textAlignment = NSTextAlignmentLeft;
                    commentTextStorage.linespace = 2.0f;
                    commentTextStorage.textColor = RGB(40, 40, 40, 1);
                    commentTextStorage.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY,SCREEN_WIDTH - 95.0f, 20.0f);
                    
                    CommentModel* commentModel_1 = [[CommentModel alloc] init];
                    commentModel_1.to = commentDict[@"from"];
                    commentModel_1.index = index;
                    [commentTextStorage addLinkWithData:commentModel_1
                                         highLightColor:RGB(0, 0, 0, 0.15)];
                    
                    CommentModel* commentModel_2 = [[CommentModel alloc] init];
                    commentModel_2.to = commentDict[@"from"];
                    commentModel_2.index = index;
                    [commentTextStorage addLinkWithData:commentModel_2
                                                inRange:NSMakeRange(0,[(NSString *)commentDict[@"from"] length])
                                              linkColor:RGB(113, 129, 161, 1)
                                         highLightColor:RGB(0, 0, 0, 0.15)
                                         UnderLineStyle:NSUnderlineStyleNone];
                    
                    [LWTextParser parseEmojiWithTextStorage:commentTextStorage];
                    [LWTextParser parseTopicWithLWTextStorage:commentTextStorage
                                                    linkColor:RGB(113, 129, 161, 1)
                                               highlightColor:RGB(0, 0, 0, 0.15)
                                               underlineStyle:NSUnderlineStyleNone];
                    
                    [tmp addObject:commentTextStorage];
                    offsetY += commentTextStorage.height;
                }
            }
            //如果有评论，设置评论背景Storage
            commentTextStorages = tmp;
            commentBgPosition = CGRectMake(60.0f,dateTextStorage.bottom + 5.0f, SCREEN_WIDTH - 80, offsetY + 15.0f);
            commentBgStorage.type = LWImageStorageLocalImage;
            commentBgStorage.frame = commentBgPosition;
            commentBgStorage.image = [UIImage imageNamed:@"comment"];
            [commentBgStorage stretchableImageWithLeftCapWidth:40 topCapHeight:15];
        }
        
        /**************************将要在同一个LWAsyncDisplayView上显示的Storage要全部放入同一个LWLayout中***************************************/
        /**************************我们将尽量通过合并绘制的方式将所有在同一个View显示的内容全都异步绘制在同一个AsyncDisplayView上**************************/
        /**************************这样的做法能最大限度的节省系统的开销**************************/        
        [container addStorage:nameTextStorage];
        [container addStorage:contentTextStorage];
        [container addStorage:dateTextStorage];
        [container addStorages:commentTextStorages];
        [container addStorage:avatarStorage];
        [container addStorage:menuStorage];
        [container addStorage:commentBgStorage];
        [container addStorages:imageStorageArray];
        
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
