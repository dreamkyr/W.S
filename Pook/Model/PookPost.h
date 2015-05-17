//
//  PookPost.h
//  Pook

#import <Foundation/Foundation.h>

@interface PookPost : NSObject

@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *lng;
@property (strong, nonatomic) NSString *address;

- (id) initWithData;

@end
