//
//  NotificationCell.m
//  Pook

#import "NotificationCell.h"

@implementation NotificationCell
@synthesize _thumbImg;

- (void)awakeFromNib
{
    self._thumbImg.layer.cornerRadius = self._thumbImg.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
