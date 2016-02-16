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
#import <OneSignal/OneSignal.h>


@interface AppDelegate ()

@property (strong, nonatomic) OneSignal *oneSignal;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _accepted = false; 

    [Parse setApplicationId:@"UaGnyAmcvVo2aDaCaHf0bnNm0c5IyjyiSCSip75i"
                  clientKey:@"CR1zqHWJ8FdsZWgf43IjSJbxuckMT83UZRCS7Kba"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFImageView class];
    
    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions
                                                        appId:@"04fae8ff-9222-499e-83c0-1a39b7146593"
                                           handleNotification:^(NSString *message, NSDictionary *additionalData, BOOL isActive) {
                                               
                                               //NSLog(@"OneSignal Notification opened:\nMessage: %@", message);
                                               if (additionalData) {
                                                   //NSLog(@"additionalData: %@", additionalData);
                                                   NSString* customKey = additionalData[@"customKey"];
                                                   if (customKey)
                                                       NSLog(@"");
                                               }
                                               
                                           } autoRegister:false];
    
    [self.oneSignal enableInAppAlertNotification:true];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"hasRanApp"] isEqualToString:@"YES"]) {        

    } else {
        
        [[NSUserDefaults standardUserDefaults] setInteger:98 forKey:@"localUserScore"];
        [[NSUserDefaults standardUserDefaults] setObject:0 forKey:@"storyViewCount"];
        [[NSUserDefaults standardUserDefaults] setObject:0 forKey:@"storyViewCountReplayed"];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasRanApp"];
        [[NSUserDefaults standardUserDefaults] setObject:@"Unknown" forKey:@"userSchool"];
        [[NSUserDefaults standardUserDefaults] setObject:@"Unknown" forKey:@"userSchoolId"];
        [[NSUserDefaults standardUserDefaults] setObject:@"1.0" forKey:@"appVersion"];
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

-(void)setOneSignalTag {
    
    [self.oneSignal IdsAvailable:^(NSString* userId, NSString* pushToken) {
        //NSLog(@"UserId:%@", userId);
        if (pushToken != nil)
            NSLog(@"pushToken");
    }];

    //NSLog(@"set One Signal tag");
    NSString *userObjectId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userObjectId"];
    NSString *userSchoolId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchoolId"];
    NSString *appVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"appVersion"];
    
    [self.oneSignal sendTags:(@{@"userObjectId" : userObjectId, @"userSchoolId" : userSchoolId, @"appVersion" : appVersion}) onSuccess:^(NSDictionary *result) {
        //NSLog(@"success");
        
    } onFailure:^(NSError *error) {
        //NSLog(@"didnt save yet: %@", error);
        [self setOneSignalTag];
    }];
}

-(void)saveOneSignalPlayerId:(PFObject *)forUser {
    
    NSString *onesignalId = [[NSUserDefaults standardUserDefaults] objectForKey:@"alreadySavedOneSignalPlayerId"];
    
    if ([onesignalId isEqualToString:@"YES"]) {
        
    } else {

        [self.oneSignal IdsAvailable:^(NSString* userId, NSString* pushToken) {
            
            [forUser setObject:userId forKey:@"oneSignalId"];
            [forUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error) {
                    
                } else {
                 
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"alreadySavedOneSignalPlayerId"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }];
            
        }];
    }
}

-(void)registerUserForOneSignalPushNotifications {

    [self.oneSignal registerForPushNotifications];
}

- (void)setupRootViewControllerForWindow {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navCon1 = [storyboard instantiateViewControllerWithIdentifier:@"CameraNav"];
    UINavigationController *navCon2 = [storyboard instantiateViewControllerWithIdentifier:@"StoriesNav"];
    
    self.swipeBetweenVC.viewControllers = @[navCon2, navCon1];
    self.swipeBetweenVC.initialViewControllerIndex = (NSInteger)self.swipeBetweenVC.viewControllers.count/2;
    
}

//-(void)askUserToEnablePushInAppDelgate {
//    
//    UIApplication *application = [UIApplication sharedApplication];
//    
//    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
//                                                        UIUserNotificationTypeBadge |
//                                                        UIUserNotificationTypeSound);
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
//                                                                                 categories:nil];
//        [application registerUserNotificationSettings:settings];
//        [application registerForRemoteNotifications];
//    } else {
//        // Register for Push Notifications before iOS 8
//        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
//                                                         UIRemoteNotificationTypeAlert |
//                                                         UIRemoteNotificationTypeSound)];
//    }
//}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
//    NSString *userSchool = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
//    
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    [currentInstallation setDeviceTokenFromData:deviceToken];
//    currentInstallation.channels = @[ @"global", userSchool ];
//    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        if (error) {
//        } else {
//        }
//    }];
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
