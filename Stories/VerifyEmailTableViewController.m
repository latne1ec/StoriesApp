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
@property (nonatomic, strong) PFObject *previouslyCreatedUser;

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
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField; {
    
    if([self.emailTextfield isFirstResponder]){
        [self checkIfEmailAlreadyExists:self];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"change_home_pic" object:self];
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

- (IBAction)checkIfEmailAlreadyExists:(id)sender {
    
    [ProgressHUD show:nil Interaction:NO];
    [self.emailTextfield resignFirstResponder];
    NSString *email = self.emailTextfield.text;
    
    if ([email rangeOfString:@"example"].location != NSNotFound) {
        [self buttonTapped:self];
        return;
    }
    
    PFQuery *q = [PFQuery queryWithClassName:@"CustomUser"];
    [q whereKey:@"emailAddress" equalTo:email];
    [q getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        if (object == nil) {
            //NSLog(@"Email Doesn't exist");
            [self buttonTapped:self];//??
            
        } else {
            
            if ([[object objectForKey:@"hasLoggedIn"] isEqualToString:@"YES"]) {
                //show some popup that says a user already exists for that email
                [ProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"That email address is already in use." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
                [alert show];
                
            } else {
                //user already verified there account, give them access!
                self.previouslyCreatedUser = object;
                [self allowUserToEnter];
            }
        }
    }];
}

-(void)allowUserToEnter {
    
    NSString *userSchool = [self.previouslyCreatedUser objectForKey:@"userSchool"];
    NSString *userSchoolId = [self.previouslyCreatedUser objectForKey:@"userSchoolId"];
    NSString *userObjectId = self.previouslyCreatedUser.objectId;
    
    //[self incrementSchoolUserCount];
    [[NSUserDefaults standardUserDefaults] setObject:userSchool forKey:@"userSchool"];
    [[NSUserDefaults standardUserDefaults] setObject:userObjectId forKey:@"userObjectId"];
    [[NSUserDefaults standardUserDefaults] setObject:@"approved" forKey:@"userStatus"];
    [[NSUserDefaults standardUserDefaults] setObject:userSchoolId forKey:@"userSchoolId"];
    [[NSUserDefaults standardUserDefaults] setObject:@"pending" forKey:@"universityStatus"];
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasLoggedIn"];
    [[NSUserDefaults standardUserDefaults] setInteger:99 forKey:@"localUserScore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.currentUser deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            
        } else {
            
            //NSLog(@"success!!!");
            CameraViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Camera"];
            cvc.currentUser = self.previouslyCreatedUser;
            [self performSelector:@selector(dismissDasView) withObject:nil afterDelay:0.75];
        }
    }];
}

-(void)dismissDasView {
    
    [ProgressHUD dismiss];
    [self dismissViewControllerAnimated:NO completion:nil];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid email" message:@"Enter a valid .edu email address" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alert show];
        [ProgressHUD dismiss];
        return;
    }
    if (self.acceptableEmailAddress.count == 0) {
        NSString *plainEdu = @".edu";
        [self.acceptableEmailAddress addObject:plainEdu];
    }
    if (![self.acceptableEmailAddress containsObject:self.userschool]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bummer" message:@"Stories isn't available at your university right now." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [alert show];
        [ProgressHUD dismiss];
            return;
    } else {
            
        [self incrementSchoolUserCount];
        [[NSUserDefaults standardUserDefaults] setObject:self.userschool forKey:@"userSchool"];
        [[NSUserDefaults standardUserDefaults] synchronize];
  
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
                [ProgressHUD dismiss];
            } else {
                
                NSString *urlString = [NSString stringWithFormat:@"http://storiesss.com/verify.php?user_id=%@&email_address=%@&user_school=%@", userObjectId, emailAddress, self.userschool];
                NSURL *url = [NSURL URLWithString:urlString];
                
                NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                
                [request setHTTPMethod:@"POST"];
                NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error) {
                        //NSLog(@"Error: %@", error);
                        [self tryMailgun:emailAddress :userObjectId];
                        
                    } else {
                        
                       //NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                       //NSLog(@"Response: %@", responseString);
                        
                        [ProgressHUD dismiss];
                        //NSLog(@"Success!");
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.6];
                            [self.emailTextfield resignFirstResponder];
                            [[NSUserDefaults standardUserDefaults] setInteger:99 forKey:@"localUserScore"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"pending" forKey:@"universityStatus"];
                            [[NSUserDefaults standardUserDefaults] synchronize];

                        });
                    }
                }];
                
                [postDataTask resume];
            }
        }];
    }
}

-(void)tryMailgun: (NSString *)emailAddress : (NSString *)userObjectId {
    
        [PFCloud callFunctionInBackground:@"sendEmailVerification" withParameters:@{ @"emailAddress": emailAddress, @"userId": userObjectId } block:^(id  _Nullable object, NSError * _Nullable error) {
            if (error) {
                [ProgressHUD showError:@"network error"];
                //NSLog(@"Error: %@", error);
            } else {
                [ProgressHUD dismiss];
                //NSLog(@"Success!");
                [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.6];
                [self.emailTextfield resignFirstResponder];
                [[NSUserDefaults standardUserDefaults] setInteger:99 forKey:@"localUserScore"];
                [[NSUserDefaults standardUserDefaults] setObject:@"pending" forKey:@"universityStatus"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
}

-(void)showAlert {
    
    [ProgressHUD dismiss];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email sent" message:@"An activation link has been sent to your email address. Check your email and activate your account. Check your spam folder if you didn't receive the email in your primary inbox." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
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
