//
//  StatusTableViewController.h
//  Stories
//
//  Created by Evan Latner on 1/13/16.
//  Copyright © 2016 stories. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"

@interface StatusTableViewController : UITableViewController 

@property (weak, nonatomic) IBOutlet UITableViewCell *firstCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *secondCell;
@property (weak, nonatomic) IBOutlet UIButton *inviteFriendsButton;
@property (weak, nonatomic) IBOutlet UILabel *lockLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCountLabel;

@property (nonatomic, strong) PFObject *currentUser;

- (IBAction)inviteButtonTapped:(id)sender;

@end
