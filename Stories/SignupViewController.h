//
//  SignupViewController.h
//  Spotshot
//
//  Created by Evan Latner on 4/16/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "JGActionSheet.h"
#import "SCRecorder.h"
#import "TSMessageView.h"
#import "VideoCameraController.h"

@class SignupViewController;

@protocol SignupViewControllerDelegate <NSObject>

-(void)disableScroll;
-(void)enableScroll;


@end


@interface SignupViewController : UITableViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic,weak) IBOutlet id<SignupViewControllerDelegate> delegate;


@property (strong, nonatomic) IBOutlet UITableViewCell *profilePicCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *passwordCell;

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@property (strong, nonatomic) IBOutlet UIImageView *profilePic;

@property (strong, nonatomic) IBOutlet UIButton *addProfilePic;

@property (nonatomic, strong) PFFile *profileImage;
@property (nonatomic, strong) PFFile *thumbnailImage;

@property (nonatomic, strong) PFGeoPoint *userLocation;
@property (nonatomic, strong) NSString *userScore;
@property (nonatomic, strong) NSString *runCount;
@property (nonatomic, strong) NSString *currentCity;
@property (strong, nonatomic) SCRecordSession *recordSession;


@property (nonatomic, strong) UIImage *selectedImage;


- (IBAction)signup:(id)sender;


- (IBAction)addProfilePic:(id)sender;

@end
