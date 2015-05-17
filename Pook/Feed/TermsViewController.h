//
//  TermsViewController.h
//  Pook
//
//  Created by han on 1/16/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TermsViewControllerDelegate <NSObject>

- (void) onMenuWithTermsViewController;

@end

@interface TermsViewController : UIViewController

@property (nonatomic, assign) id <TermsViewControllerDelegate> delegate;

@end
