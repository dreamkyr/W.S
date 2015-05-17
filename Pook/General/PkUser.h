//
//  PkUser.h
//  Pook

#import <Foundation/Foundation.h>

@interface PkUser : NSObject

@property (retain, nonatomic) NSString* deviceToken;
@property (retain, nonatomic) NSString* userid;
@property (retain, nonatomic) NSMutableArray* friends;

-(id) initWithData;

@end
