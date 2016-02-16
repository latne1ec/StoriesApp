//
//  StoriesTableViewController.m
//  Stories
//
//  Created by Evan Latner on 2/27/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "StoriesTableViewController.h"
#import "SDWebImageManager.h"
#import "SCLAlertView.h"
#import "UIView+Shake.h"
#import "UIView+Toast.h"
#import "SSARefreshControl.h"
#import "ViewContentViewController.h"
#import "JTMaterialTransition.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "CameraViewController.h"
#import <OneSignal/OneSignal.h>
#import "MyPostsTableCell.h"



@interface StoriesTableViewController ()  {
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@property(nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic) UIButton *presentControllerButton;
@property (nonatomic) JTMaterialTransition *transition;
@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSDictionary *dasDic;
@property (nonatomic, strong) NSMutableArray *dicArray;
@property (nonatomic, strong) MainStoriesViewController *daMvc;
//@property (nonatomic, strong) SSARefreshControl *refreshControl;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) OneSignal *oneSignal;

@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic, strong) NSMutableArray *myPosts;
@property (nonatomic, strong) SDWebImageManager *manager;


@end

@implementation StoriesTableViewController 

@synthesize stories;
@synthesize score;
@synthesize longTap;
@synthesize refreshControl;
@synthesize currentCity;
@synthesize searchBar;
@synthesize searchedStory;
@synthesize currentIndex;

bool uploadingPost;


-(BOOL)prefersStatusBarHidden {
    
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [[SDWebImageManager alloc] init];
    
    self.content = [[NSMutableArray alloc] init];
    
    
    if([UIScreen mainScreen].bounds.size.height <= 568.0) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        shadow.shadowOffset = CGSizeMake(0, .0);
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.322 green:0.545 blue:0.737 alpha:1], NSForegroundColorAttributeName,
                                                              shadow, NSShadowAttributeName,
                                                              [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:27.5], NSFontAttributeName, nil]];
    } else {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        shadow.shadowOffset = CGSizeMake(0, .0);
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.322 green:0.545 blue:0.737 alpha:1], NSForegroundColorAttributeName,
                                                              shadow, NSShadowAttributeName,
                                                              [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:29], NSFontAttributeName, nil]];
    }
    
    uploadingPost = false;
    
    [self queryForHomePic];
    
    NSString *universityStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"universityStatus"];
    if ([universityStatus isEqualToString:@"approved"]) {
    } else {
       [self countUsers];
    }
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
        
    self.title = @"stories";
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.322 green:0.545 blue:0.737 alpha:1]];
    
    [self.tableView setScrollsToTop:YES];
    
        if([UIScreen mainScreen].bounds.size.height <= 568.0) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"camBlueNew"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(showCamera:)];
            
            [score setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont boldSystemFontOfSize:19], NSFontAttributeName,
                                           [UIColor colorWithRed:0.322 green:0.545 blue:0.737 alpha:1], NSForegroundColorAttributeName,
                                           nil]
                                 forState:UIControlStateNormal];

            
        }
    
    else {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"camBlueNew"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(showCamera:)];
        
        [score setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont boldSystemFontOfSize:21], NSFontAttributeName,
                                       [UIColor colorWithRed:0.322 green:0.545 blue:0.737 alpha:1], NSForegroundColorAttributeName,
                                       nil]
                             forState:UIControlStateNormal];
        
        }
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    self.tableView.tableFooterView = [UIView new];
    
    [self createPresentControllerButton];
    [self createTransition];
    [self updateUserScore];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDasTable) name:@"reload_data" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableview) name:@"justReloadTheTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeHomePic) name:@"change_home_pic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoader) name:@"show_loader" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoader) name:@"hide_loader" object:nil];
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.indicator.frame = CGRectMake(9.4, 9.4, 30.0, 30.0);
    self.indicator.layer.cornerRadius = self.indicator.frame.size.width / 2;
    //self.indicator.center = cell.homeStoryImage.center;
    self.indicator.layer.speed = 1.5;
    self.indicator.alpha = 0.725;
    [self.indicator setHidden:YES];
    self.indicator.hidden = YES;
    
    //[self getMyPosts];
    
    [self addSubtitle];

}

