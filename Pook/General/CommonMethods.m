//
//  CommonMethods.m

#import "CommonMethods.h"

#import <QuartzCore/QuartzCore.h>

#import "MBProgressHUD.h"

@implementation CommonMethods

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

+ (void)showAlertUsingTitle:(NSString *)titleString andMessage:(NSString *)messageString {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

+ (NSString *)getVersionNumber {
    NSString * appVersionString = [[NSBundle mainBundle] 
                                   objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSLog(@"app version no. is:%@",appVersionString);
    return appVersionString;
}

+ (BOOL)checkEmail:(UITextField *)checkText
{
    BOOL filter = YES ;
    NSString *filterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = filter ? filterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if([emailTest evaluateWithObject:checkText.text] == NO)
    {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Input a valid Email address."];
        return NO ;
    }
    
    return YES ;
}

+ (BOOL)checkBlankField:(NSArray *)txtArray titles:(NSArray *)titleArray
{   
    UITextField *textField = nil;
    NSString *textTitle = nil;
    
    NSInteger nInx = 0;
    NSInteger nCnt = 0;
    
    for(nInx = 0, nCnt = [txtArray count]; nInx<nCnt; nInx++ )
    {
        textField = [txtArray objectAtIndex:nInx];
        textTitle = [titleArray objectAtIndex:nInx];
        
        if([textField.text isEqualToString:@""])
        {
            [CommonMethods showAlertUsingTitle:@"Error" andMessage:[NSString stringWithFormat:@"%@ can't be blank. Please try again.", textTitle]];
            return NO ;
        }
    }
    
    return YES ;
}

+ (NSString*) getAllContacts
{
    NSString* addressBookNum = [[NSString alloc] init];
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
//            ABAddressBookRef addressBook = ABAddressBookCreate( );
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAddressBookRequestAccessWithCompletion(addressBook,
                                                     ^(bool granted, CFErrorRef error){
                                                     });
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        for(int i = 0; i < numberOfPeople; i++)
        {
            
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
            // NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            // NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            // NSLog(@"Name:%@ %@", firstName, lastName);
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            [[UIDevice currentDevice] name];
            
            //NSLog(@"\n%@\n", [[UIDevice currentDevice] name]);
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++)
            {
                NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                                
                //Extract Only Numbers
                NSMutableString *strippedString = [NSMutableString
                                                   stringWithCapacity:phoneNumber.length];
                NSScanner *scanner = [NSScanner scannerWithString:phoneNumber];
                NSCharacterSet *numbers = [NSCharacterSet
                                           characterSetWithCharactersInString:@"0123456789"];
                while ([scanner isAtEnd] == NO) {
                    NSString *buffer;
                    if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
                        [strippedString appendString:buffer];
                    }
                    // --------- Add the following to get out of endless loop
                    else {
                        [scanner setScanLocation:([scanner scanLocation] + 1)];
                    }    
                    // --------- End of addition
                }
                addressBookNum = [addressBookNum stringByAppendingFormat: @"%@,",strippedString];
            }
        }
        if (![addressBookNum isEqualToString:@""]) {
            addressBookNum = [addressBookNum substringToIndex:[addressBookNum length]-1];
        }

        NSLog(@"AllNumber:%@",addressBookNum);
    }
    else
    {
        [self showAlertUsingTitle:@"Wasted Selfie" andMessage:@"You have to change your privacy settings"];
    }
    return addressBookNum;
}

