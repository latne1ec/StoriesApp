//
//  CameraViewController.m
//  Stories
//
//  Created by Evan Latner on 1/10/16.
//  Copyright © 2016 stories. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCRecordSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "EditVideoViewController.h"
#import "VerifyEmailTableViewController.h"
#import "StatusTableViewController.h"
#import "Reachability.h"
#import "StoriesTableViewController.h"

#define kVideoPreset AVCaptureSessionPresetHigh

@interface CameraViewController () {
    SCRecorder *_recorder;
    UIImage *_photo;
    SCRecordSession *_recordSession;
    UIImageView *_ghostImageView;
}

@property (strong, nonatomic) SCRecorderToolsView *focusView;
@property (nonatomic) float keyboardOriginY;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic) BOOL accepted;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) UIVisualEffect *blurEffect;

@end

@implementation CameraViewController

@synthesize caption;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _accepted = false;
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,
                                                                           [[UIScreen mainScreen] bounds].size.width,
                                                                           [[UIScreen mainScreen] bounds].size.height)];
    imageView.tag = 101;
    
    if([UIScreen mainScreen].bounds.size.height < 568.0) {
        [imageView setImage:[UIImage imageNamed:@"iphone4Black"]];
    }
    else if([UIScreen mainScreen].bounds.size.height == 568.0) {
        [imageView setImage:[UIImage imageNamed:@"blackScreen"]];
    } else if ([UIScreen mainScreen].bounds.size.height == 667.0) {
        [imageView setImage:[UIImage imageNamed:@"blackScreen6"]];
    } else  if ([UIScreen mainScreen].bounds.size.height == 736.0) {
        [imageView setImage:[UIImage imageNamed:@"6plusBlack"]];
    }
        
    [UIApplication.sharedApplication.keyWindow addSubview:imageView];
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable) {
        //connection unavailable
        UIView *badEmail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:badEmail];
        badEmail.backgroundColor = [UIColor clearColor];
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(0, 0, 300, 100);
        button.center = self.view.center;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:18];
        button.titleLabel.numberOfLines = 2;
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button setTitle:@"Please connect to the internet \n and restart the app." forState:UIControlStateNormal];
        [imageView addSubview:badEmail];
        [badEmail addSubview:button];
        
    } else {
        //connection available
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"accountActivated"] isEqualToString:@"YES"]) {
        //NSLog(@"DOOOOPPEE SON");
        
        [self getUser];
        [UIView animateWithDuration:0.25 delay:.7 options:0 animations:^{
            imageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
        
    } else {
    
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"localUser"] isEqualToString:@"YES"]) {
            
            //User already created, find them
            NSString *userObjectId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userObjectId"];
            PFQuery *query = [PFQuery queryWithClassName:@"CustomUser"];
            [query whereKey:@"objectId" equalTo:userObjectId];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if (error) {
                    //NSLog(@"ERROR: %@", error);
                } else {
                    
                    self.currentUser = object;
                    
                    NSString *userSchool = [object objectForKey:@"userSchool"];
                    [[NSUserDefaults standardUserDefaults] setObject:userSchool forKey:@"userSchool"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    if ([self.currentUser objectForKey:@"emailAddress"] == nil) {
                        
                        VerifyEmailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VerifyEmail"];
                        vc.view.layer.speed = 2.0;
                        vc.currentUser = self.currentUser;
                       [UIView animateWithDuration:0.25 delay:.7 options:0 animations:^{
                           imageView.alpha = 0.0;
                       } completion:^(BOOL finished) {
                           
                       }];
                        
                        [self presentViewController:vc animated:NO completion:nil];
                        
                    }
                    
                    else {
                        [UIView animateWithDuration:0.25 delay:.7 options:0 animations:^{
                            imageView.alpha = 0.0;
                        } completion:^(BOOL finished) {
                        }];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"accountActivated"];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:100] forKey:@"localUserScore"];
                        [[NSUserDefaults standardUserDefaults] synchronize];

                    }
                }
            }];
            
        } else {
            
            //Create User
            PFObject *newUser = [PFObject objectWithClassName:@"CustomUser"];
            [newUser setObject:@"" forKey:@"userSchool"];
            [newUser incrementKey:@"userScore" byAmount:[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"localUserScore"] intValue]]];
            [newUser incrementKey:@"runCount" byAmount:[NSNumber numberWithInt:1]];
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    
                } else {
                    
                    self.currentUser = newUser;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"localUser"];
                    [[NSUserDefaults standardUserDefaults] setObject:newUser.objectId forKey:@"userObjectId"];
                    NSString *userSchool = [newUser objectForKey:@"userSchool"];
                    [[NSUserDefaults standardUserDefaults] setObject:userSchool forKey:@"userSchool"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [currentInstallation setObject:newUser forKey:@"customUser"];
                    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                    }];
                    
                    if ([self.currentUser objectForKey:@"emailAddress"] == nil) {

                        [UIView animateWithDuration:0.25 delay:.7 options:0 animations:^{
                            imageView.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            
                        }];

                        VerifyEmailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VerifyEmail"];
                        vc.view.layer.speed = 2.0;
                        vc.currentUser = self.currentUser;
                        [self presentViewController:vc animated:NO completion:nil];
                        
                    }
                    
                    else {
                        
                        //NSLog(@"We all good");
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"accountActivated"];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:100] forKey:@"localUserScore"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [UIView animateWithDuration:0.25 delay:.7 options:0 animations:^{
                            imageView.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            
                        }];
                    }
                }
            }];
        }
    }
    
    self.capturePhotoButton.alpha = 0.0;
    self.device = AVCaptureDevicePositionBack;
    
    self.capturedImageView = [[UIImageView alloc]init];
    self.capturedImageView.frame = self.view.frame; // just to even it out
    self.capturedImageView.backgroundColor = [UIColor clearColor];
    self.capturedImageView.userInteractionEnabled = YES;
    self.capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.imageSelectedView = [[UIView alloc]initWithFrame:self.view.frame];
    [self.imageSelectedView setBackgroundColor:[UIColor clearColor]];
    [self.imageSelectedView addSubview:self.capturedImageView];
    
    UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    imageViewTap.delegate = (id) self;
    imageViewTap.numberOfTapsRequired = 1;
    imageViewTap.numberOfTouchesRequired = 1;
    [self.capturedImageView addGestureRecognizer:imageViewTap];
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(captionDrag:)];
    [self.capturedImageView addGestureRecognizer:drag];
    
    self.photoOverlayView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-50, CGRectGetWidth(self.view.frame), 50)];
    [self.photoOverlayView setBackgroundColor:[UIColor clearColor]];
    [self.imageSelectedView addSubview:self.photoOverlayView];
    
    
    self.closeButton = [[UIButton alloc]initWithFrame:CGRectMake(8,12, 50, 50)];//CGRectMake(8, 20, 32, 32)];
    [self.closeButton setImage:[UIImage imageNamed:@"cancelNew"] forState:UIControlStateNormal];
    [self.imageSelectedView addSubview:self.closeButton];

    UILongPressGestureRecognizer *cancelButtonPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doThis:)];
    cancelButtonPress.delegate = (id)self;
    cancelButtonPress.minimumPressDuration = 0.01;
    [self.closeButton addGestureRecognizer:cancelButtonPress];
    
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    _recorder.maxRecordDuration = CMTimeMake(7, 1);
    //_recorder.fastRecordMethodEnabled = true;
    _recorder.mirrorOnFrontCamera = YES;

    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = NO;
    
    self.previewView = [[UIView alloc] initWithFrame:self.view.frame];
    
    [self.view addSubview:self.previewView];
    
    self.previewView.bounds = self.view.bounds;
    
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    
    [self.retakeButton addTarget:self action:@selector(handleRetakeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self action:@selector(handleStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.reverseCamera addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.loadingView.hidden = YES;
    
    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:previewView.bounds];
    self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
        
    self.focusView.tapToFocusEnabled = YES;
        self.focusView.delegate = self;
    
    _recorder.initializeSessionLazily = NO;
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        //NSLog(@"Prepare error: %@", error.localizedDescription);
    }
    
    self.camTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(capturePhoto:)];
    self.camTap.numberOfTapsRequired = 1;

    
    self.cameraButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-42, CGRectGetHeight(self.view.bounds)-95, 85, 85)];
    [self.cameraButton setImage:[UIImage imageNamed:@"snapPic2"] forState:UIControlStateNormal];
    [self.cameraButton setImage:[UIImage imageNamed:@"snapVideoSelected"] forState:UIControlStateHighlighted];
    [self.cameraButton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
    //[self.cameraButton addGestureRecognizer:self.camTap];
    
    UILongPressGestureRecognizer *camPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recordVideo:)];
    camPress.minimumPressDuration = 0.20;
    camPress.delegate = self;
    
    [self.cameraButton addGestureRecognizer:camPress];
    
    //[self.cameraButton addTarget:self action:@selector(recordVid) forControlEvents:UIControlEventTouchDown];
    //[self.cameraButton addTarget:self action:@selector(stopVid) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    //[self.cameraButton setTintColor:[UIColor blueColor]];
    [self.cameraButton.layer setCornerRadius:20.0];
    [self.view addSubview:self.cameraButton];
    
    self.flashButton = [[UIButton alloc]initWithFrame:CGRectMake(14, 17, 33, 33)];
    [self.flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    [self.flashButton setImage:[UIImage imageNamed:@"flashSelectedTwo"] forState:UIControlStateSelected];
    [self.flashButton addTarget:self action:@selector(switchFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.flashButton setSelected:YES];
    [self.view addSubview:self.flashButton];
    
    self.menu = [[UIButton alloc]initWithFrame:CGRectMake(6, CGRectGetHeight(self.view.frame)-70, 68, 68)];
    [self.menu setImage:[UIImage imageNamed:@"dasMenu"] forState:UIControlStateNormal];
    //[self.menu addTarget:self action:@selector(ScrollToHomeView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menu];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    longPress.delegate = self;
    longPress.minimumPressDuration = 0.05;
    [longPress addTarget:self action:@selector(makeButtonBounce:)];

    [self.menu addGestureRecognizer:longPress];
    //[self.menu addGestureRecognizer:tap];
    
    self.selfieButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-47, 18, 38, 36)];
    [self.selfieButton setImage:[UIImage imageNamed:@"flipCamTho"] forState:UIControlStateNormal];
    [self.selfieButton addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.selfieButton];
    
    [self.videoProgress setTransform:CGAffineTransformMakeScale(1.0, 20.0)];
    
    [self.videoProgress setTransform:CGAffineTransformMakeScale(1.0, 20.0)];
    [self.videoProgress setProgress:0.f];
    
    UILongPressGestureRecognizer *longPressTwo = [[UILongPressGestureRecognizer alloc] init];
    longPressTwo.delegate = self;
    longPressTwo.minimumPressDuration = 0.05;
    [longPressTwo addTarget:self action:@selector(makeUploadButtonBounce:)];

    self.uploadPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.photoOverlayView.frame)-57, -5, 44, 44)];
    [self.uploadPhotoButton setImage:[UIImage imageNamed:@"addDos"] forState:UIControlStateNormal];
    //[self.uploadPhotoButton addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [self.uploadPhotoButton addGestureRecognizer:longPressTwo];

    [self.photoOverlayView addSubview:self.uploadPhotoButton];
    
    
    self.filterSwitcherView = [[SCSwipeableFilterView alloc] initWithFrame:CGRectMake(0,
                                                                                                                                                                            0,
                                                                                                                                                                            [[UIScreen mainScreen] bounds].size.width,
                                                                                                                                                                            [[UIScreen mainScreen] bounds].size.height)];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appClosed) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResign) name:UIApplicationWillResignActiveNotification object:nil];

}


