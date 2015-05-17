
#import <UIKit/UIKit.h>

@class FSWebLogin;

@protocol FSWebLoginDelegate <NSObject>
@required

- (void)webLogin:(FSWebLogin *)loginViewController didFinishWithError:(NSError *)error;

@end

@interface FSWebLogin : UIViewController


- (id) initWithUrl:(NSString *)url
       andDelegate:(id<FSWebLoginDelegate>)delegate;

@end
