//
//  MainViewController.m
//  Pook
//
//  Created by han on 1/14/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import "MainViewController.h"

#import "YCameraViewController.h"

#import "NotificationsViewController.h"
#import "SocialFriendsViewController.h"
#import "TermsViewController.h"
#import "CommentViewController.h"

#import "AddCommentViewController.h"

#import "Constant.h"

#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "CommonMethods.h"

#import "FeedCollectionViewCell.h"
#import "MenuTableViewCell.h"

#import "NotificationObject.h"

#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

#import "DataManager.h"

@interface MainViewController ()<FeedCollectionViewCellDelegate, CLLocationManagerDelegate, NotificationViewControllerDelegate, SocialFriendsViewControllerDelegate, TermsViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate>
{
    BOOL _isShowingMenu;
    
    BOOL _isShowingRecentPosts;
    
    PookFeed *_isLikingFeed;
    
    UIRefreshControl *refreshControl;
    
    PookFeed *_isSavingFeed;
    UIImage *_isSavingImage;
}

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;

@property (nonatomic, assign) IBOutlet UIView *viewMenu;
@property (nonatomic, assign) IBOutlet UIView *viewMain;

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;
@property (nonatomic, assign) IBOutlet UIButton *btnName;

@property (nonatomic, assign) IBOutlet UILabel *lblBadge;

@property (nonatomic, assign) IBOutlet UICollectionView *cvPosts;

@property (nonatomic, assign) IBOutlet UITableView *tvMenu;

@property (nonatomic, assign) IBOutlet UIButton *btnRecent;
@property (nonatomic, assign) IBOutlet UIButton *btnNearby;

@property (nonatomic, retain) NotificationsViewController *notificationVC;
@property (nonatomic, retain) SocialFriendsViewController *socialFriendsVC;
@property (nonatomic, retain) TermsViewController *termsVC;

@property (nonatomic, retain) NSMutableArray *aryRecentPosts;
@property (nonatomic, retain) NSMutableArray *aryNearbyPosts;

@property (nonatomic, retain) NSMutableArray *aryNotifications;

@property (nonatomic, retain) UIDocumentInteractionController *docController;

//LocationManager
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([DataManager shareDataManager].aryNotifications.count == 0)
    {
        [[DataManager shareDataManager] refreshNotifications];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *profileUrl = [NSString stringWithFormat:@"%@%@", DirectoryURL,  [prefs objectForKey:@"profile"]];
    
    [self.btnName setTitle:[prefs objectForKey:@"username"] forState:UIControlStateNormal] ;
    [self.ivProfile sd_setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2;
    self.ivProfile.clipsToBounds = YES;
    
    _isShowingMenu = NO;
    _isShowingRecentPosts = NO;
    
    self.aryNearbyPosts = [[NSMutableArray alloc] init];
    self.aryRecentPosts = [[NSMutableArray alloc] init];
    
    self.lblBadge.layer.cornerRadius = CGRectGetWidth(self.lblBadge.frame) / 2;
    
    double lat = [prefs doubleForKey:@"lat"];
    double lng = [prefs doubleForKey:@"lng"];
    
    if(lat != 0 || lng != 0)
    {
        self.location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    }
    
    //Location Manager
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    UINib *cellNib = [UINib nibWithNibName:@"FeedCollectionViewCell" bundle:nil];
    [self.cvPosts registerNib:cellNib forCellWithReuseIdentifier:@"postcell"];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor colorWithRed:77.0f / 255.0f green:168.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
    [refreshControl addTarget:self action:@selector(reloadDataPosts) forControlEvents:UIControlEventValueChanged];
    [self.cvPosts addSubview:refreshControl];
    
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
    
    [self updateUI];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(app.isUpdatedFeeds)
    {
        app.isUpdatedFeeds = NO;
        [self reloadDataPosts];
    }
}

- (void) updatedNotifications
{
    int count = [[DataManager shareDataManager] getUnreadNotificaitonCount];
    
    self.lblBadge.hidden = count == 0;
    
    [self.tvMenu reloadData];
    
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = count;
}

- (IBAction)onMenu:(id)sender
{
    _isShowingMenu = !_isShowingMenu;
    
    [UIView animateWithDuration:0.3f animations:^{
        
        [self updateUI];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)onPost:(id)sender
{
    YCameraViewController *controller = [[YCameraViewController alloc] init];
    controller.m_parentView = self;
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void) reloadDataPosts
{
    if(_isShowingRecentPosts)
    {
        [self onRecent:nil];
    }
    else
    {
        [self onNearby:nil];
    }
}

- (IBAction)onRecent:(id)sender
{
    //if(_isShowingRecentPosts) return;
    
    _isShowingRecentPosts = YES;
    
    [self updateUI];
    
    [self performSelectorInBackground:@selector(loadFeeds) withObject:nil];
}

- (IBAction)onNearby:(id)sender
{
    //if(!_isShowingRecentPosts) return;
    
    _isShowingRecentPosts = NO;
    
    [self updateUI];
    
    [self performSelectorInBackground:@selector(loadFeedsNearBy) withObject:nil];
}

- (void) onShareWasteSelfie
{
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Share to:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"SMS", @"Email", @"Facebook", @"Twitter", nil];
    actionsheet.tag = 1;
    
    [actionsheet showInView:self.view];
    actionsheet = nil;
}

- (IBAction)onChangeProfile:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a profile photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Library", @"Camera", nil];
    
    actionSheet.tag = 3;
    [actionSheet showInView:self.view];
}

- (void) openLibrary
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        picker = nil;
    }
}

