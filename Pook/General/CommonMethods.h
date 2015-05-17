//
//  CommonMethods.h

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <FacebookSDK/FacebookSDK.h>

@interface CommonMethods : NSObject {
    
}

+ (void)showAlertUsingTitle:(NSString *)titleString andMessage:(NSString *)messageString;
+ (NSString *)getVersionNumber;
+ (BOOL)checkEmail:(UITextField *)checkText;
+ (BOOL)checkBlankField:(NSArray *)txtArray titles:(NSArray *)titleArray;
+ (NSString*) getAllContacts;
+ (NSMutableArray*)getAllContactsNames;
+ (void) loginWithFB;
+ (void) getFBUserInfo;
+ (NSString*)getHowLongAgo:(NSString*)old and:(NSString*)current;

+(void) getFBFriends;

+ (NSString*) encodeUTF8:(NSString*)string;
+ (NSString*) decodeUTF8:(NSString*)string;


@end
