//
//  VerifyEmailTableViewController.m
//  Stories
//
//  Created by Evan Latner on 1/10/16.
//  Copyright © 2016 stories. All rights reserved.
//

#import "VerifyEmailTableViewController.h"
#import "AppDelegate.h"
#import "StatusTableViewController.h"
#import "CameraViewController.h"
#import "ProgressHUD.h"

#define IS_IOS8 [[UIDevice currentDevice].systemVersion floatValue] >= 8.0


@interface VerifyEmailTableViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *acceptableEmailAddress;

@end

@implementation VerifyEmailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.blueButton.layer.cornerRadius = 4;
    
    self.emailTextfield.delegate = self;
    
    self.acceptableEmailAddress = [[NSMutableArray alloc] init];
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig * _Nullable config, NSError * _Nullable error) {
        if (error) {
            
        } else {
            self.acceptableEmailAddress = config[@"acceptableEmailAddress"];
            NSString *link = config[@"appLink"];
            [[NSUserDefaults standardUserDefaults] setObject:link forKey:@"appLink"];
            NSLog(@"Link: %@", link);
            
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField; {
    
    if([self.emailTextfield isFirstResponder]){
        [self buttonTapped:self];
    }
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {

    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setHidden:YES];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.emailTextfield becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) return _firstCell;
    if (indexPath.row == 1) return _secondCell;
    if (indexPath.row == 2) return _thirdCell;
    
    return nil;
}

- (IBAction)buttonTapped:(id)sender {
    
    NSString * aString = self.emailTextfield.text;
    
    NSMutableString *substrings = [NSMutableString new];
    NSScanner *scanner = [NSScanner scannerWithString:aString];
    [scanner scanUpToString:@"@" intoString:nil]; // Scan all characters before #
    while(![scanner isAtEnd]) {
        NSString *substring = nil;
        [scanner scanString:@"@" intoString:nil]; // Scan the # character
        if([scanner scanUpToString:@"." intoString:&substring]) {
            [substrings appendString:substring];
        }
        [scanner scanUpToString:@"#" intoString:nil]; // Scan all characters before next #
    }
    
    NSString *string = [NSString stringWithFormat:@"%@", substrings];
    self.userschool = [string capitalizedString];
    
    if ([aString rangeOfString:@".edu"].location == NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid email" message:@"Please enter a valid .edu email address" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alert show];
        return;
    }
    
    if (self.acceptableEmailAddress.count == 0) {
        NSString *plainEdu = @".edu";
        [self.acceptableEmailAddress addObject:plainEdu];
    }
    
    if (![self.acceptableEmailAddress containsObject:self.userschool]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bummer" message:@"Stories isn't available there right now." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [alert show];
            return;
        
    } else {
            
        [self incrementSchoolUserCount];
        [[NSUserDefaults standardUserDefaults] setObject:self.userschool forKey:@"userSchool"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [ProgressHUD show:nil Interaction:NO];
        NSString *emailAddress = self.emailTextfield.text;
        NSString *userObjectId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userObjectId"];
        
        PFObject *user = self.currentUser;
        [user setObject:emailAddress forKey:@"emailAddress"];
        [user setObject:self.userschool forKey:@"userSchool"];
        if ([self.userschool isEqualToString:@"Example"]) {
            [user setObject:@"approved" forKey:@"userStatus"];
            [[NSUserDefaults standardUserDefaults] setObject:@"approved" forKey:@"userStatus"];
            [[NSUserDefaults standardUserDefaults] setObject:@"approved" forKey:@"universityStatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            [user setObject:@"pending" forKey:@"userStatus"];
        }
        [user setObject:@"pending" forKey:@"universityStatus"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error %@", error);
                [ProgressHUD dismiss];
            } else {
                
                [PFCloud callFunctionInBackground:@"sendEmailVerification" withParameters:@{ @"emailAddress": emailAddress, @"userId": userObjectId } block:^(id  _Nullable object, NSError * _Nullable error) {
                    if (error) {
                        [ProgressHUD showError:@"Network Error"];
                        NSLog(@"Error: %@", error);
                    } else {
                        [ProgressHUD dismiss];
                        NSLog(@"Success!");
                        [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.6];
                        [self.emailTextfield resignFirstResponder];
                        [[NSUserDefaults standardUserDefaults] setInteger:99 forKey:@"localUserScore"];
                        [[NSUserDefaults standardUserDefaults] setObject:@"pending" forKey:@"universityStatus"];
                        [[NSUserDefaults standardUserDefaults] synchronize];

                    }
                }];
            }
        }];
    }
}

-(void)showAlert {
    
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email sent" message:@"An activation link has been sent to your email address. Please check your email and activate your account. Check your spam folder if you didn't receive the email in your primary inbox." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alertView show];

        alertView.tag = 101;
        alertView.delegate = self;
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
    if (alertView.tag == 101) {
        
        if (buttonIndex == 0) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
                
        }
    }
}

-(void)incrementSchoolUserCount {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Universities"];
    [query whereKey:@"universityName" equalTo:self.userschool];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            
            PFObject *school = [PFObject objectWithClassName:@"Universities"];
            [school setObject:self.userschool forKey:@"universityName"];
            [school setObject:@"pending" forKey:@"universityStatus"];
            [school incrementKey:@"userSignupCount"];
            [school setObject:[NSNumber numberWithInt:499] forKey:@"userThreshold"];
            [school saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                } else {
                }
            }];
         } else {

            [object incrementKey:@"userSignupCount"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
               
                if (error) {
                    
                } else {
                }
            }];
        }
    }];
}

@end
