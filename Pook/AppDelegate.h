//
//  AppDelegate.h
//  Pook
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

#import "PkUser.h"
#import "PookFeed.h"

@class ViewController;
@class SplashViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    int pushType;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) NSString *str_devToken;

@property (nonatomic, retain) PkUser *curUser;

@property (strong, retain) NSData *dataBGpic;

@property (nonatomic, strong) PookFeed *curFeed;
@property int cellIndex;
@property int celltype;
@property int logoutflat;
@property int notification_ownerid;
@property int flag_noti;
@property (nonatomic, strong) UIApplication *globe_application;

@property (nonatomic, assign) BOOL isUpdatedFeeds;

+ (AppDelegate*) getDelegate;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)userLoggedIn;
- (void)userLoggedOut;

- (void) hideStatusBar;

@end