+ (NSMutableArray*) getAllContactsNames
{
    NSMutableArray *contactNames = [[NSMutableArray alloc] init];
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            //            ABAddressBookRef addressBook = ABAddressBookCreate( );
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAddressBookRequestAccessWithCompletion(addressBook,
                                                     ^(bool granted, CFErrorRef error){
                                                     });
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        for(int i = 0; i < numberOfPeople; i++)
        {
            
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
             NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
             NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
//            [contactNames addObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++)
            {
                NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                
                //Extract Only Numbers
                NSMutableString *strippedString = [NSMutableString
                                                   stringWithCapacity:phoneNumber.length];
                NSScanner *scanner = [NSScanner scannerWithString:phoneNumber];
                NSCharacterSet *numbers = [NSCharacterSet
                                           characterSetWithCharactersInString:@"0123456789"];
                while ([scanner isAtEnd] == NO)
                {
                    NSString *buffer;
                    if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
                        [strippedString appendString:buffer];
                    }
                    // --------- Add the following to get out of endless loop
                    else {
                        [scanner setScanLocation:([scanner scanLocation] + 1)];
                    }
                    // --------- End of addition
                }
                NSMutableDictionary *dict_Contact = [[NSMutableDictionary alloc] init];
                [dict_Contact setObject:strippedString forKey:@"number"];
                [dict_Contact setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
                [contactNames addObject:dict_Contact];
            }
        }
    }
    else
    {
        [self showAlertUsingTitle:@"Wasted Selfie" andMessage:@"You have to change your privacy settings"];
    }
    NSLog(@"Contact Names %@", contactNames);
    return contactNames;
}

+ (NSString*)getHowLongAgo:(NSString *)old and:(NSString *) current
{
    NSString *ago = [[NSString alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date_old = [dateFormatter dateFromString:old];
    NSDate *date_cur = [dateFormatter dateFromString:current];
    
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit |NSYearCalendarUnit ;
    NSDateComponents *conversionInfo = [gregorian components:unitFlags fromDate:date_old toDate:date_cur options:0];
//    NSLog(@"TimeDifference= %iyear,%imonth,%iday,%ihour,%iminute",[conversionInfo year],[conversionInfo month],[conversionInfo day], [conversionInfo hour], [conversionInfo minute]);
    
    int year = [conversionInfo year];
    int month = [conversionInfo month];
    int day = [conversionInfo day];
    int hour = [conversionInfo hour];
    int minute = [conversionInfo minute];
    
    int diff;
    
    if (year==0)
    {
        if (month==0)
        {
            if (day==0)
            {
                if (hour==0)
                {
                    diff = minute;
                    if (diff<=1) {
                        ago = @"a minute ago";
                    }
                    else{
                        ago = [NSString stringWithFormat:@"%i minutes ago",diff];
                    }
                }
                else
                {
                    diff = hour;
                    ago = [NSString stringWithFormat:@"%i hours ago",diff];
                }
            }
            else
            {
                diff = day;
                ago = [NSString stringWithFormat:@"%i days ago",diff];
            }
        }
        else
        {
            diff = month;
            ago = [NSString stringWithFormat:@"%i months ago", diff];
        }
    }
    else
    {
        diff = year;
        ago = [NSString stringWithFormat:@"%i years ago",diff];
    }
    
//    NSLog(@"%@",ago);
    return ago;
}

+ (void) loginWithFB
{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        [self getFBUserInfo];
    }
    else
    {
//        [SVProgressHUD showWithStatus: @"Connecting With Facebook..."];
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"email",@"read_friendlists",
                                nil];
        FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
        [FBSession setActiveSession:session];
        if([FBSession openActiveSessionWithAllowLoginUI:NO])
        {
            [self getFBUserInfo];
        }
        else
        {
            // you need to log the user
            [FBSession openActiveSessionWithReadPermissions: permissions
                                               allowLoginUI: YES
                                          completionHandler: ^(FBSession *session,
                                                               FBSessionState state,
                                                               NSError *error)
             {
                 [self getFBUserInfo];
             }];
        }
    }

}

+ (void) getFBUserInfo
{
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error)
     {
         NSLog(@"User = %@", user);
         if (!error)
         {
             [self getFBFriends];
         }
     }];
}

+(void) getFBFriends
{
//    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id response, NSError *error)
//     {
//         NSMutableArray *friends = [NSMutableArray new];
//         NSLog(@"error %@", error);
//         NSLog(@"response %@", response);
//         if (!error)
//         {
//             [friends addObjectsFromArray:(NSArray*)[response data]];
//         }
//         
//         NSLog(@"friends = %@", friends);
//         
//     }];
    [FBRequestConnection startWithGraphPath:@"/me/taggable_friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              NSLog(@"freidns %@", result);
                          }];
}

+ (NSString*) encodeUTF8:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *valueUnicode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return valueUnicode;
}

+ (NSString*) decodeUTF8:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *valueTextwithEmoji = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    return valueTextwithEmoji;
}

@end
