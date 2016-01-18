//
//  WelcomeViewController.m
//  Stories
//
//  Created by Evan Latner on 2/19/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "WelcomeViewController.h"
#import "VideoCameraController.h"


@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

@synthesize okButton;
@synthesize userLocation;
@synthesize locaManager;
@synthesize backgroundPic;
@synthesize scrollView;


-(BOOL)prefersStatusBarHidden {
    
    return NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CALayer *btnLayer = [okButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:3.5f];
    
    self.navigationItem.hidesBackButton = YES;
    
    
    self.locaManager = [[CLLocationManager alloc] init];
    
    self.locaManager.delegate = self;
    
    self.scrollView.delegate = self;
    
    
    self.scrollView.scrollEnabled = NO;
    
    
    
    
}



- (IBAction)createUser:(id)sender {
    

    
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] incrementKey:@"RunCount"];
    [[PFUser currentUser] setValue:@"anon" forKey:@"userStatus"];
    [[PFUser currentUser] incrementKey:@"userScore" byAmount:[NSNumber numberWithInt:100]];
    [[PFUser currentUser] saveInBackground];
    NSLog(@"Created User");
    
    if ([self.locaManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locaManager requestWhenInUseAuthorization];
    }
    [self.locaManager startUpdatingLocation];

    
    [self getLocation];
        
    
}


-(void)getLocation {
    
    if([PFUser currentUser]) {
        
        
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            
            [[PFUser currentUser] setValue:@"Enabled" forKey:@"LocationStatus"];
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
            
            self.userLocation = geoPoint;
            
            if (!error) {
                
                [self shouldWePopHome];
                
                
            }
            
            if (error) {
                
                [ProgressHUD showError:@"Network Error"];
                
            }
            
        }];
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
 
    NSLog(@"finally");
    
    
    [[PFUser currentUser] setValue:@"Disabled" forKey:@"LocationStatus"];
    [[PFUser currentUser] setValue:@"anon" forKey:@"userStatus"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            
            NSLog(@"saved");
            
        }
        
    }];
    
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hold up" message:@"Spotshot needs your location in order to work. To enable location services, go to your settings, tap privacy, tap locations services, find Stories and turn it on." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
    
    
}

-(void)shouldWePopHome {
    
    [ProgressHUD show:nil];
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        
        NSLog(@"YOOOOOO");
        
        [[PFUser currentUser] setValue:@"Enabled" forKey:@"LocationStatus"];
        [[PFUser currentUser] setValue:@"anon" forKey:@"userStatus"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                [ProgressHUD dismiss];
               // VideoCameraController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoCamera"];
                //[self.navigationController pushViewController:vc animated:NO];
                
                
            }
            
            if (error) {
                
                [ProgressHUD showError:@"Network Error"];
                
            }
        }];
        
        

    }
    

    else {
        
            NSLog(@"denied access");
        

    }
    
}

-(void)viewWillDisappear:(BOOL)animated {
      
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.navigationController.navigationBar.hidden = NO;
    
    
}

 

- (IBAction)linkToTerms:(id)sender {
    
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://grubhunt.co/terms.html"]];
    
}
@end
