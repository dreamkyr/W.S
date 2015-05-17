//
//  NotificationsViewController.m
//  Pook
//
//  Created by han on 1/15/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import "NotificationsViewController.h"

#import "NotificationCell.h"

#import "NotificationObject.h"

#import "Constant.h"

#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "CommonMethods.h"

#import "DataManager.h"

@interface NotificationsViewController ()

@property (nonatomic, assign) IBOutlet UITableView *tvNotifications;

@property (nonatomic, retain) NSMutableArray *aryNewCheckedNotifications;

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedNotifications) name:NOTIFICATION_UPDATED_NOTIFICATIONS object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadNotifications];
}

- (IBAction)onMenu:(id)sender
{
    [self.delegate onMenuWithNotificationViewController];
}

- (void) reqNewCheckReadNotifications
{
    if(self.aryNewCheckedNotifications.count > 0)
    {
        [[DataManager shareDataManager] reqCheckNotificaitons:self.aryNewCheckedNotifications];
    }
}

- (void) updatedNotifications
{
    [self.aryNewCheckedNotifications removeAllObjects];
    
    [self reloadNotifications];
}

- (void) reloadNotifications
{
    [self.tvNotifications reloadData];
}

- (NSString *)getTimeString:(NSString *)dateString
{
    NSString *timeString = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    if(date == nil) return @"";
    
    NSDate *today = [self convertToUTC:[NSDate date]];
    
    NSTimeInterval timeInterval = [today timeIntervalSinceDate:date];
    
    if(timeInterval == 1)
    {
        timeString = @"a second ago";
    }
    else if(timeInterval < 60)
    {
        timeString = [NSString stringWithFormat:@"%d seconds ago", (int)timeInterval];
    }
    else if(timeInterval == 60)
    {
        timeString = @"a min ago";
    }
    else if(timeInterval < 60 * 60)
    {
        timeString = [NSString stringWithFormat:@"%d mins ago", (int)(timeInterval / 60)];
    }
    else if(timeInterval < 60 * 60 * 2)
    {
        timeString = @"a hour ago";
    }
    else if(timeInterval < 60 * 60 * 24)
    {
        timeString = [NSString stringWithFormat:@"%d hours ago", (int)(timeInterval / (60 * 60))];
    }
    else if(timeInterval < 60 * 60 * 24 * 2)
    {
        timeString = @"a day ago";
    }
    else if(timeInterval < 60 * 60 * 24 * 7)
    {
        timeString = [NSString stringWithFormat:@"%d days ago", (int)(timeInterval / (60 * 60 * 24))];
    }
    else
    {
        [dateFormatter setDateFormat:@"dd/MM/yy"];
        timeString = [dateFormatter stringFromDate:date];
    }
    
    return timeString;
}

- (NSDate*) convertToUTC:(NSDate*)sourceDate
{
    NSTimeZone* currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone* utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval gmtInterval = gmtOffset - currentGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:sourceDate];
    return destinationDate;
}

- (void) newCheckNotification:(NSDictionary *)notification
{
    if([self isNewCheckedNotification:notification]) return;
    
    NSString *notificationId = [NSString stringWithFormat:@"%@",[notification objectForKey:@"id"]];
    
    if(self.aryNewCheckedNotifications == nil) {
        self.aryNewCheckedNotifications = [[NSMutableArray alloc] init];
    }
    
    [self.aryNewCheckedNotifications addObject:notificationId];
    
    [self.tvNotifications reloadData];
}

- (void) removeNewCheckNotification:(NSDictionary *)notification
{
    if(![self isNewCheckedNotification:notification]) return;
    
    NSString *notificationId = [NSString stringWithFormat:@"%@",[notification objectForKey:@"id"]];
    
    [self.aryNewCheckedNotifications removeObject:notificationId];
    
    [self.tvNotifications reloadData];
}

- (BOOL) isNewCheckedNotification:(NSDictionary *)notification
{
    NSString *notificationId = [NSString stringWithFormat:@"%@",[notification objectForKey:@"id"]];
    
    return [self.aryNewCheckedNotifications containsObject:notificationId];
}

#pragma -mark Table Delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DataManager shareDataManager].aryNotifications.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifer = @"Cell";
    NotificationCell *cell = (NotificationCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NotificationCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell._thumbImg.layer.cornerRadius = CGRectGetWidth(cell._thumbImg.frame) / 2;
    cell._thumbImg.clipsToBounds = YES;
    
    NSDictionary *notification = [[DataManager shareDataManager].aryNotifications objectAtIndex:indexPath.row];
    NSString *profilePath = [notification objectForKey:@"profile"];
    
    if(profilePath != nil && [profilePath isKindOfClass:[NSString class]] && profilePath.length > 0)
    {
        NSString *profileUrl = [NSString stringWithFormat:@"%@%@", DirectoryURL,  profilePath];
        [cell._thumbImg sd_setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:@"avatar"]];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"avatar"];
    }
    
    NSString *message = [notification objectForKey:@"message"];
    if(message == nil || ![message isKindOfClass:[NSString class]])
    {
        message = @"";
    }
    
    cell.lbl_Description.text = message;
    
    NSString *dateString = [notification objectForKey:@"created"];
    NSString *timeString = [self getTimeString:dateString];
    
    cell.lbl_Time.text = timeString;
    
    BOOL isRead = [[notification objectForKey:@"isread"] boolValue];
    
//    if(isRead || [self isNewCheckedNotification:notification])
//    {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
    
    NSDictionary *notification = [[DataManager shareDataManager].aryNotifications objectAtIndex:indexPath.row];
    BOOL isRead = [[notification objectForKey:@"isread"] boolValue];
    
    if(!isRead)
    {
        if([self isNewCheckedNotification:notification])
        {
            [self removeNewCheckNotification:notification];
        }
        else
        {
            [self newCheckNotification:notification];
        }
    }
}

@end