- (void) openCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        picker = nil;
    }
}

- (void) updateUI
{
    CGRect rtScreen = [[UIScreen mainScreen] bounds];
    
    float width = CGRectGetWidth(rtScreen);
    float height = CGRectGetHeight(rtScreen);
    
    self.svMain.frame = CGRectMake(0, 0, width, height);
    self.svMain.contentSize = CGSizeMake(270 + width, height);
    
    self.viewMenu.frame = CGRectMake(0, 0, 270, height);
    self.viewMain.frame = CGRectMake(270, 0, width, height);
    
//    self.viewMenu.frame = CGRectMake(_isShowingMenu ? 0 : -self.viewMenu.frame.size.width, self.viewMenu.frame.origin.y, CGRectGetWidth(self.viewMenu.frame), CGRectGetHeight(self.viewMenu.frame));
//    self.viewMain.frame = CGRectMake(_isShowingMenu ? self.viewMenu.frame.size.width : 0, self.viewMain.frame.origin.y, CGRectGetWidth(self.viewMain.frame), CGRectGetHeight(self.viewMain.frame));\
    
    if(_isShowingMenu)
    {
        [self.svMain setContentOffset:CGPointMake(0, 0) animated:YES];
        
        if(!self.notificationVC.view.isHidden)
        {
            //[self.notificationVC reqNewCheckReadNotifications];
            
            [self.tvMenu reloadData];
            
            self.lblBadge.hidden = [[DataManager shareDataManager] getUnreadNotificaitonCount] == 0;
        }
    }
    else
    {
        [self.svMain setContentOffset:CGPointMake(270, 0) animated:YES];
    }
    
    self.btnRecent.selected = _isShowingRecentPosts;
    self.btnNearby.selected = !_isShowingRecentPosts;
}

- (void) showNotificationsView
{
    if(self.notificationVC == nil)
    {
        self.notificationVC = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
        self.notificationVC.view.frame = CGRectMake(0, 0, self.viewMain.frame.size.width, self.viewMain.frame.size.height);
        self.notificationVC.delegate = self;
        
        [self.viewMain addSubview:self.notificationVC.view];
    }
    
    self.notificationVC.view.hidden = NO;
    
    [self.viewMain bringSubviewToFront:self.notificationVC.view];
    
    [self.notificationVC reloadNotifications];
}

