//
//  SignUpViewController.m
//  Pook
//
//  Created by han on 1/13/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import "SignUpViewController.h"

#import "MainViewController.h"

#import "AppDelegate.h"

#import "CommonMethods.h"
#import <AddressBook/AddressBook.h>
#import "Constant.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "MBProgressHUD.h"

@interface SignUpViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) IBOutlet UIView *viewProfileImage;
@property (nonatomic, assign) IBOutlet UIView *viewMainInfo;
@property (nonatomic, assign) IBOutlet UIView *viewTerms;

@property (nonatomic, assign) IBOutlet UITextField *txtUsername;
@property (nonatomic, assign) IBOutlet UITextField *txtEmail;
@property (nonatomic, assign) IBOutlet UITextField *txtPassword;

@property (nonatomic, assign) IBOutlet UIImageView *ivProfileImage;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.ivProfileImage.layer.cornerRadius = self.ivProfileImage.frame.size.width / 2;
    self.ivProfileImage.clipsToBounds = YES;
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
    
    self.viewTerms.frame = CGRectMake(self.viewTerms.frame.origin.x, self.view.frame.size.height, self.viewTerms.frame.size.width, self.viewTerms.frame.size.height);
    
    self.viewProfileImage.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, self.viewMainInfo.frame.origin.y / 2);
    
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

- (IBAction)onAcceptTerms:(id)sender
{
    MainViewController *controller = [[MainViewController alloc] init];
    
    [self.navigationController pushViewController:controller animated:YES];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"\"Pook\" Would Like to Access Your Contacts"
//                                                    message:@"Your Contacts will be uploaded to Pook to connect you with friends. We'll never spam them and your identity will remain anonymous."
//                                                   delegate:self
//                                          cancelButtonTitle:@"Skip"
//                                          otherButtonTitles:@"OK", nil];
//    alert.tag = 1;
//    [alert show];
}

- (IBAction)onDisagree:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onPickImage:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a profile photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Library", @"Camera", nil];
    
    actionSheet.tag = 0;
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

- (IBAction)onSignUp:(id)sender
{
    NSArray *arrTextfield = [NSArray arrayWithObjects:self.txtEmail,self.txtPassword, nil];
    NSArray *arrTitle = [NSArray arrayWithObjects:@"Email",@"Password", nil];
    if ([CommonMethods checkBlankField:arrTextfield titles:arrTitle] == NO) {
        return;
    }
    
    if (![CommonMethods checkEmail:self.txtEmail]) {
        return;
    }
    
    else if ([self.txtUsername.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please input your user name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        alert = nil;
        
        return;
    }
    
    [self signUp];
}

- (void) signUp
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"signup" forKey:@"service"];
    [request addPostValue:self.txtEmail.text forKey:@"email"];
    [request addPostValue:self.txtUsername.text forKey:@"username"];
    [request addPostValue:self.txtPassword.text forKey:@"password"];
    [request addPostValue:[AppDelegate getDelegate].str_devToken forKey:@"device_token"];
    
    UIImage *profileImage = self.ivProfileImage.image;
    if(profileImage != nil)
    {
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 1.0f);
        if(imageData)
        {
            [request addData:imageData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"profile"];
        }
    }

    [request setDelegate:self];
    [request setTimeOutSeconds:30];
    [request setDidFinishSelector:@selector(signUp_didSuccess:)];
    [request setDidFailSelector:@selector(signUp_didFail:)];
    [request startAsynchronous];
}

