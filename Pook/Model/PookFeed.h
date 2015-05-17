//
//  PookFeed.h
//  Pook

#import <Foundation/Foundation.h>

@interface PookFeed : NSObject

@property int postid;
@property int post_userid;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *profile;

@property (nonatomic, strong) NSString *device_token;
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *desc_text;
@property (nonatomic, strong) NSString *createdDate;

@property (nonatomic, strong) NSString *lastcomment;

@property float lat;
@property float lng;
@property int likecnt;
@property int commentcnt;
@property int friendlevel;
@property int likeid;
@property int commentid;
@property float distance;

- (id) initWithDict:(NSDictionary*)dict;

@end
