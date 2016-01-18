//
//  AppDelegate.m
//  Stories
//
//  Created by Evan Latner on 1/7/16.
//  Copyright © 2016 stories. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <AWSCore/AWSCore.h>



@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _accepted = false;

    [Parse setApplicationId:@"UaGnyAmcvVo2aDaCaHf0bnNm0c5IyjyiSCSip75i"
                  clientKey:@"CR1zqHWJ8FdsZWgf43IjSJbxuckMT83UZRCS7Kba"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFImageView class];
    
    if([UIScreen mainScreen].bounds.size.height <= 568.0) {
        
        NSLog(@"iPhone 4 or 5");
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        shadow.shadowOffset = CGSizeMake(0, .0);
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.322 green:0.545 blue:0.737 alpha:1], NSForegroundColorAttributeName,
                                                              shadow, NSShadowAttributeName,
                                                              [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:26], NSFontAttributeName, nil]];
    }
    
    else {
        
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        shadow.shadowOffset = CGSizeMake(0, .0);
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.322 green:0.545 blue:0.737 alpha:1], NSForegroundColorAttributeName,
                                                              shadow, NSShadowAttributeName,
                                                              [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:27], NSFontAttributeName, nil]];
    }
    
    if ([PFUser currentUser]) {
        
    } else {
        [PFUser enableAutomaticUser];
        [[PFUser currentUser] setObject:@"pending" forKey:@"userStatus"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
        }];
    }
    
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"hasRanAppV1"] isEqualToString:@"YES"]) {
        //do something
    } else {
        
        NSString *userId = [[NSUUID UUID] UUIDString];
        
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"userId"];
        [[NSUserDefaults standardUserDefaults] setInteger:98 forKey:@"localUserScore"];
        [[NSUserDefaults standardUserDefaults] setObject:0 forKey:@"storyViewCount"];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasRanAppV1"];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"userId"];
        [[NSUserDefaults standardUserDefaults] setObject:@"Unknown" forKey:@"userSchool"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"localUser"] isEqualToString:@"YES"]) {
//        //do something
//        
//        //int currentUserScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"localUserScore"] intValue];
//        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
//        
//        PFQuery *query = [PFQuery queryWithClassName:@"CustomUser"];
//        [query whereKey:@"userId" equalTo:userId];
//        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//            if (error) {
//                
//            } else {
//                
//                self.currentUser = object;
//                [self.currentUser setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"] forKey:@"userSchool"];
//                 
//                NSLog(@"User: %@", [object objectForKey:@"userStatus"]);
//                
//            }
//        }];
//        
//    } else {
//        
//        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
//        
//        PFObject *newUser = [PFObject objectWithClassName:@"CustomUser"];
//        [newUser setObject:userId forKey:@"userId"];
//        [newUser setObject:@"Locked 🔒" forKey:@"userSchool"];
//        [newUser incrementKey:@"userScore" byAmount:[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"localUserScore"] intValue]]];
//        [newUser incrementKey:@"runCount"];
//        [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (error) {
//                
//            } else {
//                
//                _currentUser = newUser;
//                NSLog(@"NEW USER: %@", newUser);
//                
//                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"localUser"];
//                 [[NSUserDefaults standardUserDefaults] setObject:newUser.objectId forKey:@"userObjectId"];
//                
//                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//                [currentInstallation setObject:newUser forKey:@"customUser"];
//                [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                    
//                }];
//            }
//        }];
//    }
    
    
    self.swipeBetweenVC = [YZSwipeBetweenViewController new];
    [self setupRootViewControllerForWindow];
    self.window.rootViewController = self.swipeBetweenVC;
    
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:1 animated:NO];

    
    [self.window makeKeyAndVisible];
    
    
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:071bc929-229a-4a61-8e99-063d4b14083e"];
    
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest1
                                                                         credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    
    return YES;
}

- (void)setupRootViewControllerForWindow{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navCon1 = [storyboard instantiateViewControllerWithIdentifier:@"CameraNav"];
    UINavigationController *navCon2 = [storyboard instantiateViewControllerWithIdentifier:@"StoriesNav"];
    
    self.swipeBetweenVC.viewControllers = @[navCon2, navCon1];
    self.swipeBetweenVC.initialViewControllerIndex = (NSInteger)self.swipeBetweenVC.viewControllers.count/2;

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
