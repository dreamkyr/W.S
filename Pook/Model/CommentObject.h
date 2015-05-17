//
//  CommentObject.h
//  Pook

#import <Foundation/Foundation.h>

@interface CommentObject : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *profile;

@property int comment_id;
@property int post_id;
@property int commentor_id;
@property (nonatomic, strong) NSString* _commentText;
@property int likedFlag;
@property int likesCnt;
@property (nonatomic, strong) NSString* old_date;
@property (nonatomic, strong) NSString* cur_date;

-(id) initWithDict:(NSDictionary*)dict;

@end
