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




@interface StoriesTableViewController () <SSARefreshControlDelegate> {
    
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
@property (nonatomic, strong) SSARefreshControl *refreshControl;

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



-(BOOL)prefersStatusBarHidden {
    
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self queryForHomePic];
    
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
    [self performSelector:@selector(reloadTableview) withObject:nil afterDelay:0.50];
    
//    self.refreshControl = [[SSARefreshControl alloc] initWithScrollView:self.tableView andRefreshViewLayerType:SSARefreshViewLayerTypeOnScrollView];
//    self.refreshControl.delegate = self;
    
    [self createPresentControllerButton];
    [self createTransition];
    [self updateUserScore];
 
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


- (void)beganRefreshing {
    
    [self queryForHomePic];
    
}

-(void)reloadTableview {
    [self.tableView reloadData];
}

-(void)showScore {
    
    [self.view shake:12   // 10 times
           withDelta:5    // 5 points wide
            andSpeed:0.05 // 30ms per shake
     ];
    
}

-(void)refreshYo {
    
    [self queryForHomePic];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    
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

    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Home";
    static NSString *CellIdentifier2 = @"Unlock";
    
    HomeTableCell *cell = (HomeTableCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HomeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    UnlockTableCell *cell2 = (UnlockTableCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    if (cell2 == nil) {
        cell2 = [[UnlockTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
    }
    
    if (indexPath.section == 0) {
    
        NSString *userSchool = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
        cell.homeName.text = userSchool;
        
        
        if (indexPath.row == 0) {
            
            cell.homeStoryImage.layer.cornerRadius = cell.homeStoryImage.frame.size.width / 2;
            cell.homeStoryImage.clipsToBounds = YES;
            
            NSString *urlString = [self.home objectForKey:@"imageUrl"];
            if (urlString == nil) {
                
            } else {
                
                [cell.homeStoryImage sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@""]];
            }
        }
        
        if (indexPath.row == 1) {
            
            cell2.inviteButton.layer.cornerRadius = 5.0;
            cell2.separatorInset = UIEdgeInsetsMake(0.f, 10000.0f, 0.f, 0.0f);
            
            return cell2;
        }
        
        return cell;
        
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        HomeTableCell *cell = (HomeTableCell *) [tableView cellForRowAtIndexPath:indexPath];
        self.transition.animatedView = cell.homeStoryImage;
        ViewContentViewController *pmvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewContent"];
        pmvc.modalPresentationStyle = UIModalPresentationCustom;
        pmvc.transitioningDelegate = self;
        [self presentViewController:pmvc animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 72.0f;
    }
    if (indexPath.row == 1)   {
        return 220.0f;
    }
    
    return 0;
}

- (IBAction)showCamera:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:1];
    
}


-(void)endRefresh {
    
    [self.refreshControl endRefreshing];
    
}

///************************************
//Get Home Image Pic

- (PFQuery *)queryForHomePic {
    
    [self updateUserScore];
    NSString *school = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
    NSLog(@"User School: %@", school);
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserContent"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"postStatus" equalTo:@"approved"];
    [query whereKey:@"userSchool" equalTo:school];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            self.home = object;
            [self.tableView reloadData];

            [self performSelector:@selector(endRefresh) withObject:nil afterDelay:1.15];
            
        }
        
        if (self.home == nil) {
            NSLog(@"NiLLLLL");
        }
        
        if (error) {
        }
    }];
    return nil;
}

///************************************



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


- (IBAction)inviteButtonTapped:(id)sender {
    
    NSString* newString = @"Hey, download Spotshot to unlock our school.";
    
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
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
    }];

}

@end
