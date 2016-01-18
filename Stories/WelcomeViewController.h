//
//  WelcomeViewController.h
//  Stories
//
//  Created by Evan Latner on 2/19/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "StoriesTableViewController.h"

@interface WelcomeViewController : UIViewController <CLLocationManagerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *okButton;

- (IBAction)createUser:(id)sender;


+(CLAuthorizationStatus)authorizationStatus;

@property (nonatomic, strong) PFGeoPoint *userLocation;
@property (nonatomic, strong) CLLocationManager *locaManager;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundPic;

@property (nonatomic, assign) UIScrollView *scrollView;


- (IBAction)linkToTerms:(id)sender;




@end
