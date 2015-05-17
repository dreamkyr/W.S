//
//  DataManager.m
//  Bento App
//
//  Created by hanjinghe on 8/8/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "DataManager.h"

#import "ASIFormDataRequest.h"
#import "SBJSON.h"

#import "Constant.h"

#import "AppDelegate.h"

#import "NotificationObject.h"

@interface DataManager ()
{
    BOOL isCheckingReadNotificaitons;
}

@property (nonatomic, retain) NSMutableArray *aryCheckingNotifications;


@end

@implementation DataManager

static DataManager *_shareDataManager;

+ (DataManager *)shareDataManager
{
    @synchronized(self) {
        
        if (_shareDataManager == nil)
        {
            _shareDataManager = [[DataManager alloc] init];
        }
    }
    
    return _shareDataManager;
}

+ (void)releaseDataManager
{
    if (_shareDataManager != nil)
    {
        _shareDataManager = nil;
    }
}

- (id) init
{
	if ( (self = [super init]) )
	{
        isCheckingReadNotificaitons = NO;
        self.aryNotifications = [[NSMutableArray alloc] init];
        
        [NSTimer scheduledTimerWithTimeInterval:3 * 60 target:self selector:@selector(refreshNotifications) userInfo:nil repeats:YES];
	}
	
	return self;
}

- (int) getUnreadNotificaitonCount
{
    int count = 0;
    for (NSDictionary *notification in self.aryNotifications) {
        
        BOOL isRead = [[notification objectForKey:@"isread"] boolValue];
        
        if(!isRead)
        {
            if(![self isNewCheckedNotification:notification])
            {
                count ++;
            }
        }
    }
    
    return count;
}

- (BOOL) isNewCheckedNotification:(NSDictionary *)notification
{
    NSString *notificationId = [NSString stringWithFormat:@"%@",[notification objectForKey:@"id"]];
    
    return [self.aryCheckingNotifications containsObject:notificationId];
}

- (void) refreshNotifications
{
    [self performSelectorInBackground:@selector(reqNotifications) withObject:nil];
}

-(void) reqNotifications
{
    if(isCheckingReadNotificaitons) return;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"loadnotifications" forKey:@"service"];
    [request addPostValue:[AppDelegate getDelegate].curUser.userid forKey:@"userid"];
    [request setDelegate:self];
    [request setTimeOutSeconds:30];
    [request setDidFinishSelector:@selector(loadFeeds_didSuccess:)];
    [request setDidFailSelector:@selector(loadFeeds_didFail:)];
    [request startAsynchronous];
}

- (void) loadFeeds_didSuccess:(ASIFormDataRequest*)request
{
    SBJSON *json = [SBJSON new];
    NSDictionary *dict = [json objectWithString:request.responseString error:nil];
    if (request.responseStatusCode == 200)
    {
        NSLog(@"Feeds =%@", request.responseString);
        
        [self.aryNotifications removeAllObjects];
        [self.aryCheckingNotifications removeAllObjects];
        
        NSArray *notifications = [dict objectForKey:@"notifications"];
        
        for (int i = 0 ; i < [notifications count] ; i++ )
        {
            NSDictionary *notification = [notifications objectAtIndex:i];
            
            [self.aryNotifications addObject:notification];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATED_NOTIFICATIONS object:nil];
    }

}

- (void) loadFeeds_didFail:(ASIFormDataRequest *)request
{

}

- (void) reqCheckAllNotifications
{
    if(self.aryCheckingNotifications == nil)
    {
        self.aryCheckingNotifications = [[NSMutableArray alloc] init];
    }
    
    [self.aryCheckingNotifications removeAllObjects];
    
    for (NSDictionary *notification in self.aryNotifications) {
        
        NSString *notificationId = [notification objectForKey:@"id"];
        
        [self.aryCheckingNotifications addObject:notificationId];
    }
    
    if(self.aryCheckingNotifications.count == 0) return;
    
    [self performSelectorInBackground:@selector(reqNewCheckReadNotifications) withObject:nil];
}

- (void) reqCheckNotificaitons:(NSMutableArray *)aryNotifications
{
    self.aryCheckingNotifications = aryNotifications;
    
    if(self.aryCheckingNotifications.count == 0) return;
    
    [self performSelectorInBackground:@selector(reqNewCheckReadNotifications) withObject:nil];
}

- (NSString *)getCheckingNotificationIds
{
    if(self.aryCheckingNotifications.count == 0) return nil;
    
    NSString *notificationIds = [self.aryCheckingNotifications objectAtIndex:0];
    
    for (int n = 1; n < self.aryCheckingNotifications.count; n ++) {
        NSString *notificationId = [self.aryCheckingNotifications objectAtIndex:n];
        notificationIds = [NSString stringWithFormat:@"%@,%@", notificationIds, notificationId];
    }
    
    return notificationIds;
}

-(void) reqNewCheckReadNotifications
{
    NSString *ids = [self getCheckingNotificationIds];
    
    if(ids == nil) return;
    
    isCheckingReadNotificaitons = YES;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"readnotifications" forKey:@"service"];
    [request addPostValue:[AppDelegate getDelegate].curUser.userid forKey:@"userid"];
    [request addPostValue:ids forKey:@"notificationids"];
    [request setDelegate:self];
    [request setTimeOutSeconds:30];
    [request setDidFinishSelector:@selector(checkRead_didSuccess:)];
    [request setDidFailSelector:@selector(checkRead_didFail:)];
    [request startAsynchronous];
}

- (void) checkRead_didSuccess:(ASIFormDataRequest*)request
{
    isCheckingReadNotificaitons = NO;
    
    if (request.responseStatusCode == 200)
    {
        NSLog(@"Feeds =%@", request.responseString);
        
        [self reqNotifications];
    }
}

- (void) checkRead_didFail:(ASIFormDataRequest *)request
{
    isCheckingReadNotificaitons = NO;
}

@end
