//
//  PookPost.m
//  Pook

#import "PookPost.h"

@implementation PookPost
@synthesize userid ;
@synthesize lat;
@synthesize lng;
@synthesize address;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

-(id) initWithData
{
    self = [super init];
    if (self)
    {
        self.userid = @"";
        self.lat    = @"";
        self.lng    = @"";
        self.address = @"";
    }
    return  self;
}



@end