-(void)showLoader {
    
    uploadingPost = true;
    self.tableView.allowsSelection = NO;
    HomeTableCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.homeStoryImage.alpha = 0.65;
    [self.indicator setHidden:NO];
    [self.indicator startAnimating];
}

-(void)hideLoader {
    [self performSelector:@selector(queryForHomePic) withObject:nil afterDelay:0.10];
    uploadingPost = false;
    self.tableView.allowsSelection = YES;
    HomeTableCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.homeStoryImage.alpha = 0.94;
    [self.indicator setHidden:YES];
    [self.indicator stopAnimating];
    self.tableView.allowsSelection = YES;
    [self.tableView reloadData];
    self.subtitleLabel.hidden = YES;

}


-(void)changeHomePic {

    [self queryForHomePic];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.tableView reloadData];
}

-(void)reloadDasTable {
    
    [self.tableView reloadData];
    [self queryForHomePic];
    [self countUsers];

}

-(void)updateUserScore {
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *daScore = [formatter stringFromNumber:[[NSUserDefaults standardUserDefaults] objectForKey:@"localUserScore"]];
    NSString *textBody = @" score";
    NSString* newString = [textBody stringByReplacingOccurrencesOfString:@"score" withString:daScore];
    self.score.title = newString;
    [score setTarget:self];
    [score setAction:@selector(showScore)];

}

//*********************************************
// Dismiss Active Keyboard

- (void) dismissKeyboard {
    // add self
    [self.searchBar resignFirstResponder];
}
//*********************************************


-(void)reloadTableview {
    [self.tableView reloadData];
}

