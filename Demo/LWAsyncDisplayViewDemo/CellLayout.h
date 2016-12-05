




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/








#import "LWLayout.h"
#import "StatusModel.h"


#define MESSAGE_TYPE_IMAGE @"image"
#define MESSAGE_TYPE_WEBSITE @"website"
#define MESSAGE_TYPE_VIDEO @"video"
#define AVATAR_IDENTIFIER @"avatar"
#define IMAGE_IDENTIFIER @"image"
#define WEBSITE_COVER_IDENTIFIER @"cover"


@interface CellLayout : LWLayout <NSCopying>

@property (nonatomic,strong) StatusModel* statusModel;
@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) CGRect lineRect;
@property (nonatomic,assign) CGRect menuPosition;
@property (nonatomic,assign) CGRect commentBgPosition;
@property (nonatomic,assign) CGRect avatarPosition;
@property (nonatomic,assign) CGRect websitePosition;
@property (nonatomic,copy) NSArray* imagePostions;

//文字过长时，折叠状态的布局模型
- (id)initWithStatusModel:(StatusModel *)stautsModel
                    index:(NSInteger)index
            dateFormatter:(NSDateFormatter *)dateFormatter;


//文字过长时，打开状态的布局模型
- (id)initContentOpendLayoutWithStatusModel:(StatusModel *)stautsModel
                                      index:(NSInteger)index
                              dateFormatter:(NSDateFormatter *)dateFormatter;





@end
