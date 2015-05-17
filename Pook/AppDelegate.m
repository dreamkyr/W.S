//
//  AppDelegate.m
//  Pook

#import "AppDelegate.h"
#import "Foursquare2.h"

#import "ViewController.h"
#import "SecretViewController.h"

#import "MainViewController.h"

#import "Flurry.h"
#import "Grab/Grab.h"

#import "DataManager.h"
#import "Constant.h"
#import "ASIFormDataRequest.h"

@implementation AppDelegate
@synthesize str_devToken;
@synthesize curUser;
@synthesize dataBGpic;
@synthesize curFeed;
@synthesize cellIndex;
@synthesize celltype;
@synthesize logoutflat;
@synthesize notification_ownerid;
@synthesize navController;
@synthesize flag_noti;
@synthesize globe_application;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.isUpdatedFeeds = YES;
    
    self.globe_application = application;
    application.statusBarHidden = NO;
    self.str_devToken = [[NSString alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.logoutflat = 0;
    self.flag_noti = 0;
    // Override point for customization after application launch.
    
    [Foursquare2 setupFoursquareWithClientId:@"5P1OVCFK0CCVCQ5GBBCWRFGUVNX5R4WGKHL2DGJGZ32FDFKT"
                                      secret:@"UPZJO0A0XL44IHCD1KQBMAYGCZ45Z03BORJZZJXELPWHPSAR"
                                 callbackURL:@"testapp123://foursquare"];
    
    [Flurry startSession:@"9HRFYQ45VBH68B9MP4W2"];
    [Grab initWithSecret:@"pook_e42ad111355:ead011ff654631a8:6XVPZ5DpRxREtbMAtBuAVhq5AHEXu1JNQTL9mNQwuU4="];
    
    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    
    navController = [[UINavigationController alloc] initWithRootViewController:vc];
    [navController setNavigationBarHidden:YES];

    self.curUser = [[PkUser alloc] initWithData];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    [self initFacebook];
    
    [self registerNotificationSetting];
    
    return YES;
}

- (void)hideStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[DataManager shareDataManager] refreshNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+(AppDelegate*) getDelegate
{
	return (AppDelegate*) [[UIApplication sharedApplication] delegate];
}

- (void) registerNotificationSetting
{
#ifdef __IPHONE_8_0
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
    {
        //        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
#else
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
#endif
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.str_devToken = token;
    self.curUser.deviceToken = token;
    NSLog(@"token---%@", token);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    self.str_devToken = @"TEST_DEVICE_TOKEN";
    self.curUser.deviceToken = @"TEST_DEVICE_TOKEN";
    NSLog(@"Fail to registered for remote notification");

}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"])
    {
    }
    else if ([identifier isEqualToString:@"answerAction"])
    {
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[DataManager shareDataManager] refreshNotifications];
}

- (void)showMessage:(NSString *)text
{
    [[[UIAlertView alloc] initWithTitle: nil
                                message: text
                               delegate: self
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: nil] show];
}


#pragma mark -
#pragma mark Facebook.

//SCFacebook Implementation
//====================================================================================================
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

//====================================================================================================
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
//    [GPPURLHandler handleURL:url
//           sourceApplication:sourceApplication
//                  annotation:annotation];
    
    [FBSession.activeSession handleOpenURL:url];
    return [Foursquare2 handleURL:url];
}

//====================================================================================================
-(void) initFacebook
{
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        //        NSLog(@"Found a cached session");
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    } else {
    }
}

// This method will handle ALL the session state changes in the app
//====================================================================================================
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen)
    {
        //        NSLog(@"Session opened");
        //        fbToken = [session accessTokenData].accessToken;
        //        NSLog(@"fbToken = %@", fbToken);
        //
        //        if(self.m_loginView != nil)
        //        {
        //            [(ViewController*)self.m_loginView loginWithToken: fbToken];
        //        }
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
    }
    
    // Handle errors
    if (error){
        //        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                //                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
//====================================================================================================
- (void)userLoggedOut
{
    [self showMessage:@"You're now logged out"];
}

// Show the user the logged-in UI
//====================================================================================================
- (void)userLoggedIn
{
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection,
       NSDictionary<FBGraphUser> *user,
       NSError *error)
     {
         
     }
     ];
}

//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    
//    return [Foursquare2 handleURL:url];
//}



@end