- (void) showSocialFriendsView:(int)type // 0 : facebook , 1 : instagram
{
    if(self.socialFriendsVC == nil)
    {
        self.socialFriendsVC = [[SocialFriendsViewController alloc] initWithNibName:@"SocialFriendsViewController" bundle:nil];
        self.socialFriendsVC.view.frame = CGRectMake(0, 0, self.viewMain.frame.size.width, self.viewMain.frame.size.height);
        self.socialFriendsVC.delegate = self;
        
        [self.viewMain addSubview:self.socialFriendsVC.view];
    }
    
    self.socialFriendsVC.friendType = type;
    self.socialFriendsVC.view.hidden = NO;
    
    [self.viewMain bringSubviewToFront:self.socialFriendsVC.view];
    
    [self.socialFriendsVC reloadFriends];
}

- (void) showTermsView
{
    if(self.termsVC == nil)
    {
        self.termsVC = [[TermsViewController alloc] initWithNibName:@"TermsViewController" bundle:nil];
        self.termsVC.view.frame = CGRectMake(0, 0, self.viewMain.frame.size.width, self.viewMain.frame.size.height);
        self.termsVC.delegate = self;
        
        [self.viewMain addSubview:self.termsVC.view];
    }
    
    self.termsVC.view.hidden = NO;
    
    [self.viewMain bringSubviewToFront:self.termsVC.view];
}

- (void) gotoCommentScreen:(PookFeed *)feed
{
    //if([[AppDelegate getDelegate].curUser.userid intValue] == feed.post_userid)
    {
        CommentViewController *commentVC = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:nil];
        commentVC.feed = feed;
        
        [self.navigationController pushViewController:commentVC animated:YES];
        commentVC = nil;
    }
//    else
//    {
//        AddCommentViewController *vc = [[AddCommentViewController alloc] initWithNibName:@"AddCommentViewController" bundle:nil];
//        vc.feed = feed;
//        
//        [self.navigationController pushViewController:vc animated:YES];
//        vc = nil;
//    }
}

#pragma mark -
#pragma mark Share

- (void) onSaveToPhone:(UIImage *)image
{
    if(image == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"There is no image for saving." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        alertView = nil;
    }
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (void) complatedToSaveOnPhone
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Successed to save!!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
    alertView = nil;
}

- (void) onShareToSMS
{
    if ( [MFMessageComposeViewController canSendText] ) {
        
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        
        picker.messageComposeDelegate = self;
        
        picker.body = [self getShareMessage];
        
        [self presentViewController:picker animated:YES completion:nil];
        picker = nil;
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) onShareToEmail
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc]init];
        mailer.mailComposeDelegate = self;
        
        //[mailer setToRecipients:arr];
        
        [mailer setSubject:@""];
        [mailer setMessageBody:[self getShareMessage] isHTML:NO];
        
        [self presentViewController:mailer animated:YES completion:nil];
        mailer = nil;
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) onShareToFacebook:(UIImage *)image message:(NSString *)message
{
    if(image == nil) image = [UIImage imageNamed:@"AppIcon"];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:message];
        [controller addImage:image];
        
        [self presentViewController:controller animated:YES completion:Nil];
        
        [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    break;
                    
                case SLComposeViewControllerResultDone:
                    break;
                    
                default:
                    break;
            }
            
        }];
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please set your facebook account on Phone Setting." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [alertView show];
        alertView = nil;
    }
}

- (void) onShareToTwitter
{
    NSString *message = [self getShareMessage];
    
    UIImage *image = [UIImage imageNamed:@"AppIcon"];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:message];
        [tweetSheet addImage:image];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        
        [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    break;
                    
                case SLComposeViewControllerResultDone:
                    break;
                    
                default:
                    break;
            }
            
        }];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please set your twitter account on Phone Setting." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [alertView show];
        alertView = nil;
    }
}

- (NSString *) getShareMessage
{
    NSString *sMessage = @"https://itunes.apple.com/us/app/wasted-selfie/id966924734?ls=1&mt=8";
    
    return sMessage;
}

#pragma mark -
#pragma mark LoadFeeds

-(void) loadFeeds
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"loadfeeds" forKey:@"service"];
    [request addPostValue:[AppDelegate getDelegate].curUser.userid forKey:@"userid"];
    [request setDelegate:self];
    [request setTimeOutSeconds:30];
    [request setDidFinishSelector:@selector(loadFeeds_didSuccess:)];
    [request setDidFailSelector:@selector(loadFeeds_didFail:)];
    [request startAsynchronous];
}

