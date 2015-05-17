#import "NSString+SBJSON.h"
#import "SBJsonParser.h"

@implementation NSString (NSString_SBJSON)

- (id)JSONFragmentValue
{
    SBJsonParser *jsonParser = [SBJsonParser new];    
    id repr = [jsonParser fragmentWithString:self];    
    if (!repr)
        NSLog(@"-JSONFragmentValue failed. Error trace is: %@", [jsonParser errorTrace]);
    [jsonParser release];
    return repr;
}

- (id)JSONValue
{
    SBJsonParser *jsonParser = [SBJsonParser new];
    id repr = [jsonParser objectWithString:self];
    if (!repr)
        NSLog(@"-JSONValue failed. Error trace is: %@", [jsonParser errorTrace]);
    [jsonParser release];
    return repr;
}

@end
