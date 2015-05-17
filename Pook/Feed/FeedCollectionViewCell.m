//
//  FeedCollectionViewCell.m
//  Pook
//
//  Created by han on 1/15/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import "FeedCollectionViewCell.h"

#import "UIImageView+WebCache.h"

#import "CommonMethods.h"
#import "Constant.h"

#define ICON_GAP 20

#define POST_TEXT_FONT  10

#define GAP_MAIN        15
#define GAP_OF_LABEL    5

#define HEIGHT_TOP    30
#define HEIGHT_BOTTOM    30

#define LOCATION_WIDTH 100

#define COMMENT_MARGIN 20

@interface FeedCollectionViewCell()

@property (nonatomic, assign) IBOutlet UIView *viewMain;

@property (nonatomic, assign) IBOutlet UIImageView *ivPost;

@property (nonatomic, assign) IBOutlet UIImageView *ivProfile;

@property (nonatomic, assign) IBOutlet UIView *viewTop;
@property (nonatomic, assign) IBOutlet UILabel *lblName;
@property (nonatomic, assign) IBOutlet UILabel *lblTime;

@property (nonatomic, assign) IBOutlet UIImageView *ivIcon;

@property (nonatomic, assign) IBOutlet UIImageView *ivLocationIcon;
@property (nonatomic, assign) IBOutlet UILabel *lblLocation;


@property (nonatomic, assign) IBOutlet UILabel *lblDescription;

@property (nonatomic, assign) IBOutlet UIButton *btnComment;
@property (nonatomic, assign) IBOutlet UILabel *lblComment;

@property (nonatomic, assign) IBOutlet UIView *viewLoveCount;
@property (nonatomic, assign) IBOutlet UILabel *lblLoveCount;

@end

@implementation FeedCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    UITapGestureRecognizer *likeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeImage)];
    likeTap.numberOfTapsRequired = 2;
    
    [self.viewMain addGestureRecognizer:likeTap];
}

- (void) likeImage
{
    [self onLike:nil];
    
    UIImage *image = [UIImage imageNamed:@"rate_icon_heart"];
    NSInteger imageWidth = CGImageGetWidth([image CGImage]);
    __block float aspectRatio = (float)self.viewMain.frame.size.width / (float)imageWidth;
    __block UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    BOOL hasMarked = YES;
    if (hasMarked)
        imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    else
        imageView.transform = CGAffineTransformMakeScale(aspectRatio / 2, aspectRatio / 2);
    
    [self.viewMain addSubview:imageView];
    [self.viewMain bringSubviewToFront:imageView];
    imageView.center = CGPointMake(self.viewMain.frame.size.width / 2, self.viewMain.frame.size.height / 2);
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (hasMarked)
            imageView.transform = CGAffineTransformMakeScale(aspectRatio / 2, aspectRatio / 2);
        else
            imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            imageView.alpha = 0.0f;
        } completion:^(BOOL finished){
            [imageView removeFromSuperview];
            imageView = nil;
        }];
        
    }];
}

