




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/




#import <UIKit/UIKit.h>


typedef void(^likeActionBlock)(BOOL isSelectd);


@interface LikeButton : UIButton

- (void)likeButtonAnimationCompletion:(likeActionBlock)completion;

@end
