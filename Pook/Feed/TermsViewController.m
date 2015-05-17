//
//  TermsViewController.m
//  Pook
//
//  Created by han on 1/16/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import "TermsViewController.h"

@interface TermsViewController ()

@property (nonatomic, assign) IBOutlet UIWebView *webView;

@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Policy" ofType:@"html"]isDirectory:NO]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender
{
    [self.delegate onMenuWithTermsViewController];
}

@end
