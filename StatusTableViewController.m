//
//  StatusTableViewController.m
//  Stories
//
//  Created by Evan Latner on 1/13/16.
//  Copyright © 2016 stories. All rights reserved.
//

#import "StatusTableViewController.h"

@interface StatusTableViewController ()

@property (nonatomic, strong) UIApplication *application;


@end

@implementation StatusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.application = [UIApplication sharedApplication];
    
    self.inviteFriendsButton.layer.cornerRadius = 4;
    
    [self countUsers];

}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setHidden:YES];
    
}

-(void)showAlert {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"askedToEnablePush"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *school = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
    NSString *message = [NSString stringWithFormat:@"Want to get notified when %@ is unlocked?", school];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enable notifications" message:message delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"Yeah", nil];
    [alertView show];
    
    alertView.tag = 101;
    alertView.delegate = self;
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
    if (alertView.tag == 101) {
        
        if (buttonIndex == 0) {
            
        } else {
            
            [self askToEnablePush];
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.row == 0) return _firstCell;
    if (indexPath.row == 1) return _secondCell;
    
    return nil;

}

- (IBAction)inviteButtonTapped:(id)sender {
    
        NSString* newString = @"Hey, download Stories to unlock our school.";
        
        NSArray *objectsToShare = @[newString];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        
        NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                       UIActivityTypePrint,
                                       UIActivityTypeCopyToPasteboard,
                                       UIActivityTypeAssignToContact,
                                       UIActivityTypeSaveToCameraRoll,
                                       UIActivityTypeAddToReadingList,
                                       UIActivityTypePostToFlickr,
                                       UIActivityTypePostToVimeo];
        
        activityVC.excludedActivityTypes = excludeActivities;
        activityVC.title = @"the";
        [self presentViewController:activityVC animated:YES completion:^{
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            
        }];
}

-(void)askToEnablePush {
    
    NSLog(@"Called from VC");
    //    UIApplication *application = [UIApplication sharedApplication];
    
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [self.application registerUserNotificationSettings:settings];
    [self.application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            
        } else {
        }
    }];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Error registering for push notifications: %@", error);
}

-(void)countUsers {
    
    NSString *userSchool = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"] lowercaseString];
    NSLog(@"School : %@", userSchool);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Universities"];
    [query whereKey:@"universityName" equalTo:[userSchool capitalizedString]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            [ProgressHUD showError:@"Network Error"];
        } else {
            PFObject *school = object;
            int userCount = [[school objectForKey:@"userCount"] intValue];
            int userThreshold = [[school objectForKey:@"userThreshold"] intValue];
            int remainingCount = userThreshold - userCount;
            self.userCountLabel.text = [NSString stringWithFormat:@"%d more students needed to unlock %@.",remainingCount, userSchool];
            
            
            if (userCount >= userThreshold) {
                
                if ([[self.currentUser objectForKey:@"userStatus"] isEqualToString:@"pending"]) {
                    
                    self.userCountLabel.text = [NSString stringWithFormat:@"%@ is currently open, check your email and validate your account to enter.", userSchool];
                    
                } else {
                    
                    self.lockLabel.text = @"🔓";
                    [ProgressHUD show:nil];
                    self.userCountLabel.text = [NSString stringWithFormat:@"%d more students needed to unlock %@.",0, userSchool];
                    [self performSelector:@selector(doThis) withObject:nil afterDelay:1.5];
                    
                }
            } else {
                
                [self askUserForPush];
            }
        }
    }];
}

-(void)askUserForPush {
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"askedToEnablePush"] isEqualToString:@"YES"]) {
        
    } else {
        
        [self performSelector:@selector(showAlert) withObject:nil afterDelay:1.0];
    }
    
}

-(void)doThis {
    
    [self.currentUser setObject:@"accepted" forKey:@"universityStatus"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (error) {
            [ProgressHUD showError:@"Network Eror"];
            
        } else {
            [ProgressHUD dismiss];
            //Dismiss view
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end
