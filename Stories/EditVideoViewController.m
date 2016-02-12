//
//  EditVideoViewController.m
//  Stories
//
//  Created by Evan Latner on 1/10/16.
//  Copyright © 2016 stories. All rights reserved.
//

#import "EditVideoViewController.h"
#import "YZSwipeBetweenViewController.h"
#import "AppDelegate.h"

@interface EditVideoViewController ()

@property (strong, nonatomic) SCAssetExportSession *exportSession;
@property (strong, nonatomic) SCPlayer *player;
@property (nonatomic, strong) YZSwipeBetweenViewController *yzBaby;
@property (nonatomic) float keyboardOriginY;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation EditVideoViewController

@synthesize caption;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.exportView.clipsToBounds = YES;
    self.exportView.layer.cornerRadius = 20;
    _player = [SCPlayer player];
    
    if ([[NSProcessInfo processInfo] activeProcessorCount] > 1) {
        self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
        SCFilter *emptyFilter = [SCFilter emptyFilter];
        
        self.filterSwitcherView.filters = @[
                                            emptyFilter,
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectFade"],
                                            [SCFilter filterWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"a_filter" withExtension:@"cisf"]],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectTonal"],
                                            ];

        _player.SCImageView = self.filterSwitcherView;
        [self.filterSwitcherView addObserver:self forKeyPath:@"selectedFilter" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
        playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        playerView.frame = self.filterSwitcherView.frame;
        playerView.autoresizingMask = self.filterSwitcherView.autoresizingMask;
        [self.filterSwitcherView.superview insertSubview:playerView aboveSubview:self.filterSwitcherView];
        [self.filterSwitcherView removeFromSuperview];
    }
    
    _player.loopEnabled = YES;
    
    self.yzBaby = [[YZSwipeBetweenViewController alloc] init];
    self.delegate = (id)self.yzBaby;
    [self.delegate performSelector:@selector(disableScroll)];
    
    
    self.closeButton = [[UIButton alloc]initWithFrame:CGRectMake(8,12, 50, 50)];//CGRectMake(8, 20, 32, 32)];
    [self.closeButton setImage:[UIImage imageNamed:@"cancelNew"] forState:UIControlStateNormal];
    [self.view addSubview:self.closeButton];
    
    UILongPressGestureRecognizer *cancelButtonPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doThis:)];
    cancelButtonPress.delegate = (id)self;
    cancelButtonPress.minimumPressDuration = 0.01;
    [self.closeButton addGestureRecognizer:cancelButtonPress];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    longPress.delegate = self;
    longPress.minimumPressDuration = 0.05;
    [longPress addTarget:self action:@selector(makeButtonBounce:)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    [tap addTarget:self action:@selector(makeButtonBounce:)];
    
    UIView *overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-50, CGRectGetWidth(self.view.frame), 50)];
    [overlayView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:overlayView];

    self.uploadPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(overlayView.frame)-57, -5, 44, 44)];
    [self.uploadPhotoButton setImage:[UIImage imageNamed:@"addDos"] forState:UIControlStateNormal];
    //[self.uploadPhotoButton addTarget:self action:@selector(saveToCameraRoll) forControlEvents:UIControlEventTouchUpInside];
    
    [self.uploadPhotoButton addGestureRecognizer:longPress];
    
    [overlayView addSubview:self.uploadPhotoButton];
    
    UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    imageViewTap.delegate = (id) self;
    imageViewTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:imageViewTap];
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(captionDrag:)];
    [self.view addGestureRecognizer:drag];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    
    //NSLog(@"Duraition: %f", CMTimeGetSeconds(_recordSession.duration));
    
    
}

-(void)viewDidAppear:(BOOL)animated {

    [self bounce];
}

- (IBAction)bounce {
    //NSLog(@"Boucning");
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

-(void)makeButtonBounce:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        //NSLog(@"hiiii");
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
            //NSLog(@"Ended:");
            [self saveToCameraRoll];
            
            self.uploadPhotoButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    }
}

-(void)ScrollToHomeView {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:0 animated:NO];
}

///********************************************************************
/////PHOTO CAPTION
- (void)imageViewTapped:(UITapGestureRecognizer *)recognizer {
        
        //NSLog(@"Tap tap");
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
    
    // Caption
    caption = [[UITextField alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height/2+80,self.view.frame.size.width,40)];
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
    [self.view addSubview:caption];
}

