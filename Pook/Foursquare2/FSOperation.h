//
//  FSOperation.h
//  Foursquare2

#import <Foundation/Foundation.h>

typedef void(^Foursquare2Callback)(BOOL success, id result);

@interface FSOperation : NSOperation

- (id)initWithRequest:(NSURLRequest *)request
             callback:(Foursquare2Callback)block
        callbackQueue:(dispatch_queue_t)callbackQueue;

@end