-(void)showScore {
    [self.view shake:12 withDelta:5 andSpeed:0.05];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [self dismissKeyboard];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor colorWithRed:0.984 green:0.984 blue:0.984 alpha:1]];
     
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13]];
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor colorWithRed:0.329 green:0.302 blue:0.302 alpha:1]];
 
    if (section == 0) {
        return @"Home";
    }
    if (section == 1) {
        return @"Featured";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        
        return 1;
        
//        if (self.myPosts.count > 0) {
//            return 2;
//        } else {
//         return 1;
//        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Home";
    static NSString *CellIdentifier2 = @"Me";
    
    HomeTableCell *cell = (HomeTableCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HomeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    MyPostsTableCell *cell2= (MyPostsTableCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    if (cell == nil) {
        cell = [[HomeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    
    NSString *universityStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"universityStatus"];
    NSString *userSchool  = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
    NSString *userStatus  = [[NSUserDefaults standardUserDefaults] objectForKey:@"userStatus"];
    
    NSString *lastSeenContentId  = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSeenContentId"];
    
    if (indexPath.section == 0) {
    
        if (indexPath.row == 0) {
            
            if (![universityStatus isEqualToString:@"approved"]) {
                cell.homeName.text = [NSString stringWithFormat:@"%@ 🔒", userSchool];
            } else if (![userStatus isEqualToString:@"approved"]) {
                cell.homeName.text = [NSString stringWithFormat:@"%@ 🔒", userSchool];
            } else {
                cell.homeName.text = userSchool;
            }
            
            [cell.homeStoryImage addSubview:self.indicator];
            
            cell.homeStoryImage.layer.cornerRadius = cell.homeStoryImage.frame.size.width / 2;
            cell.homeStoryImage.clipsToBounds = YES;
            
            
            if (uploadingPost) {
                [self.indicator setHidden:NO];
                [self.indicator startAnimating];
            } else {
                [self.indicator setHidden:YES];
                [self.indicator stopAnimating];
            }
            
            NSString *urlString = [self.home objectForKey:@"imageUrl"];
            if (urlString == nil) {
                
            } else {
            
                NSURL *url = [NSURL URLWithString:urlString];
                [self.manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    
                }
                                         completed:^(UIImage *images, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                             if (finished) {
                                                 cell.homeStoryImage.image = images;
                                                 cell.homeStoryImage.alpha = 0.96;
                                                 [self addCaption];
                                                 if ([self.home.objectId isEqualToString:lastSeenContentId]) {
                                                     
                                                     cell.homeStoryImage.alpha = 0.60;
                                                     cell.homeName.alpha = 0.60;
                                                 }
                                             }
                                             
                                         }];
                 
            //[self addCaption];
                [cell.homeStoryImage bringSubviewToFront:self.indicator];
            
                if ([self.home.objectId isEqualToString:lastSeenContentId]) {

                    cell.homeStoryImage.alpha = 0.60;
                    cell.homeName.alpha = 0.60;
                }
            }
        }
        
        if (indexPath.row == 1) {
        
            cell2.myPostImage.layer.cornerRadius = cell.homeStoryImage.frame.size.width / 2;
            cell2.myPostImage.clipsToBounds = YES;
            cell2.myPostImage.alpha = 0.96;
            
            return cell2;
        }
        return cell;
    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *userSchool = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
    NSString *universityStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"universityStatus"];
    NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"userStatus"];
    
    if (indexPath.row == 0) {
        
        if (![universityStatus isEqualToString:@"approved"]) {
            
            int userCount = [[self.university objectForKey:@"registeredUserCount"] intValue];
            int userThreshold = [[self.university objectForKey:@"userThreshold"] intValue];
            int remainingCount = userThreshold - userCount;
            
            NSString *title = [NSString stringWithFormat:@"%@ locked", [userSchool capitalizedString]];
            NSString *message = [NSString stringWithFormat:@"Only %d more students needed to unlock. Invite your friends and spread the word.", remainingCount];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Cancel", @"Invite friends", nil];
            alert.tag = 200;
            alert.delegate = self;
            [alert show];

        }
        
        else if (![userStatus isEqualToString:@"approved"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account pending" message:@"Check your email and activate your account to unlock. Check your spam folder if you didn't receive the email in your primary inbox." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [alert show];
            
        } else {
            
            HomeTableCell *cell = (HomeTableCell *) [tableView cellForRowAtIndexPath:indexPath];
            self.transition.animatedView = cell.homeStoryImage;
            ViewContentViewController *pmvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewContent"];
            pmvc.modalPresentationStyle = UIModalPresentationCustom;
            pmvc.transitioningDelegate = self;
            [self presentViewController:pmvc animated:NO completion:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 72.0f;
    }
    if (indexPath.row == 1)   {
        return 72.0f;
    }
    
    return 0;
}

- (IBAction)showCamera:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:1];
}

-(void)endRefresh {
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

///************************************
//Get Home Image Pic

- (PFQuery *)queryForHomePic {
    
    //[self updateUserScore];
    //NSString *school = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
    NSString *userSchoolId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchoolId"];
        
    PFQuery *query = [PFQuery queryWithClassName:@"UserContent"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"postStatus" equalTo:@"approved"];
    [query whereKey:@"userSchoolId" equalTo:userSchoolId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            self.home = object;
            [self.tableView reloadData];
            [self performSelector:@selector(endRefresh) withObject:nil afterDelay:0.650];
            
        } if (error) {
            [self.refreshControl endRefreshing];
        }
    }];
    return nil;
}

///************************************


-(void)countUsers {
    
    NSString *userSchool = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"] lowercaseString];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Universities"];
    [query whereKey:@"universityName" equalTo:[userSchool capitalizedString]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            //[ProgressHUD showError:@"Network Error"];
        } else {
            self.university = object;
            int userCount = [[self.university objectForKey:@"registeredUserCount"] intValue];
            int userThreshold = [[self.university objectForKey:@"userThreshold"] intValue];
            
            NSString *schoolId = object.objectId;
            
            NSString *userSchoolId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchoolId"];

            
            if ([userSchoolId isEqualToString:@"Unknown"]) {
                [[NSUserDefaults standardUserDefaults] setObject:schoolId forKey:@"userSchoolId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self queryForHomePic];

            } else {
                [[NSUserDefaults standardUserDefaults] setObject:schoolId forKey:@"userSchoolId"];
                [[NSUserDefaults standardUserDefaults] synchronize];

            }
            
            if (userCount >= userThreshold) {
                
                [self updateUserStatus];
                    
            } else {
            }
        }
    }];
}

