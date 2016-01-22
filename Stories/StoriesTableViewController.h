//
//  StoriesTableViewController.h
//  Stories
//
//  Created by Evan Latner on 2/27/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeTableCell.h"
#import "FeaturedTableCell.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import <ParseUI/ParseUI.h>
#import "AppDelegate.h"
//#import "KASlideShow.h"
#import "SDWebImageManager.h"
#import "SignupViewController.h"
#import "SDWebImageManager.h"
#import "UnlockTableCell.h"


@class MainStoriesViewController;

@interface StoriesTableViewController : UITableViewController <CLLocationManagerDelegate, UISearchBarDelegate, UIViewControllerTransitioningDelegate>


//@property (nonatomic, strong) NSArray *stories;
@property (nonatomic, strong) NSMutableArray *stories;
@property (nonatomic, strong) PFObject *home;
@property (nonatomic, strong) PFGeoPoint *userLocation;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *score;
@property (nonatomic, strong) UILongPressGestureRecognizer *longTap;
//@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSString *currentCity;
@property (nonatomic, strong) MainStoriesViewController *storyOne;
@property (nonatomic, strong) PFObject *searchedStory;
@property (nonatomic, readonly) NSUInteger currentIndex;
@property (nonatomic, strong) UIButton *camButtonBottom;

@property (nonatomic, strong) PFObject *currentUser;
@property (nonatomic, strong) PFObject *university;




@property (nonatomic, strong) UITapGestureRecognizer *tapp;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)inviteButtonTapped:(id)sender;

@end
