//
//  SignupViewController.m
//  Spotshot
//
//  Created by Evan Latner on 4/16/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "SignupViewController.h"
#import "VideoPreviewViewController.h"
#import "TSMessageView.h"
#import "TSMessage.h"
#import "YZSwipeBetweenViewController.h"




#define SOURCETYPE UIImagePickerControllerSourceTypeCamera
#define iOS7 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)
#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


@interface SignupViewController () <JGActionSheetDelegate> {
    JGActionSheet *_currentAnchoredActionSheet;
    UIView *_anchorView;
    BOOL _anchorLeft;
    JGActionSheet *_simple;
}
@property (nonatomic, strong) YZSwipeBetweenViewController *yzBaby;




@end

@implementation SignupViewController

@synthesize profilePicCell, usernameCell, passwordCell;
@synthesize usernameField, passwordField, profilePic;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Account" message:@"Create a quick profile to share your photos and videos with the world." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
    
    self.navigationController.title = @"Create account";
    self.userScore = [[PFUser currentUser] objectForKey:@"userScore"];
    self.runCount = [[PFUser currentUser] objectForKey:@"runCount"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.automaticallyAdjustsScrollViewInsets = YES;
        
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.yzBaby = [[YZSwipeBetweenViewController alloc] init];
    self.delegate = (id)self.yzBaby;
    [self.delegate performSelector:@selector(disableScroll)];
   
    
    NSShadow *shadowTwo = [[NSShadow alloc] init];
    shadowTwo.shadowColor = [UIColor clearColor];
    shadowTwo.shadowOffset = CGSizeMake(0, .0);
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor colorWithRed:0.322 green:0.545 blue:0.737 alpha:1], NSForegroundColorAttributeName,
                                                                     shadowTwo, NSShadowAttributeName,
                                                                     [UIFont fontWithName:@"AvenirNext-DemiBold" size:23], NSFontAttributeName, nil]];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    profilePic.layer.cornerRadius = profilePic.frame.size.width / 2;
    profilePic.clipsToBounds = YES;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewDidAppear:animated];
    [usernameField becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [self.delegate performSelector:@selector(enableScroll)];
    
}

-(void)addBackButton {
    
    UIImage *buttonImage = [UIImage imageNamed:@"backButton.png"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
    UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    [aButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:aBarButtonItem];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) return profilePicCell;
    if (indexPath.row == 1) return usernameCell;
    if (indexPath.row == 2) return passwordCell;
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 110.0f;
    }
    if (indexPath.row == 1)   {
        return 50.0f;
    }
    if (indexPath.row == 2)   {
        return 50.0f;
    }
    
    return 0;
}



//*********************************************
// Keyboard Button Actions

-(BOOL)textFieldShouldReturn:(UITextField*)textField; {
    
   if ([usernameField isFirstResponder]){
        [passwordField becomeFirstResponder];
    }
    else if ([passwordField isFirstResponder]){
        [passwordField resignFirstResponder];
        [self signup:self];
    }
    return YES;
}
//*********************************************

//*********************************************
// Remove Unwanted Characters from textfield

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    //Remove characters from email & username field
    NSCharacterSet *notAllowedUsernameChars = [NSCharacterSet characterSetWithCharactersInString:@" \\`~!@#$%^&*()-+=,<.>/?;:'[{]}|"];
    
    if (textField == self.usernameField) {
        
    textField.text = [textField.text lowercaseString];
    textField.text = [[textField.text componentsSeparatedByCharactersInSet:notAllowedUsernameChars] componentsJoinedByString:@""];
        return YES;
    }
    return YES;
}
//*********************************************




//*********************************************
// Email and Username Length

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //Username can only be 16 characters long
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 16) ? NO : YES;
    
}
//*********************************************



