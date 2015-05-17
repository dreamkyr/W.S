//
//  LazyFadeInLayer.h
//  LazyFadeInView

#import <QuartzCore/QuartzCore.h>
#import "LazyFadeIn.h"

@interface LazyFadeInLayer : CATextLayer <LazyFadeIn>

- (void)_updateAnimation;

@end
