//
//  SecretViewController.m
//  Pook

#import "SecretViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIFont+SecretFont.h"
#import "CommentCell.h"
#import "UIView+GradientMask.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "CommonMethods.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "CommentObject.h"

#import <QuartzCore/QuartzCore.h>

#define HEADER_HEIGHT 320.0f
#define HEADER_INIT_FRAME CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)
#define TOOLBAR_INIT_FRAME CGRectMake (0, 292, 320, 22)

const CGFloat kBarHeight = 50.0f;
const CGFloat kBackgroundParallexFactor = 0.5f;
const CGFloat kBlurFadeInFactor = 0.005f;
const CGFloat kTextFadeOutFactor = 0.05f;
const CGFloat kCommentCellHeight = 50.0f;

@interface SecretViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation SecretViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated{
    _mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), _commentsTableView.contentSize.height + CGRectGetHeight(_backgroundScrollView.frame));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden = YES;
    // Do any additional setup after loading the view from its nib.
    [self initControllers];
    [self InitGrowingTextView];
    typingflag = 0;
    [self initMembers];
}

- (void) initMembers
{
    arr_CommentsData = [[NSMutableArray alloc] init];
    last = 0.0;
    comment_Users = [[NSMutableArray alloc] init];
    likes_Users = [[NSMutableArray alloc] init];
}

-(void) initControllers
{
    _mainScrollView.bounces = YES;
    _mainScrollView.alwaysBounceVertical = YES;
    _mainScrollView.contentSize = CGSizeZero;
    _mainScrollView.showsVerticalScrollIndicator = YES;
    _mainScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(kBarHeight, 0, 0, 0);

    _backgroundScrollView.contentSize = CGSizeMake(320, 1000);
    
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Take a snapshot of the background scroll view and apply a blur to that image
    // Then add the blurred image on top of the regular image and slowly fade it in
    // in scrollViewDidScroll
    
//    UIGraphicsBeginImageContextWithOptions(_backgroundScrollView.bounds.size, _backgroundScrollView.opaque, 0.0);
//    [_backgroundScrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    _blurImageView.image = [img applyBlurWithRadius:12 tintColor:[UIColor colorWithWhite:0.8 alpha:0.4] saturationDeltaFactor:1.8 maskImage:nil];
    _blurImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _commentsTableView.scrollEnabled = NO;
    _commentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 276)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) copyBackgroundImage
{
    UIGraphicsBeginImageContextWithOptions(_backgroundScrollView.bounds.size, _backgroundScrollView.opaque, 0.0);
    [_backgroundScrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _blurImageView.image = [img applyBlurWithRadius:12 tintColor:[UIColor colorWithWhite:0.8 alpha:0.4] saturationDeltaFactor:1.8 maskImage:nil];
}

#pragma -mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat delta = 0.0f;
    CGRect rect = HEADER_INIT_FRAME;
    // Here is where I do the "Zooming" image and the quick fade out the text and toolbar
    if (scrollView.contentOffset.y < 0.0f)
    {
        delta = fabs(MIN(0.0f, _mainScrollView.contentOffset.y));
        _backgroundScrollView.frame = CGRectMake(CGRectGetMinX(rect) - delta / 2.0f, CGRectGetMinY(rect) - delta, CGRectGetWidth(rect) + delta, CGRectGetHeight(rect) + delta);
        [_commentsTableView setContentOffset:(CGPoint){0,0} animated:NO];
    }
    else
    {
        delta = _mainScrollView.contentOffset.y;
        _blurImageView.alpha = MIN(1 , delta * kBlurFadeInFactor);
        CGFloat backgroundScrollViewLimit = _backgroundScrollView.frame.size.height - kBarHeight;
        // Here I check whether or not the user has scrolled passed the limit where I want to stick the header, if they have then I move the frame with the scroll view
        // to give it the sticky header look
        if (delta > backgroundScrollViewLimit)
        {
            _backgroundScrollView.frame = (CGRect) {.origin = {0, delta - _backgroundScrollView.frame.size.height + kBarHeight}, .size = {self.view.frame.size.width, HEADER_HEIGHT}};
            _commentsViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(_backgroundScrollView.frame) + CGRectGetHeight(_backgroundScrollView.frame)}, .size = _commentsViewContainer.frame.size };
            _commentsTableView.contentOffset = CGPointMake (0, delta - backgroundScrollViewLimit);
            
            CGFloat contentOffsetY = -backgroundScrollViewLimit * kBackgroundParallexFactor;
            [_backgroundScrollView setContentOffset:(CGPoint){0,contentOffsetY} animated:NO];
        }
        else
        {
            if (typingflag==1)
            {
                [textView resignFirstResponder];
            }
            else
            {
                _backgroundScrollView.frame = rect;
                _commentsViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(rect) + CGRectGetHeight(rect)}, .size = _commentsViewContainer.frame.size };
                [_commentsTableView setContentOffset:(CGPoint){0,0} animated:NO];
                [_backgroundScrollView setContentOffset:CGPointMake(0, -delta * kBackgroundParallexFactor)animated:NO];
            }
        }
    }
