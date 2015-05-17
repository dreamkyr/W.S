// AFNetworking.h
//

#import <Foundation/Foundation.h>
#import <Availability.h>

#ifndef _AFNETWORKING_
    #define _AFNETWORKING_

    #import "AFURLRequestSerialization.h"
    #import "AFURLResponseSerialization.h"
    #import "AFSecurityPolicy.h"
    #import "AFNetworkReachabilityManager.h"

    #import "AFURLConnectionOperation.h"
    #import "AFHTTPRequestOperation.h"
    #import "AFHTTPRequestOperationManager.h"

#if ( ( defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090) || \
      ( defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 ) )
    #import "AFURLSessionManager.h"
    #import "AFHTTPSessionManager.h"
#endif

#endif /* _AFNETWORKING_ */