- (void) loadFeeds_didSuccess:(ASIFormDataRequest*)request
{
    [refreshControl endRefreshing];
    
    SBJSON *json = [SBJSON new];
    NSDictionary *dict = [json objectWithString:request.responseString error:nil];
    if (request.responseStatusCode == 200)
    {
        [self.aryRecentPosts removeAllObjects];
        
        NSLog(@"Feeds =%@", request.responseString);
        NSArray *arrPosts = [[NSArray alloc] init];
        arrPosts = [dict objectForKey:@"posts"];
        
        for (int i = 0; i < arrPosts.count ; i++)
        {
            PookFeed *feed = [[PookFeed alloc] initWithDict:[arrPosts objectAtIndex:i]];
            [self.aryRecentPosts addObject:feed];
        }
        
        [self.cvPosts reloadData];
    }
    else
    {
        [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Can't access Server"];
    }
}

- (void) loadFeeds_didFail:(ASIFormDataRequest *)request
{
    [refreshControl endRefreshing];
    
    [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Internet Connection Error"];
}

-(void) loadFeedsNearBy
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"loadfeedsnearby" forKey:@"service"];
    [request addPostValue:[AppDelegate getDelegate].curUser.userid forKey:@"userid"];
    [request addPostValue:[NSNumber numberWithFloat:self.location.coordinate.latitude] forKey:@"lat"];
    [request addPostValue:[NSNumber numberWithFloat:self.location.coordinate.longitude] forKey:@"lng"];
    [request addPostValue:@10000 forKey:@"radius"];
    [request setDelegate:self];
    [request setTimeOutSeconds:30.0f];
    [request setDidFinishSelector:@selector(loadFeedsNearBy_didSuccess:)];
    [request setDidFailSelector:@selector(loadFeedsNearBy_didFail:)];
    [request startAsynchronous];
}

- (void) loadFeedsNearBy_didSuccess:(ASIFormDataRequest*)request
{
    [refreshControl endRefreshing];
    
    SBJSON *json = [SBJSON new];
    NSDictionary *dict = [json objectWithString:request.responseString error:nil];
    if (request.responseStatusCode == 200)
    {
        [self.aryNearbyPosts removeAllObjects];
        
        NSLog(@"Feeds =%@", request.responseString);
        NSArray *arrPosts = [[NSArray alloc] init];
        arrPosts = [dict objectForKey:@"posts"];
        
        for (int i = 0; i < arrPosts.count ; i++)
        {
            PookFeed *feed = [[PookFeed alloc] initWithDict:[arrPosts objectAtIndex:i]];
            [self.aryNearbyPosts addObject:feed];
        }
        
        [self.cvPosts reloadData];
    }
    else
    {
        [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Can't access Server"];
    }
}

- (void) loadFeedsNearBy_didFail:(ASIFormDataRequest*)request
{
    [refreshControl endRefreshing];
}

#pragma -mark Liking

-(void) onLikeFeed:(PookFeed *)feed index:(NSInteger)index
{
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _isLikingFeed = feed;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];

    int postid = feed.postid;
    request.index = index;
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"likepost" forKey:@"service"];
    [request addPostValue:[NSString stringWithFormat:@"%i", postid] forKey:@"postid"];
    [request addPostValue:[AppDelegate getDelegate].curUser.userid forKey:@"userid"];
    [request setDidFinishSelector:@selector(LikePost_didSuccess:)];
    [request setDelegate:self];
    [request setTimeOutSeconds:30];
    [request startAsynchronous];
}

