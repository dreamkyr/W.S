//
//  ViewController.m
//  Pook

#import "ViewController.h"

#import "AppDelegate.h"

#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "MainViewController.h"

#import "CommonMethods.h"
#import "PkUser.h"
#import "ASIFormDataRequest.h"

#import "Constant.h"
#import "JSON.h"

@interface ViewController ()

@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Check if login lasttime
    NSString *useremail = [[NSUserDefaults standardUserDefaults] stringForKey:@"Email"];
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserID"];
    NSLog(@"userEmail = %@, userID = %@", useremail,userID);
    
    if (userID != nil)
    {
        MainViewController *controller = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
        [AppDelegate getDelegate].curUser.userid = userID;
    }
    else
    {
        [self performSelector:@selector(signIn) withObject:nil afterDelay:2];
    }
    
    //===============
    [CommonMethods getAllContacts];
}

- (void) signIn
{
    NSLog(@"--- %@", [AppDelegate getDelegate].str_devToken);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"signin" forKey:@"service"];
    [request addPostValue:@"default" forKey:@"email"];
    [request addPostValue:@"default" forKey:@"password"];
    [request addPostValue:[AppDelegate getDelegate].str_devToken forKey:@"device_token"];
    [request setTimeOutSeconds:30];
    [request setDidFinishSelector:@selector(signIn_didSuccess:)];
    [request setDidFailSelector:@selector(signIn_didFail:)];
    [request startAsynchronous];
    [request setDelegate:self];
    
}

-(void) signIn_didSuccess:(ASIFormDataRequest*)request
{
    if (request.responseStatusCode == 200)
    {
        NSLog(@"Login Status = %@", request.responseString);
        SBJSON *json = [SBJSON new];
        NSDictionary *dict = [json objectWithString:request.responseString error:nil];
        int statuscode = [[dict objectForKey:@"status_code"] intValue];
        
        if (statuscode == 1) /*Success*/ {
            
            NSDictionary *user = [dict objectForKey:@"user"];
            
            NSString *userid = [NSString stringWithFormat:@"%@", [user objectForKey:@"id"]];
            NSString *username = [user objectForKey:@"username"];
            NSString *email = [user objectForKey:@"email"];
            NSString *profile = [user objectForKey:@"profile"];
            
            [AppDelegate getDelegate].curUser.userid = userid;
            
            [[NSUserDefaults standardUserDefaults] setValue:userid forKey:@"UserID"];
            [[NSUserDefaults standardUserDefaults] setValue:email forKey:@"Email"];
            [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setValue:profile forKey:@"profile"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            MainViewController *controller = [[MainViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if (statuscode == 2) /*Password wrong*/{
            [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Password does not match"];
        }
        else /*Email wrong*/{
            [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"User does not Exist"];
        }
    }
    else
    {
        [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Can't access Server"];
    }
}

-(void) signIn_didFail:(ASIFormDataRequest*)request
{
    [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"No Internet Connection"];
    NSLog(@"Login Failed");
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

@end
