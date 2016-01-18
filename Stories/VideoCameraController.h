////
////  VideoCameraController.h
////  StoriesAWS
////
////  Created by Evan Latner on 3/29/15.
////  Copyright (c) 2015 Evan Latner. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//#import "SCRecorder.h"
//#import "VideoPreviewViewController.h"
//#import "SCSwipeableFilterView.h"
//
//
//@interface VideoCameraController : UIViewController <SCRecorderDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>
//
//@property (weak, nonatomic) IBOutlet UIView *recordView;
//@property (weak, nonatomic) IBOutlet UIButton *stopButton;
//@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
//@property (weak, nonatomic) IBOutlet UIView *previewView;
//@property (weak, nonatomic) IBOutlet UIView *loadingView;
//@property (weak, nonatomic) IBOutlet UILabel *timeRecordedLabel;
//@property (weak, nonatomic) IBOutlet UIView *downBar;
//@property (weak, nonatomic) IBOutlet UIButton *switchCameraModeButton;
//@property (weak, nonatomic) IBOutlet UIButton *reverseCamera;
//@property (weak, nonatomic) IBOutlet UIButton *flashModeButton;
//@property (weak, nonatomic) IBOutlet UIButton *capturePhotoButton;
//@property (weak, nonatomic) IBOutlet UIButton *ghostModeButton;
//@property (nonatomic, strong) IBOutlet UIButton *selfieButton;
//@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
//@property (strong, nonatomic) IBOutlet UIProgressView *videoProgress;
//@property (nonatomic, strong) IBOutlet UIButton *flash;
//@property (nonatomic, strong) IBOutlet UIButton *menu;
//@property (nonatomic, strong) PFGeoPoint *userLocation;
//@property(nonatomic,strong) UIView *imageSelectedView;
//@property(nonatomic,strong) UIImageView *capturedImageView;
//@property (nonatomic, strong) UIImage *selectedImage;
//@property (nonatomic, strong) UIView *photoOverlayView;
//@property (nonatomic, strong) UITextField *caption;
//@property (assign, nonatomic) AVCaptureDevicePosition device;
//
//
//@property (nonatomic, strong) UITapGestureRecognizer *camTap;
//
//
////AWS
//@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest;
//@property (nonatomic, strong) NSString *awsPicUrl;
//
//@property (strong, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;
//
/////Upload to parse
//
//@property (nonatomic, strong) PFObject *event;
//@property (nonatomic, strong) PFGeoPoint *eventLocation;
//@property (nonatomic, strong) UIButton *uploadPhotoButton;
//
//
//
//
//
//- (IBAction)switchFlash:(id)sender;
//- (IBAction)capturePhoto:(id)sender;
//
//
//
//@end
