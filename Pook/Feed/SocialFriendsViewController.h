//
//  SocialFriendsViewController.h
//  Pook
//
//  Created by han on 1/15/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SocialFriendsViewControllerDelegate <NSObject>

- (void) onMenuWithSocialFriendsViewController;

@end

@interface SocialFriendsViewController : UIViewController

@property (nonatomic, assign) id <SocialFriendsViewControllerDelegate> delegate;

@property (nonatomic, assign) int friendType; // = 0 : facebook, = 1 : instagram

- (void) reloadFriends;

@end
