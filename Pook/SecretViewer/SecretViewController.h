//
//  SecretViewController.h
//  Pook

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@interface SecretViewController : UIViewController<HPGrowingTextViewDelegate>
{
    IBOutlet UIScrollView *_mainScrollView;
    IBOutlet UIScrollView *_backgroundScrollView;
    IBOutlet UIImageView *imageView;
    IBOutlet UIImageView *_blurImageView;
    IBOutlet UIView *_commentsViewContainer;
    IBOutlet UITableView *_commentsTableView;
    IBOutlet UIView *_typingView;
    HPGrowingTextView *textView;
    int typingflag;
    NSMutableArray *arr_CommentsData;
    float last ;
    
    int cur_postid;
    NSMutableArray *comment_Users;
    NSMutableArray *likes_Users;
}

-(void) getPost:(int)postid;

@property (strong, nonatomic) NSData *postImage;

@end
