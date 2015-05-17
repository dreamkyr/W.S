//
//  NotificationObject.m
//  Pook

#import "NotificationObject.h"

@implementation NotificationObject

- (id) initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setPostid:[[dict objectForKey:@"postid"] intValue]];
        [self setUserid:[[dict objectForKey:@"userid"] intValue]];
        [self setNotificationid:[[dict objectForKey:@"id"] intValue]];
        [self setCnt:[[dict objectForKey:@"num"] intValue]];
        [self setType:[[dict objectForKey:@"type"] intValue]];
        [self setIsread:[[dict objectForKey:@"isread"] intValue]];
        [self setImage_url:[dict objectForKey:@"image_url"]];
    }
    
    return self;
}

@end
