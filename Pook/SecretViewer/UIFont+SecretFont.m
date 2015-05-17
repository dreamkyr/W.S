//
//  UIFont+secretFont.m

#import "UIFont+secretFont.h"

@implementation UIFont (secretFont)

+ (UIFont *)secretFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:size];
}

+ (UIFont *)secretFontLightWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:size];
}
@end