-(void)appClosed{
    
    [ProgressHUD dismiss];
    [UIApplication sharedApplication].statusBarHidden = YES;
    
}

-(void)appWillResign {
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"localUser"] isEqualToString:@"YES"]) {
        if (self.currentUser != nil) {
            int currentUserScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"localUserScore"] intValue];
            int currentStoryViewCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"storyViewCount"] intValue];
            [self.currentUser setObject:[NSNumber numberWithInt:currentUserScore] forKey:@"userScore"];
            [self.currentUser setObject:[NSNumber numberWithInt:currentStoryViewCount] forKey:@"storyViewCount"];
            [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error) {
                    
                } else {
                }
            }];
        }
    }
}

-(void)hideBlackView {
    
    [UIView animateWithDuration:0.12 animations:^{
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)recorderToolsView:(SCRecorderToolsView *)recorderToolsView didTapToFocusWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
}

-(void)recordVideo:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {

        [self.cameraButton setHighlighted:YES];
        self.videoProgress.hidden = NO;
        
        [self.cameraButton removeGestureRecognizer:self.camTap];
        
        [UIView animateWithDuration:0.06 delay:0.02 options:0 animations:^{
            [self.cameraButton setHighlighted:YES];
            self.cameraButton.transform = CGAffineTransformMakeScale(1.135, 1.135);
        } completion:^(BOOL finished) {
            [self.cameraButton setHighlighted:YES];
            self.cameraButton.transform = CGAffineTransformMakeScale(1.11, 1.11);
        }];
        
        self.menu.hidden = YES;
        self.flashButton.hidden = YES;
        self.selfieButton.hidden = YES;
        [_recorder record];

    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        self.videoProgress.hidden = YES;
     
        [UIView animateWithDuration:0.10 animations:^{
            self.cameraButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
        
        [_recorder pause:^{
            self.cameraButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
            //[self.imageSelectedView removeFromSuperview];
            [self saveAndShowSession:_recorder.session];
        }];
    }
}

-(void)makeButtonBounce:(UILongPressGestureRecognizer *)recognizer {

    if (recognizer.state == UIGestureRecognizerStateBegan) {

        [UIView animateWithDuration:0.076 animations:^{
            self.menu.transform = CGAffineTransformMakeScale(1.32, 1.32);

        } completion:^(BOOL finished) {
            self.menu.transform = CGAffineTransformMakeScale(1.28, 1.28);

        }];
    }

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.menu.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [UIView animateWithDuration:0.08 animations:^{

            [self ScrollToHomeView];

        } completion:^(BOOL finished) {

            self.menu.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    }
}

-(void)makeUploadButtonBounce:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:0.12 animations:^{
            self.uploadPhotoButton.transform = CGAffineTransformMakeScale(1.30, 1.30);
            
        } completion:^(BOOL finished) {
            self.uploadPhotoButton.transform = CGAffineTransformMakeScale(1.26, 1.26);
            
        }];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        //self.uploadPhotoButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [UIView animateWithDuration:0.1 animations:^{
        } completion:^(BOOL finished) {
            [self uploadPhoto];
            self.uploadPhotoButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    }
}

