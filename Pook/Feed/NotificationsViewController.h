//
//  NotificationsViewController.h
//  Pook
//
//  Created by han on 1/15/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotificationViewControllerDelegate <NSObject>

- (void) onMenuWithNotificationViewController;

@end

@interface NotificationsViewController : UIViewController

@property (nonatomic, assign) id<NotificationViewControllerDelegate> delegate;

- (void) reloadNotifications;

- (void) setNotifications:(NSMutableArray *)aryNotifications;

- (void) reqNewCheckReadNotifications;

@end
