//
//  SocialFriendTableViewCell.h
//  Pook
//
//  Created by han on 1/15/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialFriendTableViewCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;

@property (nonatomic, assign) IBOutlet UILabel *lblFriendName;

@property (nonatomic, assign) IBOutlet UIButton *btnCheck;

- (void) updateLayout;

@end