-(IBAction)cancelSelectedPhoto:(id)sender {
    
    [self.imageSelectedView removeFromSuperview];
    [self.filterSwitcherView setFilters:nil];
    
    self.closeButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
    
    self.menu.hidden = NO;
    self.flashButton.hidden = NO;
    self.selfieButton.hidden = NO;

    
}

-(void)ScrollToHomeView {
    
   [UIView animateWithDuration:0.02 animations:^{
       
       AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
       [appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:0 animated:NO];

   } completion:^(BOOL finished) {
       self.menu.transform = CGAffineTransformMakeScale(1.0, 1.0);
   }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    int currentUserScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"localUserScore"] intValue];
    
    if (currentUserScore == 99) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
        [self viewDidLoad];
    }
    
    [self prepareSession];
    [self updateTimeRecordedLabel];
    
    self.navigationController.navigationBarHidden = YES;
    
    [UIView animateWithDuration:0.06 delay:0.02 options:0 animations:^{
        self.cameraButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
    }];

    
    [self.imageSelectedView removeFromSuperview];
    [self.cameraButton addGestureRecognizer:self.camTap];
    
    self.menu.hidden = NO;
    self.flashButton.hidden = NO;
    self.selfieButton.hidden = NO;
    [self.videoProgress setProgress:0.f animated:NO];
    self.videoProgress.hidden = YES;
    [self.cameraButton setHighlighted:NO];

}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorder startRunning];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focus)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    //[self performSelector:@selector(focus) withObject:nil afterDelay:2.0];
    
}

