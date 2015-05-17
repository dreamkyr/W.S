//
//  CommentViewController.m
//  Pook
//
//  Created by iDev on 7/9/14.
//  Copyright (c) 2014 iWorld. All rights reserved.
//

#import "CommentViewController.h"

#import "AddCommentViewController.h"

#import "CommentCell.h"

#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "Constant.h"
#import "CommonMethods.h"
#import "CommentObject.h"

#import "AppDelegate.h"


@interface CommentViewController ()

@property (nonatomic, assign) IBOutlet UIView *viewMain;

@property (nonatomic, assign) IBOutlet UITextField *txtComment;

@property (nonatomic, assign) IBOutlet UITableView *tvComments;

@property (nonatomic, retain) NSMutableArray *aryComments;

@end

@implementation CommentViewController

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
    
    [self initWithMembers];
}

-(void) initWithMembers
{
    self.aryComments = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadAllComments];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAddComment:(id)sender
{
    AddCommentViewController *vc = [[AddCommentViewController alloc] initWithNibName:@"AddCommentViewController" bundle:nil];
    vc.feed = self.feed;
    
    [self.navigationController pushViewController:vc animated:YES];
    vc = nil;
}

#pragma -mark TeamSearchTable Delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.aryComments.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    CommentObject *comment = [self.aryComments objectAtIndex:indexPath.row];
    NSString *strContent = comment._commentText;
    
    float commentWidth = self.tvComments.frame.size.width - 100;
    
    CGSize sizeContent = [strContent sizeWithFont:[UIFont fontWithName:@"Open Sans" size:14.0f] constrainedToSize:CGSizeMake(commentWidth, 100.0f)];
    
    return sizeContent.height + 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifer = @"Cell";
    CommentCell *cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if ((self.aryComments != nil) && [self.aryComments count]>0)
    {
        CommentObject *comment = [self.aryComments objectAtIndex:indexPath.row];
        
        //Encode Text With Emoji
        NSData *data = [comment._commentText dataUsingEncoding:NSUTF8StringEncoding];
        NSString *valueTextwithEmoji = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        cell._commentText.text = valueTextwithEmoji;
        cell.lbl_Likescnt.text = [NSString stringWithFormat:@"%i likes", comment.likesCnt];
        cell.lbl_History.text = [CommonMethods getHowLongAgo:comment.old_date and:comment.cur_date];
        if (comment.likedFlag>0) {
            cell.btn_Like.selected = YES;
        }
        
//        //
//        int emo_index = (comment.post_id*comment.commentor_id) % 136;
//        UIImage *emoImg = [[UIImage alloc] init];
//        emoImg = [UIImage imageNamed:[NSString stringWithFormat:@"persons-%i_medium.png", emo_index]];
//        
//        //Adjust Emoticon and Size
//        float ratio = emoImg.size.height / emoImg.size.width;
//        if (emoImg.size.height>emoImg.size.width) {
//            cell._imgEmoticon.frame = CGRectMake(0, 0, 35/ratio, 35);
//        }
//        else{
//            cell._imgEmoticon.frame = CGRectMake(0, 0, 35, 35 * ratio);
//        }
//        
//        cell._imgEmoticon.center = CGPointMake(27, 30);
//        cell._imgEmoticon.image = emoImg;
        
        if(comment.profile.length > 0)
        {
            NSString * profileimgUrl = [NSString stringWithFormat:@"%@%@", DirectoryURL, comment.profile];
            [cell._imgEmoticon sd_setImageWithURL:[NSURL URLWithString:profileimgUrl] placeholderImage:[UIImage imageNamed:@"avatar"]];
        }
        else
        {
            cell._imgEmoticon.image = [UIImage imageNamed:@"avatar"];
        }
        cell._imgEmoticon.layer.cornerRadius = cell._imgEmoticon.frame.size.width / 2;
        cell._imgEmoticon.clipsToBounds = YES;
        
        cell._usernameText.text = comment.username;
        
        float commentWidth = self.tvComments.frame.size.width - 100;
        
        //Adjust Cell Height accroding to Comment Length
        CGSize sizeContent = [comment._commentText sizeWithFont:[UIFont fontWithName:@"Open sans" size:14.0f]constrainedToSize:CGSizeMake(commentWidth, 100.f)];
        
        cell._commentText.frame = CGRectMake(cell._commentText.frame.origin.x, cell._commentText.frame.origin.y, commentWidth, sizeContent.height);
        
        float posY = cell._commentText.frame.origin.y + sizeContent.height + 10;
        
        cell.lbl_History.center = CGPointMake(cell.lbl_History.center.x, posY);
        cell.lbl_Likescnt.center = CGPointMake(cell.lbl_Likescnt.center.x, posY);
        cell.likeIcon.center = CGPointMake(cell.likeIcon.center.x, posY);
        NSLog(@"History Widt %f, LikeCnt %f, LikeIcon %f", cell.lbl_History.frame.size.width, cell.lbl_Likescnt.frame.origin.x, cell.likeIcon.frame.origin.x);
    }
    
    cell.tag = indexPath.row;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [((CommentCell *)cell) updateLayout];
}

