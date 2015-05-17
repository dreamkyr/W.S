//
//  SocialFriendTableViewCell.m
//  Pook
//
//  Created by han on 1/15/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import "SocialFriendTableViewCell.h"

@interface SocialFriendTableViewCell()

@property (nonatomic, assign) IBOutlet UIView *viewMain;

@end

@implementation SocialFriendTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onCheck:(id)sender
{
    
}

- (void) updateLayout
{
    self.ivProfile.layer.cornerRadius = CGRectGetWidth(self.ivProfile.frame) / 2;
    
    self.viewMain.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

@end
