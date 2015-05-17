
#import "NSObject+SBJSON.h"
#import "SBJsonWriter.h"

@implementation NSObject (NSObject_SBJSON)

- (NSString *)JSONFragment {
    SBJsonWriter *jsonWriter = [SBJsonWriter new];
    NSString *json = [jsonWriter stringWithFragment:self];    
    if (!json)
        NSLog(@"-JSONFragment failed. Error trace is: %@", [jsonWriter errorTrace]);
    [jsonWriter release];
    return json;
}

- (NSString *)JSONRepresentation {
    SBJsonWriter *jsonWriter = [SBJsonWriter new];    
    NSString *json = [jsonWriter stringWithObject:self];
    if (!json)
        NSLog(@"-JSONRepresentation failed. Error trace is: %@", [jsonWriter errorTrace]);
    [jsonWriter release];
    return json;
}

@end