-(void) LikePost_didSuccess:(ASIFormDataRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (request.responseStatusCode == 200)
    {
        FeedCollectionViewCell *cell = (FeedCollectionViewCell *)[self.cvPosts cellForItemAtIndexPath:[NSIndexPath indexPathForItem:request.index inSection:0]];
        
        _isLikingFeed.likeid = 1;
        NSString *str_devToken = _isLikingFeed.device_token;
        NSLog(@"deviceToken = %@", _isLikingFeed.device_token);
        
        SBJSON *json = [SBJSON new];
        NSDictionary *dict = [json objectWithString:request.responseString error:nil];
        if ([[dict objectForKey:@"message"] isEqualToString:@"success"])
        {
            if (cell) {
                
                [cell increaseLikeCount];
            }
        }
        else
        {
            _isLikingFeed.likeid = 0;
        }
        
    }
}

#pragma -mark Table Delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableViewCell *cell = (MenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MenuTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.lblBadge.hidden = YES;
    
    if(indexPath.row == 0)
    {
        cell.ivIcon.image = [UIImage imageNamed:@"icon_recent"];
        cell.lblTitle.text = @"Recent";
    }
    else if(indexPath.row == 1)
    {
        cell.ivIcon.image = [UIImage imageNamed:@"icon_nearby"];
        cell.lblTitle.text = @"Nearby";
    }
    else if(indexPath.row == 2)
    {
        cell.ivIcon.image = [UIImage imageNamed:@"icon_notification"];
        cell.lblTitle.text = @"Notifications";
        
        [cell.lblTitle sizeToFit];
        
        int notificationCounts = [[DataManager shareDataManager] getUnreadNotificaitonCount];
        if(notificationCounts > 0)
        {
            cell.lblBadge.hidden = NO;
            cell.lblBadge.text = [NSString stringWithFormat:@"%d", notificationCounts];
            [cell.lblBadge sizeToFit];
            
            float width = MAX(self.lblBadge.frame.size.width, 20);
            cell.lblBadge.frame = CGRectMake(cell.lblBadge.frame.origin.x, cell.lblBadge.frame.origin.y, width, 20);
            
            cell.lblBadge.layer.cornerRadius = 10;
            cell.lblBadge.clipsToBounds = YES;
            
            cell.lblBadge.center = CGPointMake(cell.lblTitle.frame.size.width + cell.lblTitle.frame.origin.x, cell.lblTitle.frame.origin.y);
        }
    }
//    else if(indexPath.row == 3)
//    {
//        cell.ivIcon.image = [UIImage imageNamed:@"icon_addfriend"];
//        cell.lblTitle.text = @"Add Facebook Friends";
//    }
//    else if(indexPath.row == 4)
//    {
//        cell.ivIcon.image = [UIImage imageNamed:@"icon_addfriend"];
//        cell.lblTitle.text = @"Add Instagram Friends";
//    }
    else if(indexPath.row == 3)
    {
        cell.ivIcon.image = [UIImage imageNamed:@"icon_terms"];
        cell.lblTitle.text = @"Terms of Service";
    }
    else if(indexPath.row == 4)
    {
        cell.ivIcon.image = [UIImage imageNamed:@"icon_share"];
        cell.lblTitle.text = @"Share WastedSelfie";
    }

    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.notificationVC.view.hidden = YES;
    self.socialFriendsVC.view.hidden = YES;
    self.termsVC.view.hidden = YES;
    
    if(indexPath.row == 0)
    {
        [self onRecent:nil];
        
        [self onMenu:nil];
    }
    else if(indexPath.row == 1)
    {
        [self onNearby:nil];
        
        [self onMenu:nil];
    }
    else if(indexPath.row == 2) //Notifications
    {
        [[DataManager shareDataManager] reqCheckAllNotifications];
        
        [self showNotificationsView];
        
        [self onMenu:nil];
    }