- (void) setPostInfo:(PookFeed *)post index:(NSInteger)index
{
    self.index = index;
    self.feed = post;
    
    float cellWidth = CGRectGetWidth(self.frame);
    float cellHeight = [FeedCollectionViewCell getPostCellHeight:post width:cellWidth];
    
    float mainWidth = cellWidth - GAP_MAIN * 2;
    float contentWidth = mainWidth - GAP_MAIN * 2;
    
    float pos = GAP_OF_LABEL;
    self.viewMain.frame = CGRectMake(GAP_MAIN, 0, mainWidth, cellHeight);
    self.viewMain.clipsToBounds = YES;
    
    //-------- top view -------------
    
    self.viewTop.frame = CGRectMake(GAP_MAIN, pos, contentWidth, HEIGHT_TOP);
    
    self.ivProfile.layer.cornerRadius = CGRectGetHeight(self.ivProfile.frame) / 2;
    self.ivProfile.clipsToBounds = YES;
    
    if(post.profile.length > 0)
    {
        NSString * profileimgUrl = [NSString stringWithFormat:@"%@%@", DirectoryURL, post.profile];
        [self.ivProfile sd_setImageWithURL:[NSURL URLWithString:profileimgUrl] placeholderImage:[UIImage imageNamed:@"avatar"]];
    }
    else
    {
        self.ivProfile.image = [UIImage imageNamed:@"avatar"];
    }
    
    self.lblName.text = post.username;
    
    NSString *location = [CommonMethods decodeUTF8:post.location];
    
    if(location == nil || location.length == 0)
    {
        self.lblLocation.text = @"None";
    }
    else
    {
        self.lblLocation.text = location;
    }
    
    self.lblLocation.numberOfLines = 1;
    [self.lblLocation sizeToFit];
    
    if(self.lblLocation.frame.size.width > LOCATION_WIDTH)
    {
        self.lblLocation.frame = CGRectMake(contentWidth - LOCATION_WIDTH, 0, LOCATION_WIDTH, CGRectGetHeight(self.viewTop.frame));
        self.lblLocation.numberOfLines = 2;
        
        self.lblLocation.text = location;
        [self.lblLocation sizeToFit];
    }
    else
    {
        self.lblLocation.frame = CGRectMake(contentWidth - self.lblLocation.frame.size.width, 0, self.lblLocation.frame.size.width, CGRectGetHeight(self.viewTop.frame));
    }
    
    self.ivLocationIcon.center = CGPointMake(self.lblLocation.frame.origin.x - self.ivLocationIcon.frame.size.width / 2, self.lblLocation.center.y);

    
    NSString *createdDate = post.createdDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:createdDate];
    
    if(date !=  nil)
    {
        self.lblTime.text = [NSString stringWithFormat:@"%@ ago", [self getTimeIntervalString:date]];
        [self.lblTime sizeToFit];
        
        self.lblTime.center = CGPointMake(self.ivLocationIcon.center.x - self.lblTime.frame.size.width / 2 - 20 , self.ivLocationIcon.center.y);
        
        self.ivIcon.hidden = NO;
        self.ivIcon.center = CGPointMake(self.lblTime.frame.origin.x - self.ivIcon.frame.size.width / 2 - 2, self.lblTime.center.y);
    }
    else
    {
        self.lblTime.text = @"";
        self.ivIcon.hidden = YES;
    }
    
    pos += HEIGHT_TOP;
    
    //---------- post image ---------------
    
    self.ivPost.frame = CGRectMake(GAP_MAIN, pos, contentWidth, contentWidth);
    
    NSString *imgUrl = [[NSString alloc] init];
    imgUrl = [NSString stringWithFormat:@"%@%@", DirectoryURL, post.image_url];
    
    NSLog(@"%@", imgUrl);
    
    
    [self.ivPost sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    
    pos += (contentWidth + GAP_OF_LABEL);
    
    //---------- description ---------------
    
    NSString *description = [CommonMethods decodeUTF8:post.desc_text];
    
    float heightOfDescription = 0;
    if(description.length > 0)
    {
        heightOfDescription = [FeedCollectionViewCell getLabelHeightWithString:description width:(contentWidth - LOCATION_WIDTH)];
    }
    
    self.lblDescription.frame = CGRectMake(GAP_MAIN, pos, contentWidth - LOCATION_WIDTH, heightOfDescription);
    self.lblDescription.text = description;
    
    pos += heightOfDescription + GAP_OF_LABEL;
    
    //---------- description ---------------
    
    NSString *comment = post.lastcomment;
    
    if(comment.length == 0) comment = @"None";
    
    float heightOfComment = [FeedCollectionViewCell getLabelHeightWithString:comment width:(contentWidth - COMMENT_MARGIN)];
    
    self.btnComment.frame = CGRectMake(GAP_MAIN, pos, self.btnComment.frame.size.width, self.btnComment.frame.size.height);
    self.lblComment.frame = CGRectMake(GAP_MAIN + COMMENT_MARGIN, pos + 2, contentWidth - COMMENT_MARGIN, heightOfComment);
    self.lblComment.text = [NSString stringWithFormat:@"%@", comment];
    
    pos += heightOfComment + GAP_OF_LABEL;
    
    //----------- bottom view --------------
    
    self.viewLoveCount.frame = CGRectMake(GAP_MAIN, pos, contentWidth, HEIGHT_BOTTOM);
    
    self.lblLoveCount.text = [NSString stringWithFormat:@"%i", post.likecnt];
}

- (void) increaseLikeCount;
{
    self.feed.likecnt ++;
    
    self.lblLoveCount.text = [NSString stringWithFormat:@"%i", self.feed.likecnt];
}

+ (float) getPostCellHeight:(PookFeed *)post width:(float)width
{
    float mainViewWidth = width - 2 * GAP_MAIN;
    float contentWidth = mainViewWidth - 2 * GAP_MAIN;
    
    float height = GAP_OF_LABEL + HEIGHT_TOP + contentWidth + GAP_OF_LABEL;
    
    NSString *description = [CommonMethods decodeUTF8:post.desc_text];
    float heightOfDescription = 0;
    
    if(description.length > 0)
    {
        heightOfDescription = [self getLabelHeightWithString:description width:contentWidth];
    }
    
    height += heightOfDescription + GAP_OF_LABEL;
    
    NSString *comment = post.lastcomment;
    float heightOfComment = [self getLabelHeightWithString:comment width:(contentWidth - COMMENT_MARGIN)];
    
    height += heightOfComment + GAP_OF_LABEL;
    
    height += HEIGHT_BOTTOM;
    
    return height;
}

+ (float) getLabelHeightWithString:(NSString *)string width:(float)width
{
    CGSize constrainedSize = CGSizeMake(width  , 9999);
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"Open Sans" size:POST_TEXT_FONT], NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributesDictionary];
    
    CGRect requiredHeight = [attributedString boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return requiredHeight.size.height;
}

- (IBAction)onLike:(id)sender
{
    [self.delegate likeFeed:self.feed index:self.index];
}

- (IBAction)onComment:(id)sender
{
    [self.delegate commentFeed:self.feed index:self.index];
}

- (IBAction)onShare:(id)sender
{
    [self.delegate shareFeed:self.feed image:self.ivPost.image index:self.index];
}

- (NSString *)getTimeIntervalString:(NSDate *)date
{
    NSTimeInterval localDiff = [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSTimeInterval interval = -[date timeIntervalSinceNow] - localDiff;
    

    
    NSInteger minutes = ((NSInteger)(interval / 60.f) % 60);
    if (minutes == 0)
        minutes = 1;
    
    NSInteger hours = (NSInteger)(interval / 3600.f);
    NSInteger days = (NSInteger)(interval / 86400.f);
    
    NSString *strInterval = nil;
    if (days > 1)
    {
        strInterval = [NSString stringWithFormat:@"%ld days", (long)days];
    }
    else
    {
        if (hours > 0)
        {
            strInterval = [NSString stringWithFormat:@"%ld hours", (long)hours];
        }
        else
        {
            if (minutes > 0)
            {
                strInterval = [NSString stringWithFormat:@"%ld mins", (long)minutes];
            }
        }
    }
    
    return strInterval;
}

@end