//    NSLog(@"mainscrollview offset %f",scrollView.contentOffset.y);
//    NSLog(@"delta %f", delta);
//    NSLog(@"typing flag %i",typingflag);
    last = scrollView.contentOffset.y;
}

#pragma mark TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((arr_CommentsData != nil) && [arr_CommentsData count]>0) {
        return [arr_CommentsData count];
    }
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((arr_CommentsData != nil) && [arr_CommentsData count]>0)
    {
        CommentObject *comment = [arr_CommentsData objectAtIndex:indexPath.row];
        NSString *strContent = comment._commentText;
        CGSize sizeContent = [strContent sizeWithFont:[UIFont fontWithName:@"GothamNarrow-Light" size:18.0f] constrainedToSize:CGSizeMake(224.0f, 100.0f)];
        return sizeContent.height+30.0f;
    }
    
    else{
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifer = @"Cell";
    CommentCell *cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if ((arr_CommentsData != nil) && [arr_CommentsData count]>0)
    {
        CommentObject *comment = [arr_CommentsData objectAtIndex:indexPath.row];
        
        //Encode Text with Emoji
//        NSData *data = [comment._commentText dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *valueTextwithEmoji = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        NSString *strComment = [CommonMethods decodeUTF8:comment._commentText];
        
        cell._commentText.text = strComment;
        cell.lbl_Likescnt.text = [NSString stringWithFormat:@"%i likes", comment.likesCnt];
        cell.lbl_History.text = [CommonMethods getHowLongAgo:comment.old_date and:comment.cur_date];
        if (comment.likedFlag>0) {
            cell.btn_Like.selected = YES;
        }
        
        if ([AppDelegate getDelegate].notification_ownerid == comment.commentor_id) {
            cell._commentText.textColor = [UIColor colorWithRed:248/255.0f green:235/255.0f blue:133/255.0f alpha:1.0];
        }
        
        //
        int emo_index = (comment.post_id*comment.commentor_id)%137;
        UIImage *emoImg = [[UIImage alloc] init];
        
        //This is for setting comment about oneself's comment
//        if ([[AppDelegate getDelegate].curUser.userid intValue] == comment.commentor_id) {
//            emoImg = [UIImage imageNamed:@"king.png"];
//            cell._commentText.textColor = [UIColor colorWithRed:255/255.0f green:242/255.0f blue:136/255.0f alpha:1.0f];
//        }
//        else{
            emoImg = [UIImage imageNamed:[NSString stringWithFormat:@"persons-%i_medium.png", emo_index]];
//        }
        
        //Adjusting Emoticion Size preventing from stretch
        float ratio = emoImg.size.height/emoImg.size.width;
        if (emoImg.size.height>emoImg.size.width) {
            cell._imgEmoticon.frame = CGRectMake(0, 0, 35/ratio, 35);
        }
        else{
            cell._imgEmoticon.frame = CGRectMake(0, 0, 35, 35*ratio);
        }
        
        cell._imgEmoticon.center = CGPointMake(27, 30);
        cell._imgEmoticon.image = emoImg;
        
        //Adjust Cell Height accroding to Comment Length
        CGSize sizeContent = [comment._commentText sizeWithFont:[UIFont fontWithName:@"GothamNarrow-Light" size:18.0f] constrainedToSize:CGSizeMake(224.0f, 100.f)];
        cell._commentText.frame = CGRectMake(cell._commentText.frame.origin.x, cell._commentText.frame.origin.y, sizeContent.width, sizeContent.height);
        cell.lbl_History.frame = CGRectMake(cell.lbl_History.frame.origin.x, 8+sizeContent.height+2, cell.lbl_History.frame.size.width, cell.lbl_History.frame.size.height);
        cell.lbl_Likescnt.frame = CGRectMake(cell.lbl_Likescnt.frame.origin.x, 8+sizeContent.height+4, cell.lbl_Likescnt.frame.size.width, cell.lbl_Likescnt.frame.size.height);
        cell.likeIcon.frame = CGRectMake(cell.likeIcon.frame.origin.x, 8+sizeContent.height+9, cell.likeIcon.frame.size.width, cell.likeIcon.frame.size.height);
    }
    
    cell.tag = indexPath.row;
    cell.delegate = self;
    return cell;
}

