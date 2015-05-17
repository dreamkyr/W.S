//
//  HPTextViewInternal.h

#import <UIKit/UIKit.h>


@interface HPTextViewInternal : UITextView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic) BOOL displayPlaceHolder;

@end
