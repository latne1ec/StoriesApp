//
//  VerifyEmailTableViewController.h
//  Stories
//
//  Created by Evan Latner on 1/10/16.
//  Copyright © 2016 stories. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface VerifyEmailTableViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate, NSURLSessionDelegate>


@property (weak, nonatomic) IBOutlet UITableViewCell *firstCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *secondCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *thirdCell;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UIButton *blueButton;
@property (nonatomic, strong) PFObject *currentUser;

@property (nonatomic, strong) NSString *userschool;


@property (nonatomic) BOOL status;

- (IBAction)checkIfEmailAlreadyExists:(id)sender;

- (IBAction)buttonTapped:(id)sender;

@end
