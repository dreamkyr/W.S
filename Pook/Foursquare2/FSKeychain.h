//
//  FSKeychain.h
//  Foursquare2

#import <Foundation/Foundation.h>

@interface FSKeychain : NSObject

+ (instancetype)sharedKeychain;

- (NSString *)readAccessTokenFromKeychainWithClientId:(NSString *)clientId;

- (void)saveAccessTokenInKeychain:(NSString *)accessToken forClientId:(NSString *)clientId;

- (void)removeAccessTokenFromKeychainWithClientId:(NSString *)clientId;

@end