-(void) signUp_didSuccess:(ASIFormDataRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (request.responseStatusCode == 200)
    {
        NSLog(@"SignupStatus Code = %@", request.responseString);
        SBJSON *json = [SBJSON new];
        NSDictionary *dict = [json objectWithString:request.responseString error:nil];
        int statuscode = [[dict objectForKey:@"status_code"] intValue];
        
        if (statuscode == 1)//Success
        {
            NSDictionary *user = [dict objectForKey:@"user"];
            
            NSString *userid = [NSString stringWithFormat:@"%@", [user objectForKey:@"id"]];
            NSString *username = [user objectForKey:@"username"];
            NSString *email = [user objectForKey:@"email"];
            NSString *profile = [user objectForKey:@"profile"];
            
            
            [[NSUserDefaults standardUserDefaults] setValue:userid forKey:@"UserID"];
            [[NSUserDefaults standardUserDefaults] setValue:email forKey:@"Email"];
            [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setValue:profile forKey:@"profile"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [AppDelegate getDelegate].curUser.userid = userid;
            
            //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //[self addPhoneContacts:userid];
            
            [self closeKeyboard];
            
            [UIView animateWithDuration:0.2 animations:^{
                self.viewTerms.frame = CGRectMake(0, 0, self.viewTerms.frame.size.width, self.viewTerms.frame.size.height);
            }];
        }
        else if (statuscode == 2)//Error
        {
            [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Internet Connection Error!"];
        }
        else if (statuscode == 3)//Email duplicate
        {
            [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"This Email is already registed!"];
        }
        else if (statuscode == 4)//Phone duplicate
        {
            [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"This Phone Number is already registered"];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wasted Selfie" message:@"InternetConnection Lost!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void) signUp_didFail:(ASIFormDataRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"No Internet Connection"];
    
    NSLog(@"SignUp Failed");
}

-(void) addPhoneContacts:(NSString*)userid
{
    NSString *strphonecontacts = [[NSString alloc] init];
    strphonecontacts = [CommonMethods getAllContacts];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"addphonecontacts" forKey:@"service"];
    [request addPostValue:userid forKey:@"userid"];
    [request addPostValue:strphonecontacts forKey:@"contacts"];
    [request setDelegate:self];
    [request setTimeOutSeconds:30];
    [request startAsynchronous];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void) addPhoneContacts_didSuccess:(ASIFormDataRequest*)request
{
    NSLog(@"Add Contact Status = %@", request.responseString);
}

- (void) closeKeyboard
{
    [self.txtEmail resignFirstResponder];
    [self.txtUsername resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

- (void) showMainInfoViewWhenShowKeyboard:(float)keyboardHeight
{
    [UIView animateWithDuration:0.3f animations:^{
        
        BOOL isIphone4 = self.view.frame.size.height == 480;
        
        self.viewMainInfo.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - (CGRectGetHeight(self.viewMainInfo.frame) + keyboardHeight) + (isIphone4 ? 62 : 0), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.viewMainInfo.frame));
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) hideMainInfo
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.viewMainInfo.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.viewMainInfo.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.viewMainInfo.frame));
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.txtUsername)
    {
        [self.txtEmail becomeFirstResponder];
    }
    else if(textField == self.txtEmail)
    {
        [self.txtPassword becomeFirstResponder];
    }
    else if(textField == self.txtPassword)
    {
        [self.txtPassword resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.txtUsername)
    {
        if([self.txtUsername.text isEqualToString:@"User Name"])
        {
            self.txtUsername.text = @"";
        }
    }
    else if(textField == self.txtEmail)
    {
        if([self.txtEmail.text isEqualToString:@"Email Address"])
        {
            self.txtEmail.text = @"";
        }
    }
    else if(textField == self.txtPassword)
    {
        if([self.txtPassword.text isEqualToString:@"Choose a Password"])
        {
            self.txtPassword.secureTextEntry = YES;
            self.txtPassword.text = @"";
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField == self.txtUsername)
    {
        if(self.txtUsername.text.length == 0)
        {
            self.txtUsername.text = @"User Name";
        }
    }
    else if(textField == self.txtEmail)
    {
        if(self.txtEmail.text.length == 0)
        {
            self.txtEmail.text = @"Email Address";
        }
    }
    else if(textField == self.txtPassword)
    {
        if(self.txtPassword.text.length == 0)
        {
            self.txtPassword.secureTextEntry = NO;
            self.txtPassword.text = @"Choose a Password";
        }
    }
    
    return YES;
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        MainViewController *controller = [[MainViewController alloc] init];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if(alertView.tag == 0)
    {
        if (buttonIndex == 0) {
            NSLog(@"Skip PhoneNumber");
            [self signUp];
        }
        else{
        }
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 0)
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

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    self.ivProfileImage.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