#pragma mark HPGrowingTextView Delegate

- (void) InitGrowingTextView
{
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(8, 5.5, 243, 33)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 3;
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont fontWithName:@"GothamNarrow-Light" size:17.0f];
    textView.tintColor = [UIColor whiteColor];
    textView.placeholder = @"Add a comment...";

    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [_typingView addSubview:textView];
    
    _typingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
    CGRect containerFrame = _typingView.frame;
    containerFrame.origin.y = 568 - keyboardBounds.size.height - containerFrame.size.height;

	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	_typingView.frame = containerFrame;
	
	// commit animations
    _backgroundScrollView.contentOffset = CGPointMake(0, -135);
    _commentsTableView.contentOffset = CGPointMake(0, 0);
    _mainScrollView.contentOffset = CGPointMake(0, 272);
    
	[UIView commitAnimations];
    typingflag =1;
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
    CGRect containerFrame = _typingView.frame;
    containerFrame.origin.y = 568- containerFrame.size.height;
    //	tbl_Comment.frame = CGRectMake(0, tbl_Comment.frame.origin.y, tbl_Comment.frame.size.width, 506-containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	_typingView.frame = containerFrame;
	
	// commit animations
    _backgroundScrollView.contentOffset = CGPointMake(0, 0);
    _commentsTableView.contentOffset = CGPointMake(0, 0);
    _mainScrollView.contentOffset = CGPointMake(0, 0);
    _commentsViewContainer.frame = CGRectMake(0, 320, 320,518 );
    
	[UIView commitAnimations];
    typingflag = 0;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = _typingView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	_typingView.frame = r;
}

- (IBAction)onExit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma -mark -

-(void) getPost:(int)postid
{
    cur_postid = postid;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    request.index = postid;
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"getafeed" forKey:@"service"];
    [request addPostValue:[NSString stringWithFormat:@"%i",postid] forKey:@"postid"];
    [request setDelegate:self];
    [request setTimeOutSeconds:30];
    [request setDidFinishSelector:@selector(getPost_didSuccess:)];
    [request setDidFailSelector:@selector(getPost_didFail:)];
    [request startAsynchronous];
}

-(void) getPost_didSuccess:(ASIFormDataRequest*)request
{
    if (request.responseStatusCode == 200)
    {
        NSLog(@"GetPost Status = %@", request.responseString);
        SBJSON *json = [SBJSON new];
        NSDictionary *dict = [[json objectWithString:request.responseString error:nil] objectForKey:@"post"];
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",DirectoryURL,[dict objectForKey:@"image_url"]];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        [self copyBackgroundImage];
        [self getComments:request.index];
    }
    else
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Can't access Server"];
    }
}

- (void) getPost_didFail:(ASIFormDataRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"No Internet Connection"];
}

-(void) getComments:(int)postid
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
    [request setRequestMethod:@"POST"];
    [request addPostValue:@"loadcomments" forKey:@"service"];
    [request addPostValue:[AppDelegate getDelegate].curUser.userid forKey:@"userid"];
    [request addPostValue:[NSString stringWithFormat:@"%i",postid] forKey:@"postid"];
    [request setDelegate:self];
    [request setTimeOutSeconds:30];
    [request setDidFinishSelector:@selector(getComments_didSuccess:)];
    [request startAsynchronous];
}

