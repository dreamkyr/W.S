//
//  AddCommentViewController.m
//  Pook
//
//  Created by han on 1/16/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import "AddCommentViewController.h"

#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "Constant.h"
#import "CommonMethods.h"
#import "CommentObject.h"

#import "AppDelegate.h"

#import "UIImageView+WebCache.h"

@interface AddCommentViewController ()

@property (nonatomic, assign) IBOutlet UIImageView *ivImage;

@property (nonatomic, assign) IBOutlet UITextView *txtComment;

@end

@implementation AddCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.txtComment.font = [UIFont fontWithName:@"Open Sans" size:16.0f];
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
    
    NSString *imgUrl = [[NSString alloc] init];
    imgUrl = [NSString stringWithFormat:@"%@%@", DirectoryURL, self.feed.image_url];
    [self.ivImage sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender
{
    if(self.txtComment.text.length == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please add something for comment." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        alertView = nil;
        
        return;
    }
    
    [self onSendComments];
}

- (void)onSendComments
{
    NSData *data = [self.txtComment.text dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *valueUnicode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (![self.txtComment.text isEqualToString:@""]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
        [request setRequestMethod:@"POST"];
        [request addPostValue:@"commentonpost" forKey:@"service"];
        [request addPostValue:[NSString stringWithFormat:@"%i", self.feed.postid] forKey:@"postid"];
        [request addPostValue:[AppDelegate getDelegate].curUser.userid forKey:@"commentorid"];
        [request addPostValue:valueUnicode forKey:@"comment"];
        [request setDelegate:self];
        [request setTimeOutSeconds:30];
        [request setDidFinishSelector:@selector(SendComments_didSuccess:)];
        [request startAsynchronous];
    }
}

-(void) SendComments_didSuccess:(ASIFormDataRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (request.responseStatusCode == 200) {
        NSLog(@"Comment Status = %@", request.responseString);
        
        self.txtComment.text = @"";
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        app.isUpdatedFeeds = YES;
        
        [self onBack:nil];
    }
}

#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"Write something here..."])
    {
        textView.text = @"";
    }
    
    return YES;
}

@end
