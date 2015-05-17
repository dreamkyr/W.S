//
//  PookFeed.m
//  Pook

#import "PookFeed.h"

@implementation PookFeed

- (id) initWithDict:(NSDictionary *)dict
{
    NSLog(@"%@", dict);
    
    self = [super init];
    
    if (self) {
        [self setPostid:[[dict objectForKey:@"id"] intValue]];
        [self setPost_userid:[[dict objectForKey:@"userid"] intValue]];
        
        NSString *username = [dict objectForKey:@"username"];
        if(username == nil || ![username isKindOfClass:[NSString class]]) username = @"";
        [self setUsername:username];
        
        NSString *profile = [dict objectForKey:@"profile"];
        if(profile == nil || ![profile isKindOfClass:[NSString class]]) profile = @"";
        [self setProfile:profile];
        
        NSString *lastComment = [dict objectForKey:@"last_comment"];
        if(lastComment == nil || ![lastComment isKindOfClass:[NSString class]]) lastComment = @"";
        [self setLastcomment:lastComment];
        
        [self setCreatedDate:[dict objectForKey:@"created"]];
        [self setDevice_token:[dict objectForKey:@"device_token"]];
        [self setImage_url:[dict objectForKey:@"image_url"]];
        [self setLocation:[dict objectForKey:@"location"]];
        [self setLat:[[dict objectForKey:@"lat"] floatValue]];
        [self setLng:[[dict objectForKey:@"lng"] floatValue]];
        [self setLikecnt:[[dict objectForKey:@"likescnt"] intValue]];
        if ([[dict allKeys] containsObject:@"likeid"] && ![[dict valueForKey: @"likeid"] isKindOfClass: [NSNull class]]) {
            [self setLikeid:[[dict objectForKey:@"likeid"] intValue]];
        }
        else{
            [self setLikeid:0];
            
        }
        [self setCommentcnt:[[dict objectForKey:@"commentscnt"] intValue]];
        if ([[dict allKeys] containsObject:@"commentid"] && ![[dict valueForKey: @"commentid"] isKindOfClass: [NSNull class]]) {
            [self setCommentid:[[dict objectForKey:@"commentid"] intValue]];
        }
        else{
            [self setCommentid:0];
        }
        [self setFriendlevel:[[dict objectForKey:@"frendlevel"] intValue]];
        if (![[dict objectForKey:@"caption"] isKindOfClass:[NSNull class]]) {
            [self setDesc_text:[dict objectForKey:@"caption"]];
        }
                [self setDistance:[[dict objectForKey:@"distance"] floatValue]];
    }
    
    return self;
}

@end
