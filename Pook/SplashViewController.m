//
//  SplashViewController.m
//  Pook

#import "SplashViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"

#import "MainViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    NSString *pathImg = [[NSBundle mainBundle] pathForResource:@"abstract-256" ofType:@"gif"];
    NSString* webViewContent = [NSString stringWithFormat:
                                @"<html><body><img style='width:128;height:128;' src=\"file://%@\" /></body></html>", pathImg];
    [aniBg loadHTMLString:webViewContent baseURL:nil];
    aniBg.scalesPageToFit = NO;
    [aniBg setBackgroundColor:[UIColor clearColor]];
    [aniBg setOpaque:NO];
    aniBg.userInteractionEnabled = NO;

    [self performSelector:@selector(nextView) withObject:nil afterDelay:1.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    if ([AppDelegate getDelegate].logoutflat == 1) {
        [self performSelector:@selector(nextView) withObject:nil afterDelay:3.0f];
    }
}

-(void) nextView  
{
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
        NSLog(@"Not logged in last time");
        ViewController *controller = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
        // Do any additional setup after loading the view from its nib.
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