//    else if(indexPath.row == 3) //Add Facebook Friends
//    {
//        [self showSocialFriendsView:0];
//        
//        [self onMenu:nil];
//    }
//    else if(indexPath.row == 4) //Add Instagram Friends
//    {
//        [self showSocialFriendsView:1];
//        
//        [self onMenu:nil];
//    }
    else if(indexPath.row == 3) //Terms of Service
    {
        [self showTermsView];
        
        [self onMenu:nil];
    }
    else if(indexPath.row == 4) //Share WastedSelfie
    {
        [self onShareWasteSelfie];
    }

}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Email"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        [AppDelegate getDelegate].logoutflat = 1;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(_isShowingRecentPosts)
        return self.aryRecentPosts.count;
    
    return self.aryNearbyPosts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"postcell";
        
    FeedCollectionViewCell *cell = (FeedCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    cell.clipsToBounds = YES;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

    FeedCollectionViewCell *myCell = (FeedCollectionViewCell *)cell;
    
    PookFeed *feed = nil;
    
    if(_isShowingRecentPosts)
        feed = [self.aryRecentPosts objectAtIndex:indexPath.row];
    else
        feed = [self.aryNearbyPosts objectAtIndex:indexPath.row];
    
    [myCell setPostInfo:feed index:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = self.cvPosts.frame;
    
    PookFeed *feed = nil;
    
    if(_isShowingRecentPosts)
        feed = [self.aryRecentPosts objectAtIndex:indexPath.row];
    else
        feed = [self.aryNearbyPosts objectAtIndex:indexPath.row];
    
    float height = [FeedCollectionViewCell getPostCellHeight:feed width:frame.size.width];
    
    return CGSizeMake(CGRectGetWidth(frame), height);
}

#pragma mark -
#pragma mark Location Manager
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setDouble:newLocation.coordinate.latitude forKey:@"lat"];
    [prefs setDouble:newLocation.coordinate.longitude forKey:@"lng"];
    
    [prefs synchronize];
    
    self.location = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark FeedCollectionViewCellDelegate

- (void) likeFeed:(PookFeed *)feed index:(NSInteger)index
{
    [self onLikeFeed:feed index:index];
}

- (void) commentFeed:(PookFeed *)feed index:(NSInteger)index
{
    [self gotoCommentScreen:feed];
}

- (void) shareFeed:(PookFeed *)feed image:(UIImage *)image index:(NSInteger)index
{
    _isSavingFeed = feed;
    _isSavingImage = image;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You can flag this post and our moderator team will review this within 24 hours." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Flag", @"Save to Phone", @"Share to Facebook", @"Share on other apps",nil];
    actionSheet.tag = 2;
    
    [actionSheet showInView:self.view];
    actionSheet = nil;
}

#pragma mark NotificationViewControllerDelegate

- (void) onMenuWithNotificationViewController
{
    [self onMenu:nil];
}

#pragma mark SocialFriendViewControllerDelegate

- (void) onMenuWithSocialFriendsViewController
{
    [self onMenu:nil];
}

#pragma mark TermsViewControllerDelegate

- (void) onMenuWithTermsViewController
{
    [self onMenu:nil];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView == self.svMain)
    {
        float offPos = scrollView.contentOffset.x;
        
        [self proccessOffset:offPos];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == self.svMain)
    {
        [self updateUI];
    }
}

- (void) proccessOffset:(float)offset
{
    float base = 135;
    
    if(_isShowingMenu) base = 30;
    else base = 240;
    
    if(offset < base)
    {
        _isShowingMenu = YES;
    }
    else
    {
        _isShowingMenu = NO;
    }
    
    [self updateUI];
}

-(void)ShareInstagram:(UIImage *)image
{
    [self storeimage:image];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        
        CGRect rect = CGRectMake(0 ,0 , 612, 612);
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/15717.ig"];
        
        NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
        self.docController.UTI = @"com.instagram.photo";
        self.docController = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
        self.docController = [UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
        self.docController.delegate= self;
        [self.docController presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
        //  [[UIApplication sharedApplication] openURL:instagramURL];
    }
    else
    {
        //   NSLog(@"instagramImageShare");
        UIAlertView *errorToShare = [[UIAlertView alloc] initWithTitle:@"Instagram unavailable " message:@"You need to install Instagram in your device in order to share this image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [errorToShare show];
        errorToShare = nil;
    }
}


- (void) storeimage:(UIImage *)image
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"15717.ig"];
    
    //UIImage *NewImg=[self resizedImage:image :CGRectMake(0, 0, 420, 420) ];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [imageData writeToFile:savedImagePath atomically:NO];
}

