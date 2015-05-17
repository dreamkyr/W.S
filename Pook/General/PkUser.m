//
//  PkUser.m
//  Pook

#import "PkUser.h"

@implementation PkUser
@synthesize userid;
@synthesize deviceToken;
@synthesize friends;

- (id) initWithData
{
    self = [super init];
    if (self) {
//        [self setDeviceToken:[NSString alloc]];
//        [self setUserid:[NSString alloc]];
    }
    return self;
}

@end