- (void) captionDrag: (UIGestureRecognizer*)gestureRecognizer{
    
    CGPoint translation = [gestureRecognizer locationInView:self.view];
    
    if(translation.y < caption.frame.size.height/2+280){
        //NSLog(@"HEre;");
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  caption.frame.size.height/2+280);
    } else if(self.view.frame.size.height < translation.y + caption.frame.size.height/2){
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  self.view.frame.size.height - caption.frame.size.height/2);
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
    
    //NSLog(@"keyboard %f and %f", keyboardFrame.origin.y-40, keyboardFrame.origin.x);
    
    _keyboardOriginY = keyboardFrame.origin.y;
    [self setKeyboardFrame];
}


/////PHOTO CAPTION
///********************************************************************


-(void)cancelVideo {

    [self.filterSwitcherView removeObserver:self forKeyPath:@"selectedFilter"];
    [_recordSession cancelSession:nil];
    [_player pause];
    [self.navigationController popViewControllerAnimated:NO];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_player setItemByAsset:_recordSession.assetRepresentingSegments];
    [_player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate enableScroll];
    [_player pause];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.filterSwitcherView) {
        self.filterNameLabel.hidden = NO;
        self.filterNameLabel.text = self.filterSwitcherView.selectedFilter.name;
        self.filterNameLabel.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.filterNameLabel.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    self.filterNameLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }];
    }
}


- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        float progress = assetExportSession.progress;
        
        CGRect frame =  self.progressView.frame;
        frame.size.width = self.progressView.superview.frame.size.width * progress;
        self.progressView.frame = frame;
    });
}

- (void)cancelSaveToCameraRoll
{
    [_exportSession cancelExport];
}

- (IBAction)cancelTapped:(id)sender {
    [self cancelSaveToCameraRoll];
}

- (void)_addActionToAlertController:(UIAlertController *)alertController forType:(SCContextType)contextType withName:(NSString *)name {
    if ([SCContext supportsType:contextType]) {
        UIAlertActionStyle style = (self.filterSwitcherView.contextType != contextType ? UIAlertActionStyleDefault : UIAlertActionStyleDestructive);
        UIAlertAction *action = [UIAlertAction actionWithTitle:name style:style handler:^(UIAlertAction * _Nonnull action) {
            self.filterSwitcherView.contextType = contextType;
        }];
        [alertController addAction:action];
    }
}

- (IBAction)changeRenderingModeTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change video rendering mode" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [self _addActionToAlertController:alertController forType:SCContextTypeAuto withName:@"Auto"];
    [self _addActionToAlertController:alertController forType:SCContextTypeMetal withName:@"Metal"];
    [self _addActionToAlertController:alertController forType:SCContextTypeEAGL withName:@"EAGL"];
    [self _addActionToAlertController:alertController forType:SCContextTypeCoreGraphics withName:@"Core Graphics"];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)saveToCameraRoll {
    
        //[ProgressHUD show:nil Interaction:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"show_loader" object:self];
        [self ScrollToHomeView];
        [_player pause];
        [self.navigationController popViewControllerAnimated:NO];
        [self.delegate enableScroll];
        [self.filterSwitcherView removeObserver:self forKeyPath:@"selectedFilter"];
    
        SCFilter *currentFilter = self.filterSwitcherView.selectedFilter;
        
        void(^completionHandler)(NSURL *url, NSError *error) = ^(NSURL *url, NSError *error) {
            if (error == nil) {
            } else {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
            }
        };
        
        SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:self.recordSession.assetRepresentingSegments];
        exportSession.videoConfiguration.filter = currentFilter;
        exportSession.videoConfiguration.preset = SCPresetMediumQuality;
        exportSession.audioConfiguration.preset = SCPresetLowQuality;
        exportSession.videoConfiguration.maxFrameRate = 30.0;
        exportSession.outputUrl = self.recordSession.outputUrl;
        exportSession.outputFileType = AVFileTypeMPEG4;
    
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            completionHandler(exportSession.outputUrl, exportSession.error);
            self.daVid = exportSession.outputUrl;
            
            [self uploadToS3:self.daVid];
            [self createThumbnail];
            
        }];
}

////////////////**************************************************************

-(void)uploadToS3:(NSURL *)videoUrl {
    
    
    [_recordSession cancelSession:nil];
    
    _uploadRequest = [AWSS3TransferManagerUploadRequest new];
    _uploadRequest.bucket = @"storiescontentbucket";
    _uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    
    
    int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"localUserScore"] intValue];
    
    NSString *randomId = [[NSUUID UUID] UUIDString];
    
    NSString * uuidStr = [NSString stringWithFormat:@"%@-%d-%@", self.currentUser.objectId, i, randomId];
    
    NSString *textBody = @"posts/PIC_KEY.mp4";
    NSString* newString = [textBody stringByReplacingOccurrencesOfString:@"PIC_KEY" withString:uuidStr];
    
    _uploadRequest.key = newString;
    //_uploadRequest.key = @"photos/image.png";
    _uploadRequest.contentType = @"video/mp4";
    _uploadRequest.body = videoUrl;
    
    
    NSString *daAwsRegion = @"http://d267cblbp4esvr.cloudfront.net/";
    daAwsRegion = [daAwsRegion stringByAppendingString:newString];
    _awsVideoUrl = daAwsRegion;
    
    
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
            
            //NSLog(@"AWS URL: %@", _awsVideoUrl);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [ProgressHUD dismiss];
        }
        return nil;
        
    }];
}