-(UIImage*) resizedImage:(UIImage *)inImage: (CGRect) thumbRect
{
    CGImageRef imageRef = [inImage CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    
    // There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
    // see Supported Pixel Formats in the Quartz 2D Programming Guide
    // Creating a Bitmap Graphics Context section
    // only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
    // and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
    // The images on input here are likely to be png or jpeg files
    if (alphaInfo == kCGImageAlphaNone)
        alphaInfo = kCGImageAlphaNoneSkipLast;
    
    // Build a bitmap context that's the size of the thumbRect
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                thumbRect.size.width,       // width
                                                thumbRect.size.height,      // height
                                                CGImageGetBitsPerComponent(imageRef),   // really needs to always be 8
                                                4 * thumbRect.size.width,   // rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo
                                                );
    
    // Draw into the context, this scales the image
    CGContextDrawImage(bitmap, thumbRect, imageRef);
    
    // Get an image from the context and a UIImage
    CGImageRef  ref = CGBitmapContextCreateImage(bitmap);
    UIImage*    result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);   // ok if NULL
    CGImageRelease(ref);
    
    return result;
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    interactionController.delegate = self;
    
    return interactionController;
}

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    
}

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller canPerformAction:(SEL)action
{

    return YES;
}

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller performAction:(SEL)action
{
    return YES;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{

}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1)
    {
        if(buttonIndex == 0)
        {
            [self onShareToSMS];
        }
        else if(buttonIndex == 1)
        {
            [self onShareToEmail];
        }
        else if(buttonIndex == 2)
        {
            [self onShareToFacebook:nil message:[self getShareMessage]];
        }
        else if(buttonIndex == 3)
        {
            [self onShareToTwitter];
        }
    }
    else if(actionSheet.tag == 2)
    {
        if(buttonIndex == 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Thank you for flagging this post. We will review it within 24 hours and remove any bullying, spam, impersonation or other in-appropriate activity that violates or terms of service agreement." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alertView show];
            alertView = nil;
        }
        else if(buttonIndex == 1)
        {
            [self onSaveToPhone:_isSavingImage];
        }
        else if(buttonIndex == 2)
        {
            [self onShareToFacebook:_isSavingImage message:[CommonMethods decodeUTF8:_isSavingFeed.desc_text]];
        }
        else if(buttonIndex == 3)
        {
            [self ShareInstagram:_isSavingImage];
        }
    }
    else if(actionSheet.tag == 3)
    {
        if(buttonIndex == 0)
        {
            [self openLibrary];
        }
        else if(buttonIndex == 1)
        {
            [self openCamera];
        }
    }
}

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    self.ivProfile.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self performSelectorInBackground:@selector(reqUpdateProfileImage) withObject:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) reqUpdateProfileImage
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"updateprofile" forKey:@"service"];
    [request addPostValue:[AppDelegate getDelegate].curUser.userid forKey:@"userid"];
    
    CGSize szImage = self.ivProfile.image.size;
    float newWidth = 120;
    float newHeight = newWidth * szImage.height / szImage.width;
    
    UIImage *profileImage = [MainViewController imageWithImage:self.ivProfile.image scaledToSize:CGSizeMake(newWidth, newHeight )] ;
    if(profileImage != nil)
    {
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8f);
        if(imageData)
        {
            [request addData:imageData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"profile"];
        }
    }
    
    [request setDelegate:self];
    [request setTimeOutSeconds:30];
    [request setDidFinishSelector:@selector(updateProfile_didSuccess:)];
    [request setDidFailSelector:nil];
    [request startAsynchronous];
}

-(void) updateProfile_didSuccess:(ASIFormDataRequest*)request
{
    if (request.responseStatusCode == 200)
    {
        NSLog(@"SignupStatus Code = %@", request.responseString);
        SBJSON *json = [SBJSON new];
        NSDictionary *dict = [json objectWithString:request.responseString error:nil];
        int statuscode = [[dict objectForKey:@"status_code"] intValue];
        
        if (statuscode == 1)//Success
        {   
            NSString *profile = [dict objectForKey:@"profile"];
            
            [[NSUserDefaults standardUserDefaults] setValue:profile forKey:@"profile"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

@end
