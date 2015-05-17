//
//  FSConverter.m
//  Foursquare2-iOS

#import "FSConverter.h"
#import "FSVenue.h"

@implementation FSConverter

- (NSArray *)convertToObjects:(NSArray *)venues {
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:venues.count];
    for (NSDictionary *v  in venues) {
        FSVenue *ann = [[FSVenue alloc]init];
        ann.name = v[@"name"];
        ann.venueId = v[@"id"];

        ann.location.address = v[@"location"][@"address"];
        ann.location.distance = v[@"location"][@"distance"];
//        ann.location.fullAdd = v[@"location"][@"city"];
        ann.location.fullAdd = [[NSString alloc] init];
        
        NSArray *formattedAddress = [[NSArray alloc] init];
        formattedAddress = v[@"location"][@"formattedAddress"];
        
        for (int i=0; i<[formattedAddress count]; i++) {
            ann.location.fullAdd = [ann.location.fullAdd stringByAppendingFormat:@"%@ ",[formattedAddress objectAtIndex:i] ];
        }
        
        [ann.location setCoordinate:CLLocationCoordinate2DMake([v[@"location"][@"lat"] doubleValue],
                                                      [v[@"location"][@"lng"] doubleValue])];
        [objects addObject:ann];
    }
    return objects;
}

@end
