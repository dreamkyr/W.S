
#import <Foundation/Foundation.h>
#import "SBJsonParser.h"
#import "SBJsonWriter.h"

/**
 @brief Facade for SBJsonWriter/SBJsonParser.

 Requests are forwarded to instances of SBJsonWriter and SBJsonParser.
 */
@interface SBJSON : SBJsonBase <SBJsonParser, SBJsonWriter> {

@private    
    SBJsonParser *jsonParser;
    SBJsonWriter *jsonWriter;
}


/// Return the fragment represented by the given string
- (id)fragmentWithString:(NSString*)jsonrep
                   error:(NSError**)error;

/// Return the object represented by the given string
- (id)objectWithString:(NSString*)jsonrep
                 error:(NSError**)error;

/// Parse the string and return the represented object (or scalar)
- (id)objectWithString:(id)value
           allowScalar:(BOOL)x
    			 error:(NSError**)error;


/// Return JSON representation of an array  or dictionary
- (NSString*)stringWithObject:(id)value
                        error:(NSError**)error;

/// Return JSON representation of any legal JSON value
- (NSString*)stringWithFragment:(id)value
                          error:(NSError**)error;

/// Return JSON representation (or fragment) for the given object
- (NSString*)stringWithObject:(id)value
                  allowScalar:(BOOL)x
    					error:(NSError**)error;


@end
