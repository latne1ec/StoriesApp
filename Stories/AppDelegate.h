//
//  AppDelegate.h
//  Stories
//
//  Created by Evan Latner on 1/7/16.
//  Copyright © 2016 stories. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZSwipeBetweenViewController.h"
#import <Parse/Parse.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) YZSwipeBetweenViewController *swipeBetweenVC;
@property (nonatomic, strong) PFObject *currentUser;
@property (nonatomic) BOOL accepted;


-(void)setupRootViewControllerForWindow;
//-(void)askUserToEnablePushInAppDelgate;
-(void)setOneSignalTag;
-(void)registerUserForOneSignalPushNotifications;
-(void)saveOneSignalPlayerId:(PFObject *)forUser;

@end

