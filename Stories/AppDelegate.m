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
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"hasRanAppV1.1.1"] isEqualToString:@"YES"]) {
        //do something
    } else {
        
        [[NSUserDefaults standardUserDefaults] setInteger:98 forKey:@"localUserScore"];
        [[NSUserDefaults standardUserDefaults] setObject:0 forKey:@"storyViewCount"];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasRanAppV1.1.1"];
        [[NSUserDefaults standardUserDefaults] setObject:@"Unknown" forKey:@"userSchool"];
        [[NSUserDefaults standardUserDefaults] setObject:@"Unknown" forKey:@"userSchoolId"];
        [[NSUserDefaults standardUserDefaults] setObject:@"1.1.1" forKey:@"appVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
        
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

- (void)setupRootViewControllerForWindow {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navCon1 = [storyboard instantiateViewControllerWithIdentifier:@"CameraNav"];
    UINavigationController *navCon2 = [storyboard instantiateViewControllerWithIdentifier:@"StoriesNav"];
    
    self.swipeBetweenVC.viewControllers = @[navCon2, navCon1];
    self.swipeBetweenVC.initialViewControllerIndex = (NSInteger)self.swipeBetweenVC.viewControllers.count/2;

}

-(void)askUserToEnablePushInAppDelgate {
    
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *userSchool = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global", userSchool ];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
        } else {
        }
    }];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
