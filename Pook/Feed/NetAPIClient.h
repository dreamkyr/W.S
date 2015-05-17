//
//  NetAPIClient.h
//  TipHive

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NetAPIClient : AFHTTPRequestOperationManager

+ (NetAPIClient *)sharedClient;

- (void)sendToServicePOST:(NSDictionary *)params_
              success:(void (^)(id responseObject_))success_
              fail:(void (^)(NSError* _error))failure_;

- (void)sendToServiceGET:(NSDictionary *)params_
                  success:(void (^)(id responseObject_))success_
                     fail:(void (^)(NSError* _error))failure_;

- (void)postImageParams:(NSDictionary *)params_
                  image:(NSData*)imageData_
              imageName:(NSString*)imageName_
                success:(void (^)(id responseObject_))success_
                   fail:(void (^)(NSError* _error))failure_;

- (void)postMultiImages:(NSDictionary*)params_
                 images:(NSArray*)images_
              imageName:(NSString*)imageName_
                service:(NSString*)service_
                success:(void (^)(id responseObject_))success_
                   fail:(void (^)(NSError* _error))failure_;

@end
