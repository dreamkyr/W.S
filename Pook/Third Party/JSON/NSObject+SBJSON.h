

#import <Foundation/Foundation.h>


/**
 @brief Adds JSON generation to Foundation classes
 
 This is a category on NSObject that adds methods for returning JSON representations
 of standard objects to the objects themselves. This means you can call the
 -JSONRepresentation method on an NSArray object and it'll do what you want.
 */
@interface NSObject (NSObject_SBJSON)

/**
 @brief Returns a string containing the receiver encoded as a JSON fragment.
 
 This method is added as a category on NSObject but is only actually
 supported for the following objects:
 @li NSDictionary
 @li NSArray
 @li NSString
 @li NSNumber (also used for booleans)
 @li NSNull 
 
 @deprecated Given we bill ourselves as a "strict" JSON library, this method should be removed.
 */
- (NSString *)JSONFragment;

/**
 @brief Returns a string containing the receiver encoded in JSON.

 This method is added as a category on NSObject but is only actually
 supported for the following objects:
 @li NSDictionary
 @li NSArray
 */
- (NSString *)JSONRepresentation;

@end

