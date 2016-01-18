//
//  CameraViewController.h
//  Stories
//
//  Created by Evan Latner on 1/10/16.
//  Copyright © 2016 stories. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>
#import <Parse/Parse.h>


@interface CameraViewController : UIViewController <SCRecorderDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, SCRecorderToolsViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (strong, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *timeRecordedLabel;
@property (weak, nonatomic) IBOutlet UIView *downBar;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraModeButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseCamera;
@property (weak, nonatomic) IBOutlet UIButton *flashModeButton;
@property (weak, nonatomic) IBOutlet UIButton *capturePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *ghostModeButton;
@property (weak, nonatomic) IBOutlet UIView *toolsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *openToolsButton;

@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (nonatomic, strong) IBOutlet UIButton *menu;
@property (nonatomic, strong) IBOutlet UIButton *selfieButton;
@property (strong, nonatomic) IBOutlet UIProgressView *videoProgress;
@property (nonatomic, strong) IBOutlet UIButton *flash;
@property(nonatomic,strong) UIView *imageSelectedView;
@property(nonatomic,strong) UIImageView *capturedImageView;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIView *photoOverlayView;
@property (nonatomic, strong) UITextField *caption;
@property (assign, nonatomic) AVCaptureDevicePosition device;
@property (strong, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;
@property (nonatomic, strong) UIButton *uploadPhotoButton;
@property (nonatomic, strong) UITapGestureRecognizer *camTap;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) PFObject *currentUser;

@property (nonatomic, strong) UIImageView *blackView;





//AWS
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest;
@property (nonatomic, strong) NSString *awsPicUrl;



- (IBAction)switchCameraMode:(id)sender;
- (IBAction)switchFlash:(id)sender;
- (IBAction)capturePhoto:(id)sender;
- (IBAction)switchGhostMode:(id)sender;

@end
