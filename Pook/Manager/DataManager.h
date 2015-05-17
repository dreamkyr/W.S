//
//  DataManager.h
//  Bento App
//
//  Created by hanjinghe on 8/8/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define NOTIFICATION_UPDATED_NOTIFICATIONS @"notification_updated_notifications"

@interface DataManager : NSObject

+ (DataManager *)shareDataManager;
+ (void)releaseDataManager;

@property (nonatomic, retain) NSMutableArray *aryNotifications;

- (void) refreshNotifications;

- (int) getUnreadNotificaitonCount;

- (void) reqCheckNotificaitons:(NSMutableArray *)aryNotifications;
- (void) reqCheckAllNotifications;


@end
