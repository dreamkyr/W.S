//
//  NetAPIClient.m
//  TipHive

#import "NetAPIClient.h"

//static NSString *baseURLString = @"http://192.168.2.112/pollit/index.php";
static NSString *baseURLString = @"http://54.172.52.116/pook/pookWebService.php";

@implementation NetAPIClient

+ (NetAPIClient*)sharedClient {
    static NetAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NetAPIClient alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)sendToServicePOST:(NSDictionary *)params_
              success:(void (^)(id responseObject_))success_
              fail:(void (^)(NSError* _error))failure_
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    
    [manager POST:baseURLString
       parameters:params_
          success:^(AFHTTPRequestOperation *operation_, id responseObject_){
              if (success_) {
                  success_(responseObject_);
              }
          }
          failure:^(AFHTTPRequestOperation *operation_, NSError *error_){
              if (failure_) {
                  failure_(error_);
              }
          }];
}

- (void)sendToServiceGET:(NSDictionary *)params_
                  success:(void (^)(id responseObject_))success_
                     fail:(void (^)(NSError* _error))failure_
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@", baseURLString, @"?action=SignIn&username=a&password=a&social=1"];
    
    params_ = [NSMutableDictionary dictionary];
    
    [manager GET:strURL
       parameters:params_
          success:^(AFHTTPRequestOperation *operation_, id responseObject_){
              if (success_) {
                  success_(responseObject_);
              }
          }
          failure:^(AFHTTPRequestOperation *operation_, NSError *error_){
              if (failure_) {
                  failure_(error_);
              }
          }];
}

- (void)postImageParams:(NSDictionary *)params_
                  image:(NSData *)imageData_
              imageName:(NSString *)imageName_
                success:(void (^)(id))success_
                   fail:(void (^)(NSError *))failure_
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:baseURLString
       parameters:params_
constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
    if (imageData_!=nil) {
        [formData appendPartWithFileData:imageData_ name:imageName_ fileName:[NSString stringWithFormat:@"%@.jpg", imageName_] mimeType:@"image/jpeg"];
        }
    }
          success:^(AFHTTPRequestOperation *operation, id responseObject_){
              if (success_) {
                  success_(responseObject_);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error_){
              if (failure_) {
                  failure_(error_);
              }
          }];
}

- (void)postMultiImages:(NSDictionary *)params_
                 images:(NSArray *)images_
              imageName:(NSString *)imageName_
                service:(NSString *)service_
                success:(void (^)(id))success_
                   fail:(void (^)(NSError *))failure_
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?", baseURLString, service_];
    [manager POST:urlString
       parameters:params_
constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
    for (int i=0; i<[images_ count]; i++)
    {
        [formData appendPartWithFileData:[images_ objectAtIndex:i] name:imageName_ fileName:[NSString stringWithFormat:@"%@.jpg", imageName_] mimeType:@"image/jpeg"];
    }
}
          success:^(AFHTTPRequestOperation *operation, id responseObject_){
              if (success_) {
                  success_(responseObject_);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error_){
              if (failure_) {
                  failure_(error_);
              }
          }];
}

@end