-(void)createThumbnail {
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.recordSession.outputUrl];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = kCMTimeZero;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    //NSLog(@"Thumbnail: %@", thumbnail);
    
    thumbnail = resizeDasPicTwo(thumbnail);
    
    
    //if (thumbnail.size.width > 140) thumbnail = ResizePhotoTwo(thumbnail, 225, 400); //300 x 400 -- 240 x 430
    
    //if (thumbnail.size.width > 140) thumbnail = ResizePhotoTwo(thumbnail, 320, 568); //300 x 400 -- 240 x 430
    
    // Upload image******************************************
    
    //NSData *imageData = UIImagePNGRepresentation(thumbnail);
    NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.75);
    [self uploadThumbnailToS3:imageData];
}

-(void)uploadThumbnailToS3: (NSData *)data {
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"image.png"];
    [data writeToFile:path atomically:YES];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
    _uploadRequest = [AWSS3TransferManagerUploadRequest new];
    _uploadRequest.bucket = @"storiescontentbucket";
    _uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    
    NSString *randomId = [[NSUUID UUID] UUIDString];
    int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"localUserScore"] intValue];
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
            
           // NSLog(@"AWS ERROR: %@", task.error);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            //Hide Loader
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hide_loader" object:self];
            [ProgressHUD showError:@"network error"];
            
        }
        
        else {
            
           // NSLog(@"AWS Pic URL: %@", _awsPicUrl);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self uploadToParse];
            //[ProgressHUD dismiss];
            //Hide Loader
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hide_loader" object:self];

        }
        return nil;
        
    }];
}

UIImage* resizeDasPicTwo(UIImage *image) {
    
    float heightFactor = 960/image.size.height;
    CGSize size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(heightFactor, heightFactor));
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //NSLog(@"final image height: %f", finalImage.size.height);
    return finalImage;
}

UIImage* ResizePhotoTwo(UIImage *image, CGFloat width, CGFloat height) {
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


-(void)uploadToParse {
    
    NSString *userSchool = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
    NSString *schoolId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchoolId"];
    NSString *userObjectId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userObjectId"];
    
    PFObject *userPhoto = [PFObject objectWithClassName:@"UserContent"];
    [userPhoto setObject:_awsVideoUrl forKey:@"videoUrl"];
    [userPhoto setObject:_awsPicUrl forKey:@"imageUrl"];
    
    float height = [[UIScreen mainScreen] bounds].size.height;
    
    NSString *capLoc = [NSString stringWithFormat:@"%f", caption.frame.origin.y/height];
    
    
    if ([self.caption.text length] >= 1) {
        [userPhoto setObject:caption.text forKey:@"contentCaption"];
        [userPhoto setObject:capLoc forKey:@"captionLocation"];
    }
    [userPhoto setObject:@"pending" forKey:@"postStatus"];
    [userPhoto setObject:@"video" forKey:@"postType"];
    [userPhoto setObject:userSchool forKey:@"userSchool"];
    [userPhoto setObject:schoolId forKey:@"userSchoolId"];
    if (self.currentUser != nil) {
     [userPhoto setObject:self.currentUser forKey:@"user"];
    }
    [userPhoto setObject:userObjectId forKey:@"userObjectId"];
    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            //Increment User Score
            int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"localUserScore"] intValue];
            [[NSUserDefaults standardUserDefaults] setInteger:i+1 forKey:@"localUserScore"];
            
        }
        else {
            //Hide Loader
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hide_loader" object:self];
            [ProgressHUD showError:@"network error"];
        }
    }];
}

-(void)doThis: (UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:0.09 animations:^{
            //NSLog(@"Started");
            self.closeButton.transform = CGAffineTransformMakeScale(1.4, 1.4);
            
        } completion:^(BOOL finished) {
            //NSLog(@"FINISHED");
            
        }];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.08 animations:^{
            //NSLog(@"Started");
            self.closeButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
            
        } completion:^(BOOL finished) {
            //NSLog(@"FINISHED");
            [self cancelVideo];
        }];
    }
}

@end
