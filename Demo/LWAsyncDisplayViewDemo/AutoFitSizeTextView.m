




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/









#import "AutoFitSizeTextView.h"

@implementation AutoFitSizeTextView


- (void)setContentSize:(CGSize)contentSize {
    CGSize oriSize = self.contentSize;
    [super setContentSize:contentSize];
    if(oriSize.height != self.contentSize.height){
        CGRect newFrame = self.frame;
        newFrame.size.height = self.contentSize.height;
        self.frame = newFrame;
        if([self.fitSizeDelegate respondsToSelector:@selector(textView:heightChanged:)]){
            [self.fitSizeDelegate textView:self heightChanged:floorf(self.contentSize.height - oriSize.height)];
        }
    }
}


@end
