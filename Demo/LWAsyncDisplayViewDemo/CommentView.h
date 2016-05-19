




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/









#import <UIKit/UIKit.h>
#import "AutoFitSizeTextView.h"


typedef void(^PressSendBlock)(NSString * content);

@interface CommentView : UIView<AutoFitSizeTextViewDelegate>

@property (nonatomic,strong) AutoFitSizeTextView* textView;
@property (nonatomic,copy) NSString* placeHolder;
@property (nonatomic,copy) PressSendBlock sendBlock;


- (id)initWithFrame:(CGRect)frame sendBlock:(PressSendBlock)sendBlock;

@end
