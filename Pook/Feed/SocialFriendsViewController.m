//
//  SocialFriendsViewController.m
//  Pook
//
//  Created by han on 1/15/15.
//  Copyright (c) 2015 iWorld. All rights reserved.
//

#import "SocialFriendsViewController.h"

#import "SocialFriendTableViewCell.h"

@interface SocialFriendsViewController ()

@property (nonatomic, assign) IBOutlet UIView *viewTop;
@property (nonatomic, assign) IBOutlet UILabel *lblTitle;

@property (nonatomic, assign) IBOutlet UITableView *tvFriends;

@property (nonatomic, retain) NSMutableArray *aryFriends;

@end

@implementation SocialFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [self reloadFriends];
}

- (IBAction)onBack:(id)sender
{
    [self.delegate onMenuWithSocialFriendsViewController];
}

- (void) reloadFriends
{
    [self updateUI];
    
    [self.tvFriends reloadData];
}

- (void) updateUI
{
    if(self.friendType == 0)
    {
        self.viewTop.backgroundColor = [UIColor colorWithRed:54.0f / 255.0f green:89.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
        self.lblTitle.text = @"FACEBOOK FRIENDS";
    }
    else
    {
        self.viewTop.backgroundColor = [UIColor colorWithRed:32.0f / 255.0f green:53.0f / 255.0f blue:92.0f / 255.0f alpha:1.0f];
        self.lblTitle.text = @"INSTAGRAM FRIENDS";
    }
}

#pragma -mark Table Delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;//self.aryFriends.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifer = @"Cell";
    SocialFriendTableViewCell *cell = (SocialFriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SocialFriendTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell updateLayout];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
