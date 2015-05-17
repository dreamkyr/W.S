//
//  CommentCell.m
//  Pook

#import "CommentCell.h"

@implementation CommentCell
@synthesize delegate;

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onLikeComment:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(LikeComment:)]) {
        [self.delegate LikeComment:self.tag];
    }
}

- (void) updateLayout
{
    self.viewMain.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end