-(void)focus {
    CGPoint point = CGPointMake(250, 250);
    [_recorder autoFocusAtPoint:point];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_recorder stopRunning];
    
    [self.flashButton setSelected:YES];
    
    [UIView animateWithDuration:0.04 animations:^{
        self.cameraButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:nil];
}

///********************************************************************
/////PHOTO CAPTION
- (void)imageViewTapped:(UITapGestureRecognizer *)recognizer {
    
    caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    caption.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    if([caption isFirstResponder]){
        [caption resignFirstResponder];
        caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
        
    } else {
        if (caption.alpha == 1) {
        }
        else {
            [self initCaption];
            [caption becomeFirstResponder];
            caption.alpha = 1;
        }
    }
}

- (void) initCaption{
    
    caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
    
    caption = [[UITextField alloc] initWithFrame:CGRectMake(0,self.capturedImageView.frame.size.height/2+80,self.capturedImageView.frame.size.width,40)];
    
    caption.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
    caption.textAlignment = NSTextAlignmentCenter;
    caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    caption.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    caption.textColor = [UIColor whiteColor];
    caption.keyboardAppearance = UIKeyboardAppearanceDefault;
    caption.alpha = 0;
    caption.tintColor = [UIColor whiteColor];
    caption.delegate = self;
    caption.font = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:18];
    [self.capturedImageView addSubview:caption];
}

