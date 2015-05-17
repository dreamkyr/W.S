//
//  NotificationObject.h
//  Pook

#import <Foundation/Foundation.h>

@interface NotificationObject : NSObject

@property int postid;
@property int userid;
@property int notificationid;
@property int cnt;
@property int type;
@property int isread;
@property (nonatomic, strong) NSString *image_url;

- (id) initWithDict:(NSDictionary*)dict;

@end