- (IBAction)addProfilePic:(UIView *)anchor {
    
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
 
    if (!_simple) {
        
        _simple = [JGActionSheet actionSheetWithSections:@[[JGActionSheetSection sectionWithTitle:@"Add Profile Picture" message:@"" buttonTitles:@[@"Take Photo", @"Choose From Library"] buttonStyle:JGActionSheetButtonStyleDefault]]];
        _simple.delegate = self;
        _simple.insets = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
        [_simple setOutsidePressBlock:^(JGActionSheet *sheet) {
            [sheet dismissAnimated:YES];
            
        }];
        
        __unsafe_unretained typeof(self) weakSelf = self;
        
        [_simple setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
            
            if (indexPath.row == 0) {
                
                if ([UIImagePickerController isSourceTypeAvailable:SOURCETYPE]) {
                    
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = weakSelf;
                    picker.allowsEditing = YES;
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [weakSelf presentViewController:picker animated:NO completion:NULL];
                    [sheet dismissAnimated:NO];
                    
                }
                else {
                    //Cannot Take Photo -- Capturing photo's is not supported
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Not Available" message:@"Choose a photo from your library instead." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                    
                }
                
            }
            if (indexPath.row == 1) {
                
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = weakSelf;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [weakSelf presentViewController:picker animated:YES completion:NULL];
                [sheet dismissAnimated:NO];
            }
        }];
    }
    
    if (anchor && iPad) {
        _anchorView = anchor;
        _anchorLeft = YES;
        _currentAnchoredActionSheet = _simple;
        CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(anchor.bounds)};
        p = [self.navigationController.view convertPoint:p fromView:anchor];
        [_simple showFromPoint:p inView:[[UIApplication sharedApplication] keyWindow] arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
    }
    else {
        [_simple showInView:self.navigationController.view animated:YES];
    }

    
    
}

//*********************************************
// Resize the Image Properly

UIImage* ResizeImagePic(UIImage *image, CGFloat width, CGFloat height) {
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//*********************************************


//*********************************************
// Take Picture Canceled

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:NO completion:NULL];
}
//*********************************************





//*********************************************
// Take Picture Or Select Image From Library

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    profilePic.image = self.selectedImage;
    [picker dismissViewControllerAnimated:NO completion:NULL];
    
}
//*********************************************




//*********************************************
// Signup the Current User

- (IBAction)signup:(id)sender {
    
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0) {
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:@"create a username"
                                        type:TSMessageNotificationTypeError];
        
    }
    else if ([password length] == 0) {
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:@"create a password"
                                        type:TSMessageNotificationTypeError];
    }
    
    else if (self.selectedImage == nil) {
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:@"add a profile pic"
                                        type:TSMessageNotificationTypeError];
    }
    
    else {
        
        [PFUser logOut];
        
        if (self.selectedImage.size.width > 140) self.selectedImage = ResizeImagePic(self.selectedImage, 140, 140);
        
        PFFile *filePicture = [PFFile fileWithName:@"picture.png" data:UIImagePNGRepresentation(self.selectedImage)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (error != nil) [ProgressHUD showError:@"Network error"];
        }];
        
        profilePic.image = self.selectedImage;
        
        if (self.selectedImage.size.width > 40) self.selectedImage = ResizeImagePic(self.selectedImage, 40, 40);
        
        PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.png" data:UIImagePNGRepresentation(self.selectedImage)];
        [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) [ProgressHUD showError:@"Network error"];
         }];

        
        PFUser *newUser = [PFUser user];
        newUser.username = username;
        newUser.password = password;
        
        [ProgressHUD show:nil];
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [ProgressHUD showError:@"Network Error"];
                
                if (error.userInfo.count >= 3) {
                    
                    [TSMessage showNotificationWithTitle:nil
                                                subtitle:@"something went wrong, try again"
                                                    type:TSMessageNotificationTypeError];
                    
                    
                }
                else {
                    
                    [TSMessage showNotificationWithTitle:nil
                                                subtitle:[error.userInfo objectForKey:@"error"]
                                                    type:TSMessageNotificationTypeError];
                }
            }
            else {
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                [currentInstallation saveInBackground];
                
                PFUser *user = [PFUser currentUser];
                [user setObject:filePicture forKey:@"profilePic"];
                [user setObject:fileThumbnail forKey:@"thumbnailPic"];
                [user setValue:@"registered" forKey:@"userStatus"];
                [user setValue:@0 forKey:@"postCount"];
                [user setValue:@0 forKey:@"videoViews"];
                [user setObject:self.userScore forKey:@"userScore"];
                //[user setObject:self.runCount forKey:@"runCount"];
                [user setObject:_currentCity forKey:@"userCity"];
                [user setObject:self.userLocation forKey:@"currentLocation"];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (error != nil) {
                        [ProgressHUD showError:@"Network error"];
                    }
                    
                    if (error) {
                        NSLog(@"Error: %@", error);
                    }
                    else {
                        NSLog(@"Successfully Created User");
                        [self.delegate performSelector:@selector(enableScroll)];
                        
//                        VideoCameraController *vcvc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoCamera"];
//                        [self.navigationController pushViewController:vcvc animated:NO];
                        [ProgressHUD dismiss];
                        
                    }
                }];

            }
        }];
    }
}
//*********************************************



@end
