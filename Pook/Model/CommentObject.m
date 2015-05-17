//
//  CommentObject.m
//  Pook

#import "CommentObject.h"

@implementation CommentObject

-(id) initWithDict:(NSDictionary *)dict
{
    NSLog(@"%@", dict);
    
    self = [super init];
    if (self)
    {
        NSString *username = [dict objectForKey:@"username"];
        if(username == nil || ![username isKindOfClass:[NSString class]]) username = @"";
        [self setUsername:username];
        
        NSString *profile = [dict objectForKey:@"profile"];
        if(profile == nil || ![profile isKindOfClass:[NSString class]]) profile = @"";
        [self setProfile:profile];

        
        [self setComment_id:[[dict objectForKey:@"id"] intValue]];
        [self setPost_id:[[dict objectForKey:@"postid"] intValue]];
        [self setCommentor_id:[[dict objectForKey:@"commentorid"] intValue]];
        [self set_commentText:[dict objectForKey:@"comment"]];
        if ([[dict allKeys] containsObject:@"likecommentid"] && ![[dict valueForKey: @"likecommentid"] isKindOfClass: [NSNull class]]) {
            [self setLikedFlag:[[dict objectForKey:@"likecommentid"] intValue]];
        }
        else{
            [self setLikedFlag:0];
        }
        [self setLikesCnt:[[dict objectForKey:@"likescnt"] intValue]];
        [self setOld_date:[dict objectForKey:@"created"]];
        [self setCur_date:[dict objectForKey:@"current"]];
    }
    
    return  self;
}

@end