- (void) captionDrag: (UIGestureRecognizer*)gestureRecognizer{
    
    CGPoint translation = [gestureRecognizer locationInView:self.view];
    
    if(translation.y < caption.frame.size.height/2){
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  caption.frame.size.height/2);
    } else if(self.capturedImageView.frame.size.height < translation.y + caption.frame.size.height/2){
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  self.capturedImageView.frame.size.height - caption.frame.size.height/2);
    } else {
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  translation.y);
    }
}

-(void)cancelTextCaption {
    
    caption.alpha = 0.0;
    
    caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
    
    [self.caption.text isEqualToString:@""];
    [caption resignFirstResponder];
    
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string{
    
    NSString *text = textField.text;
    text = [text stringByReplacingCharactersInRange:range withString:string];
    CGSize textSize = [text sizeWithAttributes: @{NSFontAttributeName:textField.font}];
    return (textSize.width + 50 < textField.bounds.size.width) ? true : false;
}

-(void)textFieldDidBeginEditing:(UITextView *)textField{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.15];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:caption cache:YES];
    caption.frame = CGRectMake(0,self.view.frame.size.height/2+31,self.view.frame.size.width,40);
    //[self setKeyboardFrame];
    [UIView commitAnimations];
    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField; {
    
    [caption resignFirstResponder];
    
    return YES;
}

-(void)setKeyboardFrame {
    
    [UIView animateWithDuration:0.06 animations:^{
         caption.frame = CGRectMake(0,_keyboardOriginY-42,self.view.frame.size.width,40);
    } completion:^(BOOL finished) {
        
    }];
}


-(void)keyboardOnScreen:(NSNotification *)notification {
    
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    _keyboardOriginY = keyboardFrame.origin.y;
    [self setKeyboardFrame];
}

/////PHOTO CAPTION
///********************************************************************

#pragma mark - Handle

- (void)showVideo {
    EditVideoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditVideo"];
    vc.recordSession = _recordSession;
    vc.currentUser = self.currentUser;
    [self.navigationController pushViewController:vc animated:NO];
    
}

- (void)showPhoto:(UIImage *)photo {
    _photo = photo;
    [self performSegueWithIdentifier:@"Photo" sender:self];
}

- (void) handleReverseCameraTapped:(id)sender {
    [self selfieButtonBounce];
        [_recorder switchCaptureDevices];
    
        if (self.device == AVCaptureDevicePositionBack) {
    
            self.device = AVCaptureDevicePositionFront;
            //[self.cameraButton addGestureRecognizer:self.camTap];
        }
    
        else {
            self.device = AVCaptureDevicePositionBack;
            //[self.cameraButton addGestureRecognizer:self.camTap];
        }
}

-(void)selfieButtonBounce {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.125;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)];
    [self.selfieButton.layer addAnimation:anim forKey:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *url = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    SCRecordSessionSegment *segment = [SCRecordSessionSegment segmentWithURL:url info:nil];
    
    [_recorder.session addSegment:segment];
    _recordSession = [SCRecordSession recordSession];
    [_recordSession addSegment:segment];
    
    [self showVideo];
}
- (void) handleStopButtonTapped:(id)sender {
    [_recorder pause:^{
        [self saveAndShowSession:_recorder.session];
    }];
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    
    _recordSession = recordSession;
    [self showVideo];
}

- (void)handleRetakeButtonTapped:(id)sender {
    SCRecordSession *recordSession = _recorder.session;
    
    if (recordSession != nil) {
        _recorder.session = nil;
        
        // If the recordSession was saved, we don't want to completely destroy it
        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
            [recordSession endSegmentWithInfo:nil completionHandler:nil];
        } else {
            [recordSession cancelSession:nil];
        }
    }
    
    [self prepareSession];
}

