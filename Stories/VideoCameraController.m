////
////  VideoCameraController.m
////  StoriesAWS
////
////  Created by Evan Latner on 3/29/15.
////  Copyright (c) 2015 Evan Latner. All rights reserved.
////
//
//#import "VideoCameraController.h"
//#import <AVFoundation/AVFoundation.h>
//#import "SCAudioTools.h"
//#import "SCRecorderFocusView.h"
//#import "SCRecorder.h"
//#import <AssetsLibrary/AssetsLibrary.h>
//#import "SCRecordSessionManager.h"
//#import <MobileCoreServices/MobileCoreServices.h>
//#import "WelcomeViewController.h"
//
//
//
//#define kVideoPreset AVCaptureSessionPresetLow
//
//@interface VideoCameraController () {
//    SCRecorder *_recorder;
//    UIImage *_photo;
//    SCRecordSession *_recordSession;
//    UIImageView *_ghostImageView;
//}
//
//@property (strong, nonatomic) SCRecorderFocusView *focusView;
//
//@end
//
//@implementation VideoCameraController
//
//@synthesize caption;
//
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    self.device = AVCaptureDevicePositionBack;
//    
////    PFUser *currentuser = [PFUser currentUser];
////    if (currentuser) {
////        [[PFUser currentUser] incrementKey:@"RunCount"];
////        [[PFUser currentUser] saveInBackground];
////        if ([[[PFUser currentUser] objectForKey:@"LocationStatus"] isEqualToString:@"Disabled"]) {
////            WelcomeViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
////            [self.navigationController pushViewController:wvc animated:NO];
////        }
////        else {
////            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
////                self.userLocation = geoPoint;
////            }];
////        }
////    }
////    else {
////        [self performSegueWithIdentifier:@"welcome" sender:self];
////    }
////    if (![PFUser currentUser]) {
////    }
////    else {
//        self.capturePhotoButton.alpha = 0.0;
//        _recorder.recordSession = nil;
//        
//        //Photo Views
//        self.capturedImageView = [[UIImageView alloc]init];
//        self.capturedImageView.frame = self.view.frame; // just to even it out
//        self.capturedImageView.backgroundColor = [UIColor clearColor];
//        self.capturedImageView.userInteractionEnabled = YES;
//        self.capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
//        
//        self.imageSelectedView = [[UIView alloc]initWithFrame:self.view.frame];
//        [self.imageSelectedView setBackgroundColor:[UIColor clearColor]];
//        [self.imageSelectedView addSubview:self.capturedImageView];
//        
//        UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
//        imageViewTap.delegate = (id) self;
//        imageViewTap.numberOfTapsRequired = 1;
//        imageViewTap.numberOfTouchesRequired = 1;
//        [self.capturedImageView addGestureRecognizer:imageViewTap];
//        UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(captionDrag:)];
//        [self.capturedImageView addGestureRecognizer:drag];
//        
//        self.photoOverlayView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-50, CGRectGetWidth(self.view.frame), 50)];
//        [self.photoOverlayView setBackgroundColor:[UIColor clearColor]];
//        [self.imageSelectedView addSubview:self.photoOverlayView];
//        
//        UIButton *cancelPhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(15,16, 38, 38)];//CGRectMake(8, 20, 32, 32)];
//        [cancelPhotoButton setImage:[UIImage imageNamed:@"cancelbutton"] forState:UIControlStateNormal];
//        [cancelPhotoButton addTarget:self action:@selector(cancelSelectedPhoto:) forControlEvents:UIControlEventTouchUpInside];
//        [cancelPhotoButton addTarget:self action:@selector(cancelTextCaption) forControlEvents:UIControlEventTouchUpInside];
//        [self.imageSelectedView addSubview:cancelPhotoButton];
//        
//        self.uploadPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.photoOverlayView.frame)-54, -2, 38, 38)];
//        [self.uploadPhotoButton setImage:[UIImage imageNamed:@"addDos"] forState:UIControlStateNormal];
//        [self.uploadPhotoButton addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self.photoOverlayView addSubview:self.uploadPhotoButton];
//        
//        _recorder = [SCRecorder recorder];
//        _recorder.sessionPreset = [SCRecorderTools bestSessionPresetCompatibleWithAllDevices];
//        _recorder.maxRecordDuration = CMTimeMake(7, 1); //
//        _recorder.delegate = self;
//        _recorder.autoSetVideoOrientation = YES;
//        _recorder.videoOrientation = AVCaptureVideoOrientationPortrait;
//        
//        UIView *previewView = self.previewView;
//        _recorder.previewView = previewView;
//        
//        [self.reverseCamera addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIView *overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-60, CGRectGetWidth(self.view.frame), 60)];
//        [overlayView setBackgroundColor:[UIColor clearColor]];
//        [self.view addSubview:overlayView];
//        
//        self.selfieButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-54, 4.5, 32, 32)];
//        [self.selfieButton setImage:[UIImage imageNamed:@"flipCamTho"] forState:UIControlStateNormal];
//        [self.selfieButton addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
//        [overlayView addSubview:self.selfieButton];
//        
//        self.flash = [[UIButton alloc]initWithFrame:CGRectMake(15, 18, 35, 35)];
//        [self.flash setImage:[UIImage imageNamed:@"flashYo"] forState:UIControlStateNormal];
//        [self.flash setImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateSelected];
//        [self.flash addTarget:self action:@selector(switchFlash:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:self.flash];
//        
//        
//        self.focusView = [[SCRecorderFocusView alloc] initWithFrame:previewView.bounds];
//        self.focusView.recorder = _recorder;
//        [previewView addSubview:self.focusView];
//        
//        self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
//        self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
//        
//        _recorder.initializeRecordSessionLazily = YES;
//        [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
//            [self prepareCamera];
//        }];
//        
//        
//        self.camTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(capturePhoto:)];
//        self.camTap.numberOfTapsRequired = 1;
//        
//        self.cameraButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-42, CGRectGetHeight(self.view.bounds)-95, 85, 85)];
//        [self.cameraButton setImage:[UIImage imageNamed:@"snapPic2"] forState:UIControlStateNormal];
//        [self.cameraButton setImage:[UIImage imageNamed:@"snapVideoSelected"] forState:UIControlStateHighlighted];
//        //[self.cameraButton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
//        [self.cameraButton addGestureRecognizer:self.camTap];
//        [self.cameraButton addTarget:self action:@selector(recordVid) forControlEvents:UIControlEventTouchDown];
//        [self.cameraButton addTarget:self action:@selector(stopVid) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
//        [self.cameraButton setTintColor:[UIColor blueColor]];
//        [self.cameraButton.layer setCornerRadius:20.0];
//        [self.view addSubview:self.cameraButton];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(methodToShowViewOnTop)
//                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
//        
//        self.menu = [[UIButton alloc]initWithFrame:CGRectMake(6, CGRectGetHeight(self.view.frame)-70, 65, 65)];
//        [self.menu setImage:[UIImage imageNamed:@"dasMenu"] forState:UIControlStateNormal];
//        //[self.menu addTarget:self action:@selector(ScrollToHomeView) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:self.menu];
//        
//        [self.videoProgress setTransform:CGAffineTransformMakeScale(1.0, 20.0)];
//        [self.videoProgress setProgress:0.f];
//        
//        
//    //}
//    
//    
//    self.filterSwitcherView = [[SCSwipeableFilterView alloc] initWithFrame:CGRectMake(0,
//                                                                                      0,
//                                                                                      [[UIScreen mainScreen] bounds].size.width,
//                                                                                      [[UIScreen mainScreen] bounds].size.height)];
//    
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
//    longPress.delegate = self;
//    longPress.minimumPressDuration = 0.05;
//    [longPress addTarget:self action:@selector(makeButtonBounce:)];
//    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
//    tap.delegate = self;
//    tap.numberOfTapsRequired = 1;
//    [tap addTarget:self action:@selector(makeButtonBounce:)];
//    
//    [self.menu addGestureRecognizer:longPress];
//    [self.menu addGestureRecognizer:tap];
//    
//    
//}
//
//-(void)makeButtonBounce:(UILongPressGestureRecognizer *)recognizer {
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        
//        NSLog(@"hiiii");
//        [UIView animateWithDuration:0.07 animations:^{
//            self.menu.transform = CGAffineTransformMakeScale(1.30, 1.30);
//            
//        } completion:^(BOOL finished) {
//            self.menu.transform = CGAffineTransformMakeScale(1.26, 1.26);
//            
//        }];
//    }
//    
//    if (recognizer.state == UIGestureRecognizerStateEnded) {
//        self.menu.transform = CGAffineTransformMakeScale(1.0, 1.0);
//        [UIView animateWithDuration:0.14 animations:^{
//            
//            [self ScrollToHomeView];
//            
//        } completion:^(BOOL finished) {
//            NSLog(@"Ended:");
//            
//            self.menu.transform = CGAffineTransformMakeScale(1.0, 1.0);
//        }];
//    }
//}
//
/////********************************************************************
///////PHOTO CAPTION
//- (void)imageViewTapped:(UITapGestureRecognizer *)recognizer {
//    
//    if([UIScreen mainScreen].bounds.size.height <= 568.0) {
//    }
//    else {
//        
//        NSLog(@"Tap tap");
//        caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        caption.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//        if([caption isFirstResponder]){
//            [caption resignFirstResponder];
//            caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
//            
//        } else {
//            if (caption.alpha == 1) {
//            }
//            else {
//                [self initCaption];
//                [caption becomeFirstResponder];
//                caption.alpha = 1;
//            }
//        }
//    }
//}
//- (void) initCaption{
//    
//    caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
//    
//    // Caption
//    caption = [[UITextField alloc] initWithFrame:CGRectMake(0,self.capturedImageView.frame.size.height/2,self.capturedImageView.frame.size.width,40)];
//    caption.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.70];
//    caption.textAlignment = NSTextAlignmentCenter;
//    caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    caption.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    caption.textColor = [UIColor whiteColor];
//    caption.keyboardAppearance = UIKeyboardAppearanceDefault;
//    caption.alpha = 0;
//    caption.tintColor = [UIColor whiteColor];
//    caption.delegate = self;
//    caption.font = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:18];
//    [self.capturedImageView addSubview:caption];
//}
//
//- (void) captionDrag: (UIGestureRecognizer*)gestureRecognizer{
//    
//    CGPoint translation = [gestureRecognizer locationInView:self.view];
//    
//    if(translation.y < caption.frame.size.height/2){
//        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  caption.frame.size.height/2);
//    } else if(self.capturedImageView.frame.size.height < translation.y + caption.frame.size.height/2){
//        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  self.capturedImageView.frame.size.height - caption.frame.size.height/2);
//    } else {
//        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  translation.y);
//    }
//}
//
//-(void)cancelTextCaption {
//    
//    caption.alpha = 0.0;
//    
//    caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
//    
//    [self.caption.text isEqualToString:@""];
//    [caption resignFirstResponder];
//    
//}
//
//- (BOOL)textField:(UITextField *)textField
//shouldChangeCharactersInRange:(NSRange)range
//replacementString:(NSString *)string{
//    
//    NSString *text = textField.text;
//    text = [text stringByReplacingCharactersInRange:range withString:string];
//    CGSize textSize = [text sizeWithAttributes: @{NSFontAttributeName:textField.font}];
//    return (textSize.width + 50 < textField.bounds.size.width) ? true : false;
//}
//
//-(void)textFieldDidBeginEditing:(UITextView *)textField{
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.15];
//    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:caption cache:YES];
//    caption.frame = CGRectMake(0,self.view.frame.size.height/2,self.view.frame.size.width,40);
//    [UIView commitAnimations];
//    
//}
//
//
///////PHOTO CAPTION
/////********************************************************************
//
//
//
/////********************************************************************
///////RECORD VIDEO
//- (void)recordVid {
//    
////    if ([[[PFUser currentUser] objectForKey:@"userStatus"] isEqualToString:@"anon"]) {
////        SignupViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Signup"];
////        svc.userLocation = self.userLocation;
////        svc.recordSession = _recordSession;
////        svc.currentCity = [[PFUser currentUser] objectForKey:@"userCity"];
////        [self.navigationController pushViewController:svc animated:YES];
////        
////    }
////    else {
//        
//        [self.cameraButton removeGestureRecognizer:self.camTap];
//        
//        [UIView animateWithDuration:0.06 delay:0.02 options:0 animations:^{
//            self.cameraButton.transform = CGAffineTransformMakeScale(1.135, 1.135);
//        } completion:^(BOOL finished) {
//            self.cameraButton.transform = CGAffineTransformMakeScale(1.11, 1.11);
//        }];
//        
//        self.menu.hidden = YES;
//        self.flash.hidden = YES;
//        self.selfieButton.hidden = YES;
//        [self.cameraButton setHighlighted:YES];
//        [_recorder record];
//        
//    }
//}
//-(void)stopVid {
//    
//    self.videoProgress.hidden = YES;
//    CMTime currentTime = kCMTimeZero;
//    currentTime = _recorder.recordSession.currentRecordDuration;
//    
//    if (_recorder.recordSession.currentRecordDuration.timescale <= 2) {
//        [_recorder pause];
//        self.menu.hidden = NO;
//        self.flash.hidden = NO;
//        self.selfieButton.hidden = NO;
//        self.videoProgress.hidden = NO;
//    }
//    
//    else {
//        
//        [UIView animateWithDuration:0.10 animations:^{
//            self.cameraButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
//        } completion:nil];
//        
//        [_recorder pause:^{
//            self.cameraButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
//            [self.imageSelectedView removeFromSuperview];
//            [self saveAndShowSession:_recorder.recordSession];
//        }];
//    }
//}
////RECORD VIDEO
/////*********************************************************************
//
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.filterSwitcherView setFilterGroups:nil];
//    
//    self.menu.hidden = NO;
//    self.flash.hidden = NO;
//    self.selfieButton.hidden = NO;
//    self.videoProgress.hidden = NO;
//    self.photoOverlayView.hidden = NO;
//    
//    [self.videoProgress setProgress:0.f];
//    [self prepareCamera];
//    
//    self.navigationController.navigationBarHidden = YES;
//    [self updateTimeRecordedLabel];
//    [self.imageSelectedView removeFromSuperview];
//    [self.cameraButton addGestureRecognizer:self.camTap];
//    
//}
//
//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    
//    [_recorder previewViewFrameChanged];
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [_recorder startRunningSession];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [_recorder endRunningSession];
//    [self.navigationController setNavigationBarHidden:YES];
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    self.navigationController.navigationBarHidden = YES;
//}
//
//#pragma mark - Handle
//
//- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*) message {
//    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//    [alertView show];
//}
//
//- (void)showVideo {
//    
//    VideoPreviewViewController *vpvc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPreview"];
//    vpvc.recordSession = _recordSession;
//    vpvc.userLocation = self.userLocation;
//    [self.navigationController pushViewController:vpvc animated:NO];
//    
//}
//
//- (void) handleReverseCameraTapped:(id)sender {
//    [self selfieButtonBounce];
//    [_recorder switchCaptureDevices];
//    
//    if (self.device == AVCaptureDevicePositionBack) {
//        
//        NSLog(@"Switching to Selfie");
//        self.device = AVCaptureDevicePositionFront;
//        [self.cameraButton addGestureRecognizer:self.camTap];
//    }
//    
//    else {
//        NSLog(@"Switching to Back Cam");
//        self.device = AVCaptureDevicePositionBack;
//        [self.cameraButton addGestureRecognizer:self.camTap];
//    }
//    
//}
//
//- (void)saveAndShowSession:(SCRecordSession *)recordSession {
//    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
//    
//    _recordSession = recordSession;
//    [self showVideo];
//}
//
//- (IBAction)switchFlash:(id)sender {
//    NSString *flashModeString = nil;
//    if ([_recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
//        switch (_recorder.flashMode) {
//            case SCFlashModeAuto:
//                flashModeString = @"Flash : Off";
//                _recorder.flashMode = SCFlashModeOff;
//                break;
//            case SCFlashModeOff:
//                flashModeString = @"Flash : On";
//                _recorder.flashMode = SCFlashModeOn;
//                break;
//            case SCFlashModeOn:
//                flashModeString = @"Flash : Light";
//                _recorder.flashMode = SCFlashModeLight;
//                break;
//            case SCFlashModeLight:
//                flashModeString = @"Flash : Auto";
//                _recorder.flashMode = SCFlashModeAuto;
//                break;
//            default:
//                break;
//        }
//    } else {
//        switch (_recorder.flashMode) {
//            case SCFlashModeOff:
//                flashModeString = @"Flash : On";
//                [self.flash setSelected:YES];
//                _recorder.flashMode = SCFlashModeLight;
//                break;
//            case SCFlashModeLight:
//                flashModeString = @"Flash : Off";
//                [self.flash setSelected:NO];
//                _recorder.flashMode = SCFlashModeOff;
//                break;
//            default:
//                break;
//        }
//    }
//    [self.flashModeButton setTitle:flashModeString forState:UIControlStateNormal];
//}
//
//- (void) prepareCamera {
//    if (_recorder.recordSession == nil) {
//        
//        SCRecordSession *session = [SCRecordSession recordSession];
//        session.fileType = AVFileTypeQuickTimeMovie;
//        _recorder.recordSession = session;
//    }
//}
//
//
//
//
//- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBuffer:(SCRecordSession *)recordSession {
//    [self updateTimeRecordedLabel];
//}
//
//- (IBAction)capturePhoto:(id)sender {
//    
//    if ([[[PFUser currentUser] objectForKey:@"userStatus"] isEqualToString:@"anon"]) {
//        SignupViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Signup"];
//        svc.userLocation = self.userLocation;
//        svc.recordSession = _recordSession;
//        svc.currentCity = [[PFUser currentUser] objectForKey:@"userCity"];
//        [self.navigationController pushViewController:svc animated:YES];
//        
//    }
//    else {
//        
//        [_recorder capturePhoto:^(NSError *error, UIImage *image) {
//            if (image != nil) {
//                
//                [self bounce];
//                
//                
//                
//                //////IF SELFIE TAKEN
//                if (self.device == AVCaptureDevicePositionFront) {
//                    
//                    NSLog(@"selfie was taken");
//                    
//                    UIImage * flippedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
//                    
//                    self.selectedImage = flippedImage;
//                    self.capturedImageView.image = flippedImage;
//                    
//                    [self.view addSubview:self.imageSelectedView];
//                    self.selectedImage = flippedImage;
//                    
//                    [self.filterSwitcherView setImageByUIImage:self.selectedImage];
//                    [self.capturedImageView addSubview:self.filterSwitcherView];
//                    [self.filterSwitcherView setNeedsDisplay];
//                    [self.filterSwitcherView setNeedsLayout];
//                    
//                    
//                    self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
//                    self.filterSwitcherView.filterGroups = @[
//                                                             [NSNull null],
//                                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectTransfer"]],
//                                                             
//                                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectInstant"]]
//                                                             ];
//                    
//                    
//                    [self.capturedImageView addSubview:self.filterSwitcherView];
//                    [self.filterSwitcherView setNeedsDisplay];
//                    [self.filterSwitcherView setNeedsLayout];
//                    
//                }
//                
//                else {
//                    
//                    self.capturedImageView.image = image;
//                    self.selectedImage = image;
//                    [self.view addSubview:self.imageSelectedView];
//                    [self.filterSwitcherView setImageByUIImage:self.selectedImage];
//                    [self.capturedImageView addSubview:self.filterSwitcherView];
//                    [self.filterSwitcherView setNeedsDisplay];
//                    [self.filterSwitcherView setNeedsLayout];
//                    
//                    self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
//                    self.filterSwitcherView.filterGroups = @[
//                                                             [NSNull null],
//                                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectTransfer"]],
//                                                             
//                                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectInstant"]]
//                                                             
//                                                             ];
//                    
//                    [self.capturedImageView addSubview:self.filterSwitcherView];
//                    [self.filterSwitcherView setNeedsDisplay];
//                    [self.filterSwitcherView setNeedsLayout];
//                    
//                }
//                
//                
//            } else {
//                [self showAlertViewWithTitle:@"Failed to capture photo" message:error.localizedDescription];
//            }
//        }];
//    }
//}
//
//-(IBAction)cancelSelectedPhoto:(id)sender {
//    
//    [self.imageSelectedView removeFromSuperview];
//    [self.filterSwitcherView setFilterGroups:nil];
//    
//}
//
///////********************************************************
/////// PHOTO CAPTION
//
//-(void)uploadPhoto {
//    
//    UIImage *filteredImage = [self.filterSwitcherView currentlyDisplayedImageWithScale:self.selectedImage.scale orientation:self.selectedImage.imageOrientation];
//    
//    self.selectedImage = filteredImage;
//    
//    UIGraphicsBeginImageContextWithOptions(self.selectedImage.size, YES, 0.0);
//    [self.selectedImage drawInRect:CGRectMake(0,0,self.selectedImage.size.width,self.selectedImage.size.height)];
//    
//    
//    CGPoint myPoint = caption.center;
//    
//    
//    
//    //FOR SELFIES
//    if (self.device == AVCaptureDevicePositionFront) {
//        
//        
//        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
//            if([UIScreen mainScreen].bounds.size.height <= 568.0) {
//                
//                if ([self.caption.text length] >= 1) {
//                    
//                    NSLog(@"iPhone 4 Selfie");
//                    
//                    UILabel *capLabel = [[UILabel alloc] init];
//                    capLabel.textColor = [UIColor whiteColor];
//                    capLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
//                    capLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:20];
//                    capLabel.text = self.caption.text;
//                    capLabel.numberOfLines = 1;
//                    [capLabel setTextAlignment:NSTextAlignmentCenter];
//                    [capLabel setNeedsDisplay];
//                    [capLabel setNeedsLayout];
//                    
//                    [capLabel setBounds:CGRectMake(0, myPoint.y * 2.15, self.selectedImage.size.width, 38)];
//                    
//                    [capLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
//                    
//                }
//                
//                
//            }
//            
//            
//            
//            else {
//                
//                
//                //iPhone 6
//                if ([self.caption.text length] >= 1) {
//                    
//                    NSLog(@"iPhone 6 Selfie");
//                    
//                    UILabel *capLabel = [[UILabel alloc] init];
//                    capLabel.textColor = [UIColor whiteColor];
//                    capLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.70];
//                    capLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:38];
//                    capLabel.text = self.caption.text;
//                    capLabel.numberOfLines = 1;
//                    [capLabel setTextAlignment:NSTextAlignmentCenter];
//                    [capLabel setNeedsDisplay];
//                    [capLabel setNeedsLayout];
//                    
//                    [capLabel setBounds:CGRectMake(0, myPoint.y * 1.75, self.selectedImage.size.width, 76)];
//                    
//                    [capLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
//                    
//                }
//                
//            }
//        }
//    }
//    
//    
//    /////NOT SELFIES
//    else {
//        
//        
//        ////IPHONE 4
//        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
//            if([UIScreen mainScreen].bounds.size.height <= 568.0) {
//                
//                if ([self.caption.text length] >= 1) {
//                    
//                    NSLog(@"iPhone 4 - no selfie");
//                    
//                    UILabel *capLabel = [[UILabel alloc] init];
//                    capLabel.textColor = [UIColor whiteColor];
//                    capLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
//                    capLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:28];
//                    capLabel.text = self.caption.text;
//                    capLabel.numberOfLines = 1;
//                    [capLabel setTextAlignment:NSTextAlignmentCenter];
//                    [capLabel setNeedsDisplay];
//                    [capLabel setNeedsLayout];
//                    
//                    [capLabel setBounds:CGRectMake(0, myPoint.y * 2.15, self.selectedImage.size.width, 40)];
//                    
//                    [capLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
//                    
//                }
//            }
//            
//            else {
//                
//                //IPHONE 6^
//                if ([self.caption.text length] >= 1) {
//                    
//                    
//                    NSLog(@"i6 no selfie");
//                    
//                    UILabel *capLabel = [[UILabel alloc] init];
//                    capLabel.textColor = [UIColor whiteColor];
//                    capLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
//                    capLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:38];; //92
//                    capLabel.text = self.caption.text;
//                    capLabel.numberOfLines = 1;
//                    [capLabel setTextAlignment:NSTextAlignmentCenter];
//                    [capLabel setNeedsDisplay];
//                    [capLabel setNeedsLayout];
//                    
//                    [capLabel setBounds:CGRectMake(0, myPoint.y * 2.15, self.selectedImage.size.width, 76)];  // was rect
//                    
//                    [capLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
//                    
//                    NSLog(@"Caption: %@", capLabel.layer);
//                    
//                }
//            }
//        }
//    }
//    
//    //// IF SELFIE
//    if (self.device == AVCaptureDevicePositionFront) {
//        
//        /// ON IPHONE 4 -- REDRAW CORRECT SIZE
//        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
//            if([UIScreen mainScreen].bounds.size.height <= 568.0) {
//                
//                NSLog(@"NEW IFFFFFF BABY");
//                UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
//                
//                
//                UIImage *finalImage = myNewImage;
//                
//                
//                if (finalImage.size.width > 140) finalImage = ResizePhoto(finalImage, 240, 320);
//                
//                NSData *imageData = UIImagePNGRepresentation(finalImage);
//                [self uploadToS3:imageData];
//                
//            }
//            
//            else {
//                
//                
//                NSLog(@"Sefie iPhone 6");
//                
//                UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
//                
//                
//                UIImage *finalImage = myNewImage;
//                
//                
//                if (finalImage.size.width > 140) finalImage = ResizePhoto(finalImage, 225, 400); //300x400-240x430-225x400
//                
//                
//                
//                // Upload image******************************************
//                
//                NSData *imageData = UIImagePNGRepresentation(finalImage);
//                [self uploadToS3:imageData];
//                
//                
//                
//                
//            }
//            
//        }
//        
//    }
//    
//    
//    else {
//        
//        NSLog(@"We are here yo");
//        UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        
//        UIImage *finalImage = myNewImage;
//        
//        
//        if (finalImage.size.width > 140) finalImage = ResizePhoto(finalImage, 225, 400); //300 x 400 -- 240 x 430
//        
//        // Upload image******************************************
//        
//        NSData *imageData = UIImagePNGRepresentation(finalImage);
//        [self uploadToS3:imageData];
//        
//    }
//    
//    self.caption.text = nil;
//    caption = nil;
//    [self.filterSwitcherView setFilterGroups:nil];
//    
//}
///////********************************************************
//
//
//-(void)uploadToS3:(NSData *)imgdata {
//    
//    [ProgressHUD show:nil];
//    [self ScrollToHomeView];
//    NSLog(@"upload to S3 yooo");
//    [self.imageSelectedView removeFromSuperview];
//    [self.filterSwitcherView setFilterGroups:nil];
//    
//    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"image.png"];
//    [imgdata writeToFile:path atomically:YES];
//    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
//    
//    _uploadRequest = [AWSS3TransferManagerUploadRequest new];
//    _uploadRequest.bucket = @"storiesbucket";
//    _uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
//    
//    NSString * uuidStr = [[NSUUID UUID] UUIDString];
//    NSString *textBody = @"photos/PIC_KEY-image.png";
//    NSString* newString = [textBody stringByReplacingOccurrencesOfString:@"PIC_KEY" withString:uuidStr];
//    
//    _uploadRequest.key = newString;
//    _uploadRequest.contentType = @"image/png";
//    _uploadRequest.body = url;
//    
//    NSString *daAwsRegion = @"https://s3-us-west-2.amazonaws.com/storiesbucket/";
//    daAwsRegion = [daAwsRegion stringByAppendingString:newString];
//    _awsPicUrl = daAwsRegion;
//    
//    AWSS3TransferManager *manager = [AWSS3TransferManager defaultS3TransferManager];
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    
//    [[manager upload:_uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
//        
//        if (task.error) {
//            
//            NSLog(@"AWS ERROR: %@", task.error);
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//            [ProgressHUD showError:@"Network Error"];
//            
//            
//        }
//        
//        else {
//            
//            NSLog(@"AWS URL: %@", _awsPicUrl);
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//            [self uploadToParse];
//            [ProgressHUD dismiss];
//        }
//        return nil;
//        
//        
//    }];
//}
//
//-(void)uploadToParse {
//    
//    PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
//    [userPhoto setObject:_awsPicUrl forKey:@"imageUrl"];
//    //[userPhoto setObject:self.userLocation forKey:@"postLocation"];
////    [userPhoto setObject:[PFUser currentUser] forKey:@"user"];
////    [userPhoto setObject:[[PFUser currentUser] objectForKey:@"userCity"]  forKey:@"cityName"];
////    [userPhoto setObject:[[PFUser currentUser] objectForKey:@"userCity"]  forKey:@"eventName"];
//    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        
//        if (succeeded) {
//            NSLog(@"Succeeeeeded");
//            [ProgressHUD dismiss];
//            
//        }
//        else {
//            
//            [ProgressHUD showError:@"Network Error"];
//        }
//    }];
//}
//
//- (IBAction)bounce {
//    
//    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
//    animationGroup.duration = 1.1;
//    animationGroup.repeatCount = INFINITY;
//    
//    CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    pulseAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
//    pulseAnimation.duration = .15;
//    pulseAnimation.timingFunction = easeOut;
//    pulseAnimation.autoreverses = YES;
//    animationGroup.animations = @[pulseAnimation];
//    [self.uploadPhotoButton.layer addAnimation:animationGroup forKey:@"animateTranslation"];
//    
//}
//
//-(void)menuButtonBounce {
//    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
//    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    anim.duration = 0.125;
//    anim.repeatCount = 1;
//    anim.autoreverses = YES;
//    anim.removedOnCompletion = YES;
//    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)];
//    [self.menu.layer addAnimation:anim forKey:nil];
//}
//
//-(void)selfieButtonBounce {
//    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
//    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    anim.duration = 0.125;
//    anim.repeatCount = 1;
//    anim.autoreverses = YES;
//    anim.removedOnCompletion = YES;
//    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)];
//    [self.selfieButton.layer addAnimation:anim forKey:nil];
//}
//
//-(void)ScrollToHomeView {
//    //[self menuButtonBounce];
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:0 animated:NO];
//}
//
//-(void)methodToShowViewOnTop{
//    UIImageView *imageView = (UIImageView *)[UIApplication.sharedApplication.keyWindow.subviews.lastObject viewWithTag:101];
//    [imageView removeFromSuperview];
//    [self reloadInputViews];
//}
//
////*********************************************
//// Resize the Image Properly
//
//UIImage* ResizePhoto(UIImage *image, CGFloat width, CGFloat height) {
//    
//    CGSize size = CGSizeMake(width, height);
//    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
//    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}
////*********************************************
//
//
//@end
