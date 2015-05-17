//
//  SignInViewController.m
//  Pook
//
//  Created by han on 1/12/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import "SignInViewController.h"

#import "MainViewController.h"

#import "AppDelegate.h"

#import "CommonMethods.h"
#import <AddressBook/AddressBook.h>
#import "Constant.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "MBProgressHUD.h"

#import "DataManager.h"

@interface SignInViewController ()

@property (nonatomic, assign) IBOutlet UIImageView *ivLogo;

@property (nonatomic, assign) IBOutlet UIView *viewMain;

@property (nonatomic, assign) IBOutlet UITextField *txtEmail;
@property (nonatomic, assign) IBOutlet UITextField *txtPassword;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.ivLogo.center = CGPointMake(self.view.frame.size.width / 2, self.viewMain.frame.origin.y / 2);
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeKeyboardFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) willShowKeyboard:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    [self showMainInfoViewWhenShowKeyboard:keyboardFrameBeginRect.size.height];
}

- (void) willChangeKeyboardFrame:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    [self showMainInfoViewWhenShowKeyboard:keyboardFrameBeginRect.size.height];
}

- (void) willHideKeyboard:(NSNotification *)notification
{
    [self hideMainInfo];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onForgotPassword:(id)sender
{
    
}

- (IBAction)onLogin:(id)sender
{
    [self closeKeyboard];
    
    [self signIn];
}

- (void) signIn
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"signin" forKey:@"service"];
    [request addPostValue:self.txtEmail.text forKey:@"email"];
    [request addPostValue:self.txtPassword.text forKey:@"password"];
    [request addPostValue:[AppDelegate getDelegate].str_devToken forKey:@"device_token"];
    [request setDelegate:self];
    [request setTimeOutSeconds:30];
    [request setDidFinishSelector:@selector(signIn_didSuccess:)];
    [request setDidFailSelector:@selector(signIn_didFail:)];
    [request startAsynchronous];
    
}

-(void) signIn_didSuccess:(ASIFormDataRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"No Internet Connection"];
    NSLog(@"Login Failed");
}

- (IBAction)onLoginWithFacebook:(id)sender
{
    
}

- (IBAction)onLoginWithInstagram:(id)sender
{
    
}

- (void) closeKeyboard
{
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

- (void) showMainInfoViewWhenShowKeyboard:(float)keyboardHeight
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.viewMain.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - (CGRectGetHeight(self.viewMain.frame) + keyboardHeight), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.viewMain.frame));
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) hideMainInfo
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.viewMain.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.viewMain.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.viewMain.frame));
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.txtEmail)
    {
        [self.txtPassword becomeFirstResponder];
    }
    else if(textField == self.txtPassword)
    {
        [self.txtPassword resignFirstResponder];
    }
    
    return YES;
}

@end