- (IBAction)switchCameraMode:(id)sender {
    if ([_recorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.capturePhotoButton.alpha = 0.0;
            self.recordView.alpha = 1.0;
            self.retakeButton.alpha = 1.0;
            self.stopButton.alpha = 1.0;
        } completion:^(BOOL finished) {
            _recorder.captureSessionPreset = kVideoPreset;
            [self.switchCameraModeButton setTitle:@"Switch Photo" forState:UIControlStateNormal];
            [self.flashModeButton setTitle:@"Flash : Off" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeOff;
        }];
    } else {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recordView.alpha = 0.0;
            self.retakeButton.alpha = 0.0;
            self.stopButton.alpha = 0.0;
            self.capturePhotoButton.alpha = 1.0;
        } completion:^(BOOL finished) {
            _recorder.captureSessionPreset = AVCaptureSessionPresetPhoto;
            [self.switchCameraModeButton setTitle:@"Switch Video" forState:UIControlStateNormal];
            [self.flashModeButton setTitle:@"Flash : Auto" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeAuto;
        }];
    }
}

- (IBAction)switchFlash:(id)sender {
    NSString *flashModeString = nil;
    if ([_recorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        switch (_recorder.flashMode) {
            case SCFlashModeAuto:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                [self.flashButton setSelected:NO];

                break;
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeOn;
                [self.flashButton setSelected:YES];

                break;
            case SCFlashModeOn:
                flashModeString = @"Flash : Light";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Auto";
                _recorder.flashMode = SCFlashModeAuto;
                break;
            default:
                break;
        }
    } else {
        switch (_recorder.flashMode) {
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeLight;
                [self.flashButton setSelected:NO];

                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                [self.flashButton setSelected:YES];

                break;
            default:
                break;
        }
    }
    
    [self.flashModeButton setTitle:flashModeString forState:UIControlStateNormal];
}

- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }    
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    [self saveAndShowSession:recordSession];
}

- (IBAction)bounce {
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1.1;
    animationGroup.repeatCount = INFINITY;
    
    CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    pulseAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    pulseAnimation.duration = .15;
    pulseAnimation.timingFunction = easeOut;
    pulseAnimation.autoreverses = YES;
    animationGroup.animations = @[pulseAnimation];
    [self.uploadPhotoButton.layer addAnimation:animationGroup forKey:@"animateTranslation"];
    
}

- (IBAction)capturePhoto:(id)sender {

        [_recorder capturePhoto:^(NSError *error, UIImage *image) {
            if (image != nil) {

                if (self.flashButton.selected) {
                    
                } else {
                    [self performSelector:@selector(switchFlash:) withObject:nil afterDelay:0.1];
                }
                    
                [self bounce];
                
                //////IF SELFIE TAKEN
                if (self.device == AVCaptureDevicePositionFront) {

                    UIImage * flippedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];

                    self.selectedImage = flippedImage;
                    self.capturedImageView.image = flippedImage;

                    [self.view addSubview:self.imageSelectedView];
                    self.selectedImage = flippedImage;
                    
                    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
                        //NSLog(@"Version: %f", NSFoundationVersionNumber);
                        
                    } else {
                    
                        [self.filterSwitcherView setImageByUIImage:self.selectedImage];
                        [self.capturedImageView addSubview:self.filterSwitcherView];
                        [self.filterSwitcherView setNeedsDisplay];
                        [self.filterSwitcherView setNeedsLayout];

                        self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
                        
                        SCFilter *emptyFilter = [SCFilter emptyFilter];
                        
                        self.filterSwitcherView.filters = @[
                                                            emptyFilter,
                                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectFade"],
                                                            [SCFilter filterWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"a_filter" withExtension:@"cisf"]],
                                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectTonal"],
                                                            ];

                        [self.capturedImageView addSubview:self.filterSwitcherView];
                        [self.filterSwitcherView setNeedsDisplay];
                        [self.filterSwitcherView setNeedsLayout];
                        
                    }
                    
                }

                else {

                    self.capturedImageView.image = image;
                    self.selectedImage = image;
                    [self.view addSubview:self.imageSelectedView];
                    
                    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
                        //NSLog(@"Version: %f", NSFoundationVersionNumber);
                        
                    } else {

                        [self.filterSwitcherView setImageByUIImage:self.selectedImage];
                        [self.capturedImageView addSubview:self.filterSwitcherView];
                        [self.filterSwitcherView setNeedsDisplay];
                        [self.filterSwitcherView setNeedsLayout];
                        
                        self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
                        SCFilter *emptyFilter = [SCFilter emptyFilter];
                        
                        self.filterSwitcherView.filters = @[
                                                            emptyFilter,
                                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectFade"],
                                                            [SCFilter filterWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"a_filter" withExtension:@"cisf"]],
                                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectTonal"],
                                                            ];

                        
                        [self.capturedImageView addSubview:self.filterSwitcherView];
                        [self.filterSwitcherView setNeedsDisplay];
                        [self.filterSwitcherView setNeedsLayout];

                    }
                }

            } else {
            }
        }];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBuffer:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
}

