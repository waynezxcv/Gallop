




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/










#import <UIKit/UIKit.h>


@class AutoFitSizeTextView;

@protocol AutoFitSizeTextViewDelegate <NSObject>

@optional


- (void)textView:(AutoFitSizeTextView *)textView heightChanged:(NSInteger)height;

@end

@interface AutoFitSizeTextView : UITextView


@property (nonatomic,weak) id <AutoFitSizeTextViewDelegate> fitSizeDelegate;

@end