- (IBAction)onSendComments:(id)sender
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

        [self loadAllComments];
        self.txtComment.text = @"";
    }
}

-(void) loadAllComments
{
    [self.aryComments removeAllObjects];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"loadcomments" forKey:@"service"];
    [request addPostValue:[AppDelegate getDelegate].curUser.userid forKey:@"userid"];
    [request addPostValue:[NSString stringWithFormat:@"%i", self.feed.postid] forKey:@"postid"];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(loadAllComments_didSuccess:)];
    [request startAsynchronous];
}

-(void) loadAllComments_didSuccess:(ASIFormDataRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SBJSON *json = [SBJSON new];
    NSDictionary *dict = [json objectWithString:request.responseString error:nil];
    if (request.responseStatusCode == 200) {
        NSLog(@"LoadComment Stauts = %@", request.responseString);
        NSArray *aryComments = [dict objectForKey:@"comments"];
        if ([aryComments count]>0) {
            for (int i= (int)aryComments.count - 1 ; i>=0 ; i--)
            {
                CommentObject *comment = [[CommentObject alloc] initWithDict:[aryComments objectAtIndex:i]];
                [self.aryComments addObject:comment];
            }
        }
        [self.tvComments reloadData];
    }
    else{
        [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Can't access Server"];
    }
}

- (void) LikeComment:(int)index
{
    NSLog(@"I like Comment %i", index);
    CommentObject *comment = [self.aryComments objectAtIndex:index];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    request.index = index;
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"likecomment" forKey:@"service"];
    [request addPostValue:[NSString stringWithFormat:@"%i", comment.comment_id] forKey:@"commentid"];
    [request addPostValue:[AppDelegate getDelegate].curUser.userid forKey:@"userid"];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(LikeComment_didSuccess:)];
    [request startAsynchronous];
}

-(void) LikeComment_didSuccess:(ASIFormDataRequest*)request
{
    if (request.responseStatusCode == 200)
    {
        NSLog(@"Like Comment Status = %@", request.responseString);
        CommentObject *comment = [self.aryComments objectAtIndex:request.index];
        comment.likedFlag = 1;
        comment.likesCnt = comment.likesCnt+1;
        CommentCell *cell = (CommentCell*)[self.tvComments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:request.index inSection:0]];
        
        SBJSON *json = [SBJSON new];
        NSDictionary *dict = [json objectWithString:request.responseString error:nil];
        if ([[dict objectForKey:@"message"] isEqualToString:@"success"])
        {
            if (cell) {
                cell.btn_Like.selected = YES;
                cell.lbl_Likescnt.text = [NSString stringWithFormat:@"%i likes",[cell.lbl_Likescnt.text intValue]+1];
            }
        }
        else
        {
            if (cell) {
                cell.btn_Like.selected = NO;
                cell.lbl_Likescnt.text = [NSString stringWithFormat:@"%i likes",[cell.lbl_Likescnt.text intValue]-1];
            }
        }
        
    }
    else{
        [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Can't access Server"];
    }
}

@end