- (void)updateTimeRecordedLabel {
    
    [self.cameraButton setHighlighted:YES];
    
    CMTime currentTime = kCMTimeZero;
    if (_recorder.session != nil) {
        currentTime = _recorder.session.currentSegmentDuration;
    }
    [self.view addSubview:self.videoProgress];
    
    self.timeRecordedLabel.text = [NSString stringWithFormat:@"Recorded - %.2f sec", CMTimeGetSeconds(currentTime)];
    float dur = CMTimeGetSeconds(currentTime);
    float durMili = dur*205;
    [self.videoProgress setProgress:durMili animated:YES];
    
    
    if (dur >= 7) {
        //NSLog(@"Time: %f", dur);
        [self saveAndShowSession:_recorder.session];
    }
}


- (IBAction)switchGhostMode:(id)sender {
    _ghostModeButton.selected = !_ghostModeButton.selected;
    _ghostImageView.hidden = !_ghostModeButton.selected;
    
}

- (IBAction)closeCameraTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)uploadPhoto {

    //[ProgressHUD show:nil Interaction:NO];
    
    //Show Loader
    [[NSNotificationCenter defaultCenter] postNotificationName:@"show_loader" object:self];
    
    [self ScrollToHomeView];
    
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        //NSLog(@"Version: %f", NSFoundationVersionNumber);
        
    } else{
     
        UIImage *filteredImage = [self.filterSwitcherView renderedUIImage];
        
        self.selectedImage = filteredImage;
    }

    UIGraphicsBeginImageContextWithOptions(self.selectedImage.size, YES, 0.0);
    [self.selectedImage drawInRect:CGRectMake(0,0,self.selectedImage.size.width,self.selectedImage.size.height)];
    
    
    UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();


    UIImage *finalImage = myNewImage;


    if (finalImage.size.width > 140) finalImage = ResizePhoto(finalImage, 225, 400); //300 x 400 -- 240 x 430

    // Upload image******************************************

    NSData *imageData = UIImagePNGRepresentation(finalImage);
    [self uploadToS3:imageData];

    [self.filterSwitcherView setFilters:nil];

}

UIImage* ResizePhoto(UIImage *image, CGFloat width, CGFloat height) {

    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)uploadToS3:(NSData *)imgdata {

    //[self ScrollToHomeView];
    //NSLog(@"upload to S3 yooo");
    [self.imageSelectedView removeFromSuperview];
    [self.filterSwitcherView setFilters:nil];

    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"image.png"];
    [imgdata writeToFile:path atomically:YES];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];

    _uploadRequest = [AWSS3TransferManagerUploadRequest new];
    _uploadRequest.bucket = @"storiescontentbucket";
    _uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;

    int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"localUserScore"] intValue];
    

    NSString *randomId = [[NSUUID UUID] UUIDString];
    
    NSString * uuidStr = [NSString stringWithFormat:@"%@-%d-%@", self.currentUser.objectId, i, randomId];
    
    NSString *textBody = @"posts/PIC_KEY-image.png";
    NSString* newString = [textBody stringByReplacingOccurrencesOfString:@"PIC_KEY" withString:uuidStr];

    _uploadRequest.key = newString;
    _uploadRequest.contentType = @"image/png";
    _uploadRequest.body = url;

    NSString *daAwsRegion = @"http://d267cblbp4esvr.cloudfront.net/";
    daAwsRegion = [daAwsRegion stringByAppendingString:newString];
    _awsPicUrl = daAwsRegion;

    AWSS3TransferManager *manager = [AWSS3TransferManager defaultS3TransferManager];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [[manager upload:_uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {

        if (task.error) {

            //NSLog(@"AWS ERROR: %@", task.error);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            //Hide Loader
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hide_loader" object:self];
            [ProgressHUD showError:@"network error"];

        }

        else {

            //NSLog(@"AWS URL: %@", _awsPicUrl);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self uploadToParse];
            [ProgressHUD dismiss];
            //Hide Loader
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hide_loader" object:self];

        }
        return nil;
    }];
}