-(void)updateUserStatus {
    
    NSString *userObjectId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userObjectId"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"CustomUser"];
    [query whereKey:@"objectId" equalTo:userObjectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
        } else {
            self.currentUser = object;
            [self.currentUser setObject:@"approved" forKey:@"universityStatus"];
            [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    
                } else {
                    [ProgressHUD dismiss];
                    [[NSUserDefaults standardUserDefaults] setObject:@"approved" forKey:@"universityStatus"];
                    [self.tableView reloadData];
                }
            }];
        }
    }];
}


//**********************************

-(void)checkIfUserEnabledPush {
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"askToEnablePushV1.0"] isEqualToString:@"YES"]) {
        
    } else {

        [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.1];
    }
}

-(void)showAlert {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"askToEnablePushV1.0"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *school = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
    NSString *message = [NSString stringWithFormat:@"Want to get notified when %@ is unlocked?", school];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enable notifications" message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yeah", nil];
    [alertView show];
    
    alertView.tag = 101;
    alertView.delegate = self;
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
    if (alertView.tag == 101) {
        
        if (buttonIndex == 0) {
            
        } else {
            
            //[self askToEnablePush];
            
            
            AppDelegate *appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appD registerUserForOneSignalPushNotifications];
            
        }
    } else if (alertView.tag == 200) {
        
        if (buttonIndex == 0) {
            
            NSString *universityStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"universityStatus"];
            if ([universityStatus isEqualToString:@"pending"]) {
                [self checkIfUserEnabledPush];
            }
            
        } else {
            
            [self inviteButtonTapped:self];
        }
    }
}

//-(void)askToEnablePush {
//    
//    AppDelegate *appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appD askUserToEnablePushInAppDelgate];
//    
//}

//**********************************


- (IBAction)inviteButtonTapped:(id)sender {
    
    NSString *link = [[NSUserDefaults standardUserDefaults] objectForKey:@"appLink"];
    NSString* newString = [NSString stringWithFormat:@"%@", link];
    
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
    [self presentViewController:activityVC animated:YES completion:^{
        
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }];
}


- (void)createPresentControllerButton {
    self.presentControllerButton = [[UIButton alloc] initWithFrame:CGRectMake(32, CGRectGetHeight(self.view.frame)-74, 50, 50)];
}
- (void)createTransition {
    self.transition = [[JTMaterialTransition alloc] initWithAnimatedView:self.presentControllerButton];
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.transition.reverse = NO;
    return self.transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    self.transition.reverse = YES;
    return self.transition;
}

-(void)addSubtitle {
    
    HomeTableCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    self.subtitleLabel = [[UILabel alloc] init];
    
    self.subtitleLabel.frame = CGRectMake(0,0, cell.homeStoryImage.frame.size.width, 5);
    [self.subtitleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:2.5]];
    
    self.subtitleLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.50];
    self.subtitleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.98];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    
    [cell.homeStoryImage addSubview:self.subtitleLabel];
    self.subtitleLabel.hidden = YES;

}

-(void)addCaption {
    
    HomeTableCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    CGFloat yOrigin = [[self.home objectForKey:@"captionLocation"] floatValue];
    float height = 48.0f;
    
    CGRect frame = self.subtitleLabel.frame;
    frame.origin.x = 0;
    frame.origin.y = yOrigin*height;
    self.subtitleLabel.frame = frame;
    
    self.subtitleLabel.text = [self.home objectForKey:@"contentCaption"];
    
    if ([[self.home objectForKey:@"contentCaption"] length] > 0) {
        
        self.subtitleLabel.hidden = NO;
        [cell.homeStoryImage bringSubviewToFront:self.subtitleLabel];
        
    } else {
        self.subtitleLabel.hidden = YES;
    }
}

-(void)getMyPosts {
    
    NSString *userObjectId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userObjectId"];
    
    PFQuery *q = [PFQuery queryWithClassName:@"UserContent"];
    [q whereKey:@"userObjectId" equalTo:userObjectId];
    [q findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            
        } else {
            
            self.myPosts = [objects mutableCopy];
            NSArray* reversedArray = [[self.myPosts reverseObjectEnumerator] allObjects];
            self.myPosts = [reversedArray mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

@end