-(void) getComments_didSuccess:(ASIFormDataRequest*)request
{
    [arr_CommentsData removeAllObjects];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (request.responseStatusCode==200)
    {
        NSLog(@"getcomments status = %@", request.responseString);
        SBJSON *json = [SBJSON new];
        NSDictionary *dict = [json objectWithString:request.responseString error:nil];
        NSArray *arrTemp = [dict objectForKey:@"comments"];
        [comment_Users removeAllObjects];
        [likes_Users removeAllObjects];
        if ([arrTemp count]>0) {
            for (int i=[arrTemp count]-1; i>=0; i--)
            {
                CommentObject *comment = [[CommentObject alloc] initWithDict:[arrTemp objectAtIndex:i]];
                [arr_CommentsData addObject:comment];
            }
            for (int i=0; i<[arrTemp count]; i++) {
                NSDictionary *dict_comment = [arrTemp objectAtIndex:i];
                [comment_Users addObject:[dict_comment objectForKey:@"device_token"]];
            }
        }
        
        NSArray *arr_likes = [dict objectForKey:@"likes"];
        if ([arr_likes count]>0)
        {
            for (int i=0; i<[arr_likes count]; i++)
            {
                NSDictionary *dict_like = [arr_likes objectAtIndex:i];
                [likes_Users addObject:[dict_like objectForKey:@"device_token"]];
            }
        }
        
        [_commentsTableView reloadData];
        _mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), _commentsTableView.contentSize.height + CGRectGetHeight(_backgroundScrollView.frame));
    }
}

#pragma -mark LikeComments
- (void) LikeComment:(int)index
{
    NSLog(@"I like Comment %i", index);
    CommentObject *comment = [arr_CommentsData objectAtIndex:index];
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
        CommentObject *comment = [arr_CommentsData objectAtIndex:request.index];
        comment.likedFlag = 1;
        comment.likesCnt = comment.likesCnt+1;
        CommentCell *cell = (CommentCell*)[_commentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:request.index inSection:0]];
        
        SBJSON *json = [SBJSON new];
        NSDictionary *dict = [json objectWithString:request.responseString error:nil];
        if ([[dict objectForKey:@"message"] isEqualToString:@"success"])
        {
            if (cell) {
                cell.btn_Like.selected = YES;
                cell.lbl_Likescnt.text = [NSString stringWithFormat:@"%i likes" ,[cell.lbl_Likescnt.text intValue]+1];
            }
        }
        else
        {
            if (cell) {
                cell.btn_Like.selected = NO;
                cell.lbl_Likescnt.text = [NSString stringWithFormat:@"%i likes", [cell.lbl_Likescnt.text intValue]-1];
            }
        }
        
    }
    else{
        [CommonMethods showAlertUsingTitle:@"Wasted Selfie" andMessage:@"Can't access Server"];
    }
}

#pragma -mark SendComments

- (IBAction)onSendComment:(id)sender
{
//    NSData *data = [textView.text dataUsingEncoding:NSNonLossyASCIIStringEncoding];
//    NSString *valueUnicode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *strComment = [CommonMethods encodeUTF8:textView.text];
    
    if (![textView.text isEqualToString:@""]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ServerURL]];
        [request setRequestMethod:@"POST"];
        [request addPostValue:@"commentonpost" forKey:@"service"];
        [request addPostValue:[NSString stringWithFormat:@"%i", cur_postid] forKey:@"postid"];
        [request addPostValue:[AppDelegate getDelegate].curUser.userid forKey:@"commentorid"];
        [request addPostValue:strComment forKey:@"comment"];
        [request setDelegate:self];
        [request setTimeOutSeconds:30];
        [request setDidFinishSelector:@selector(SendComments_didSuccess:)];
        [request startAsynchronous];
    }
}

-(void) SendComments_didSuccess:(ASIFormDataRequest*)request
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (request.responseStatusCode == 200)
    {
        NSLog(@"Comment Status = %@", request.responseString);
        [self getComments:cur_postid];
        textView.text = @"";
        
        for (int i = 0; i<[comment_Users count]; i++)
        {
            if ([likes_Users containsObject:[comment_Users objectAtIndex:i]])
            {
                [comment_Users removeObjectAtIndex:i];
                i = i-1;
            }
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        
        // set views with new info
        // commit animations
        _backgroundScrollView.contentOffset = CGPointMake(0, 0);
        _commentsTableView.contentOffset = CGPointMake(0, 0);
        _mainScrollView.contentOffset = CGPointMake(0, 0);
        _commentsViewContainer.frame = CGRectMake(0, 320, 320,518 );
        
        [UIView commitAnimations];
    }
    
}

@end
