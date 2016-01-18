//
//  EditVideoViewController.h
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

@class EditVideoViewController;

@protocol EditVideoViewControllerDelegate <NSObject>

-(void)disableScroll;
-(void)enableScroll;


@end


@interface EditVideoViewController : UIViewController <SCPlayerDelegate, SCAssetExportSessionDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>

@property(nonatomic,weak) IBOutlet id<EditVideoViewControllerDelegate> delegate;

@property (strong, nonatomic) SCRecordSession *recordSession;
@property (weak, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;
@property (weak, nonatomic) IBOutlet UILabel *filterNameLabel;
@property (weak, nonatomic) IBOutlet UIView *exportView;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (nonatomic, strong) UITextField *caption;

//AWS
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest;
@property (nonatomic, strong) NSString *awsVideoUrl;
@property (nonatomic, strong) NSString *awsPicUrl;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSURL *daVid;
@property (nonatomic, strong) UIButton *uploadPhotoButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) PFObject *currentUser;




@end
