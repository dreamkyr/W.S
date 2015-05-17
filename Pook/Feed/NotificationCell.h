//
//  NotificationCell.h
//  Pook

#import <UIKit/UIKit.h>

@interface NotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *_thumbImg;

@property (weak, nonatomic) IBOutlet UILabel *lbl_Description;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Time;


@end
