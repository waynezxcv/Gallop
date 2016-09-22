




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/




#import "LikeButton.h"

@implementation LikeButton

- (void)likeButtonAnimationCompletion:(likeActionBlock)completion {
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.imageView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.imageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                                                               animations:^{
                                                                   self.imageView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                                               } completion:^(BOOL finished) {
                                                                   completion(self.isSelected);
                                                               }];
                                          }];
                     }];
}


@end
