//
//  CommentCell.h
//  Pook

#import <UIKit/UIKit.h>
@protocol CommentCellDelegate <NSObject>

@optional
- (void) LikeComment:(int)index;

@end

@interface CommentCell : UITableViewCell

@property (nonatomic, retain) id                    delegate;

@property (weak, nonatomic) IBOutlet UIImageView *_imgEmoticon;
@property (weak, nonatomic) IBOutlet UILabel *_usernameText;

@property (weak, nonatomic) IBOutlet UILabel *_commentText;
@property (weak, nonatomic) IBOutlet UIButton *btn_Like;
@property (weak, nonatomic) IBOutlet UILabel *lbl_History;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Likescnt;
@property (weak, nonatomic) IBOutlet UIImageView *likeIcon;

@property (nonatomic, assign) IBOutlet UIView *viewMain;

- (void) updateLayout;

@end