-(void)uploadToParse {
    
    NSString *userSchool = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];

    PFObject *userPhoto = [PFObject objectWithClassName:@"UserContent"];
    [userPhoto setObject:_awsPicUrl forKey:@"imageUrl"];
    
    float height = [[UIScreen mainScreen] bounds].size.height;
    
    NSString *capLoc = [NSString stringWithFormat:@"%f", caption.frame.origin.y/height];
    
   if ([self.caption.text length] >= 1) {
        [userPhoto setObject:caption.text forKey:@"contentCaption"];
        [userPhoto setObject:capLoc forKey:@"captionLocation"];
    }
    
    [userPhoto setObject:@"photo" forKey:@"postType"];
    [userPhoto setObject:@"pending" forKey:@"postStatus"];
    [userPhoto setObject:userSchool forKey:@"userSchool"];
    [userPhoto setObject:self.currentUser forKey:@"user"];
    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        if (succeeded) {

            [ProgressHUD dismiss];
            
            [self checkIfUserEnabledPush];
            
            //Increment Score
            int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"localUserScore"] intValue];
            [[NSUserDefaults standardUserDefaults] setInteger:i+1 forKey:@"localUserScore"];
            
            self.caption.text = nil;
            caption = nil;

        }
        else {
            //Hide Loader
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hide_loader" object:self];
            [ProgressHUD showError:@"network error"];
        }
    }];
}

-(void)checkIfUserEnabledPush {

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"askToEnablePushV1.04"] isEqualToString:@"YES"]) {
        
    } else {
        
        [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.2];
    }
}

-(void)showAlert {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"askToEnablePushV1.04"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //NSString *school = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
    NSString *message = [NSString stringWithFormat:@"Want to get notified when your post is published?"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enable notifications" message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yeah", nil];
    [alertView show];
    
    alertView.tag = 101;
    alertView.delegate = self;
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
    if (alertView.tag == 101) {
        
        if (buttonIndex == 0) {
            
        } else {
            
            [self askToEnablePush];
        }
    }
}

-(void)askToEnablePush {
    
    AppDelegate *appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appD askUserToEnablePushInAppDelgate];
    
}


-(void)doThis: (UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:0.08 animations:^{
            //NSLog(@"Started");
            self.closeButton.transform = CGAffineTransformMakeScale(1.4, 1.4);
            
        } completion:^(BOOL finished) {
            //NSLog(@"FINISHED");
            
        }];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.07 animations:^{
            ///NSLog(@"Started");
            self.closeButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
            
        } completion:^(BOOL finished) {
            //NSLog(@"FINISHED");
            [self cancelSelectedPhoto:self];
            [self cancelTextCaption];
        }];
    }
}

-(void)getUser {
    
    NSString *userObjectId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userObjectId"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"CustomUser"];
    [query whereKey:@"objectId" equalTo:userObjectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            
            if(error.code == kPFErrorConnectionFailed) {
                
                [self showNoInternetError];
            }
        } else {
            //NSLog(@"Got User: %@", object);
            self.currentUser = object;
            
            NSString *userSchool = [object objectForKey:@"userSchool"];
            NSString *userStatus = [object objectForKey:@"userStatus"];
            NSString *universityStatus = [object objectForKey:@"universityStatus"];
            [[NSUserDefaults standardUserDefaults] setObject:userSchool forKey:@"userSchool"];
            [[NSUserDefaults standardUserDefaults] setObject:userStatus forKey:@"userStatus"];
            [[NSUserDefaults standardUserDefaults] setObject:universityStatus forKey:@"universityStatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"justReloadTheTable" object:self];
            [self.currentUser incrementKey:@"runCount"];
            [self.currentUser saveEventually];
        }
    }];
}


-(void)showNoInternetError {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,
                                                                           [[UIScreen mainScreen] bounds].size.width,
                                                                           [[UIScreen mainScreen] bounds].size.height)];
    imageView.tag = 101;
    [imageView setImage:[UIImage imageNamed:@"black"]];
    
    UIView *badEmail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:badEmail];
    badEmail.backgroundColor = [UIColor clearColor];
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(0, 0, 300, 100);
    button.center = self.view.center;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:18];
    button.titleLabel.numberOfLines = 2;
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button setTitle:@"Please connect to the internet \n and restart the app." forState:UIControlStateNormal];
    [imageView addSubview:badEmail];
    [badEmail addSubview:button];

}

@end
