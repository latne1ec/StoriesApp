////
////  VideoPreviewViewController.m
////  StoriesAWS
////
////  Created by Evan Latner on 3/29/15.
////  Copyright (c) 2015 Evan Latner. All rights reserved.
////
//
//#import "VideoPreviewViewController.h"
//#import "SCAssetExportSession.h"
////#import "SCRecordSessionManager.h"
//#import "AppDelegate.h"
//#import "ProgressHUD.h"
//
//
//@interface VideoPreviewViewController ()  {
//    SCPlayer *_player;
//}
//
//@property (nonatomic, strong) YZSwipeBetweenViewController *yzBaby;
//@property (nonatomic, strong) NSMutableIndexSet *selectedIndexes;
//@property (nonatomic, strong) IBOutlet UITextView *textView;
//@property (nonatomic, strong) NSArray *captionLocation;
//
//@end
//
//@implementation VideoPreviewViewController
//
//@synthesize caption;
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    
//    if (self) {
//    }
//    
//    return self;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    //[self queryForEventNearby];
//    
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    self.navigationItem.hidesBackButton = YES;
//    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    
//    self.filterSwitcherView.refreshAutomaticallyWhenScrolling = NO;
//    self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
//    self.filterSwitcherView.bounds = self.view.bounds;
//    self.filterSwitcherView.filterGroups = @[
//                                             [NSNull null],
//                                             
//                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectTransfer"]],
//                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectInstant"]],
//                                             ];
//    
//    _player = [SCPlayer player];
//    _player.CIImageRenderer = self.filterSwitcherView;
//    _player.loopEnabled = YES;
//    
//    
//    UIView *overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-50, CGRectGetWidth(self.view.frame), 50)];
//    [overlayView setBackgroundColor:[UIColor clearColor]];
//    [self.view addSubview:overlayView];
//    
//    self.uploadPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(overlayView.frame)-54, -2, 38, 38)];
//    [self.uploadPhotoButton setImage:[UIImage imageNamed:@"addDos"] forState:UIControlStateNormal];
//    [self.uploadPhotoButton addTarget:self action:@selector(saveToCameraRoll) forControlEvents:UIControlEventTouchUpInside];
//    
//    [overlayView addSubview:self.uploadPhotoButton];
//    
//    [self bounce];
//    
//    
//    UIButton *cancelSelectPhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(15,16, 40, 40)];//CGRectMake(8, 20, 32, 32)];
//    [cancelSelectPhotoButton setImage:[UIImage imageNamed:@"cancelbutton"] forState:UIControlStateNormal];
//    [cancelSelectPhotoButton addTarget:self action:@selector(cancelVideo) forControlEvents:UIControlEventTouchUpInside];
//    //[cancelSelectPhotoButton addTarget:self action:@selector(cancelTextCaption) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:cancelSelectPhotoButton];
//    
//    //self.postButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-40, 20, 32, 32)];
//    //    [self.addStoryButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
//    //    [self.addStoryButton setImage:[UIImage imageNamed:@"addSelected"] forState:UIControlStateSelected];
//    //    [self.addStoryButton setImage:[UIImage imageNamed:@"addSelected"] forState:UIControlStateHighlighted];
//    //    [self.addStoryButton addTarget:self action:@selector(saveToCameraRoll) forControlEvents:UIControlEventTouchUpInside];
//    
//    //    self.addStoryButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(overlayView.frame)-40, 15, 34, 34)];
//    //    [self.addStoryButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
//    //    [self.addStoryButton setImage:[UIImage imageNamed:@"addSelected"] forState:UIControlStateSelected];
//    //    [self.addStoryButton setImage:[UIImage imageNamed:@"addSelected"] forState:UIControlStateHighlighted];
//    //    [self.addStoryButton addTarget:self action:@selector(saveToCameraRoll) forControlEvents:UIControlEventTouchUpInside];
//    //    [overlayView addSubview:self.addStoryButton];
//    
//    //    UIButton *cancelSelectPhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(8, 15, 32, 32)];
//    //    [cancelSelectPhotoButton setImage:[UIImage imageNamed:@"cancelTwo"] forState:UIControlStateNormal];
//    //    [cancelSelectPhotoButton addTarget:self action:@selector(cancelVideo) forControlEvents:UIControlEventTouchUpInside];
//    //    [overlayView addSubview:cancelSelectPhotoButton];
//    
//    //    [self.postButton addTarget:self action:@selector(saveToCameraRoll) forControlEvents:UIControlEventTouchUpInside];
//    //    [self.view addSubview:self.postButton];
//    
//    //[overlayView addSubview:self.addStoryButton];
//    
//    
//    UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
//    imageViewTap.delegate = (id) self;
//    imageViewTap.numberOfTapsRequired = 1;
//    imageViewTap.numberOfTouchesRequired = 1;
//    //[self.view addGestureRecognizer:imageViewTap];
//    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(captionDrag:)];
//    //[self.view addGestureRecognizer:drag];
//    
//    self.yzBaby = [[YZSwipeBetweenViewController alloc] init];
//    self.delegate = (id)self.yzBaby;
//    [self.delegate performSelector:@selector(disableScroll)];
//    self.addStoryButton.layer.cornerRadius = 5;
//    self.addStoryButton.clipsToBounds = YES;
//    
//}
//
//-(void)viewDidAppear:(BOOL)animated {
//    
//    [self bounce];
//}
//
//- (void) initCaption{
//    
//    caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
//    caption = [[UITextField alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height/2,self.view.frame.size.width,40)];
//    caption.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.70];
//    caption.textAlignment = NSTextAlignmentCenter;
//    caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    caption.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    caption.TextAlignment=NSTextAlignmentCenter;
//    caption.textColor = [UIColor whiteColor];
//    caption.keyboardAppearance = UIKeyboardAppearanceDefault;
//    caption.alpha = 0;
//    caption.tintColor = [UIColor whiteColor];
//    caption.delegate = self;
//    caption.font = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:18];
//    caption.tintColor = [UIColor whiteColor];
//    
//    [self.view addSubview:caption];
//    
//}
//
//- (void)imageViewTapped:(UITapGestureRecognizer *)recognizer {
//    
//    if([caption isFirstResponder]){
//        
//        [caption resignFirstResponder];
//        caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
//        
//    } else {
//        
//        if (caption.alpha == 1) {
//            
//        }
//        else {
//            
//            [self initCaption];
//            [caption becomeFirstResponder];
//            caption.alpha = 1;
//        }
//    }
//}
//
//////STORING CAPTION LOCATION ****************
//
//- (void) captionDrag: (UIGestureRecognizer*)gestureRecognizer{
//    
//    CGPoint translation = [gestureRecognizer locationInView:self.view];
//    self.captionLocation = [NSArray arrayWithObjects:
//                            [NSValue valueWithCGPoint:translation],
//                            nil];
//    
//    
//    NSLog(@"%@", self.captionLocation);
//    
//    if(translation.y < caption.frame.size.height/2){
//        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  caption.frame.size.height/2);
//    } else if(self.view.frame.size.height < translation.y + caption.frame.size.height/2){
//        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  self.view.frame.size.height - caption.frame.size.height/2);
//    } else {
//        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  translation.y);
//    }
//}
//////STORING CAPTION LOCATION ****************
//
////- (BOOL)textField:(UITextField *)textField
////shouldChangeCharactersInRange:(NSRange)range
////replacementString:(NSString *)string{
////
////    NSString *text = textField.text;
////    text = [text stringByReplacingCharactersInRange:range withString:string];
////    CGSize textSize = [text sizeWithAttributes: @{NSFontAttributeName:textField.font}];
////
////    return (textSize.width + 5 < textField.bounds.size.width) ? true : false;
////}
//
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    
//    [caption resignFirstResponder];
//    return true;
//}
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    
//    return textView.text.length + (text.length - range.length) <= 45;
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
////- (void)textViewDidChange:(UITextView *)textView {
////
////    CGFloat fixedWidth = textView.frame.size.width;
////    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
////    CGRect newFrame = textView.frame;
////    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
////    textView.frame = newFrame;
////}
//
//
////-(void)textViewDidEndEditing:(UITextView *)textView {
////
////    [UIView beginAnimations:nil context:NULL];
////    [UIView setAnimationDuration:0.15];
////    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:caption cache:YES];
////    caption.frame = CGRectMake(0,self.view.frame.size.height/2,self.view.frame.size.width,44);
////    [UIView commitAnimations];
////}
//
//
//
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    self.navigationController.navigationBarHidden = YES;
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
//    self.navigationController.navigationItem.hidesBackButton = YES;
//    [_player setItemByUrl:[NSURL URLWithString:@""]];
//    [_player setItemByAsset:_recordSession.assetRepresentingRecordSegments];
//    [_player play];
//    [self.delegate performSelector:@selector(disableScroll)];
//    
//}
//
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    
//    [_player pause];
//    [_recordSession cancelSession:nil];
//    
//    [self.delegate performSelector:@selector(enableScroll)];
//    
//}
//
//-(void)cancelVideo {
//    
//    [_recordSession cancelSession:nil];
//    [_player pause];
//    [self.navigationController popViewControllerAnimated:NO];
//    
//}
//
//- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
//    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//    
//    if (error == nil) {
//        [[[UIAlertView alloc] initWithTitle:@"Saved to camera roll" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    } else {
//        [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    }
//}
//
//- (void)saveToCameraRoll {
//    
//    if ([[[PFUser currentUser] objectForKey:@"userStatus"] isEqualToString:@"anon"]) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Account" message:@"You must create an account first" delegate:nil cancelButtonTitle:@"Create Account" otherButtonTitles: nil];
//        
//        [alert show];
//        
//    }
//    
//    else {
//        
//        [_player pause];
//        [ProgressHUD show:nil Interaction:NO];
//        [self.navigationController popViewControllerAnimated:NO];
//        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//        [appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:0];
//        
//        SCFilterGroup *currentFilter = self.filterSwitcherView.selectedFilterGroup;
//        
//        void(^completionHandler)(NSURL *url, NSError *error) = ^(NSURL *url, NSError *error) {
//            if (error == nil) {
//            } else {
//                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//            }
//        };
//        
//        SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:self.recordSession.assetRepresentingRecordSegments];
//        exportSession.videoConfiguration.filterGroup = currentFilter;
//        exportSession.videoConfiguration.preset = SCPresetMediumQuality;
//        exportSession.audioConfiguration.preset = SCPresetLowQuality;
//        exportSession.videoConfiguration.maxFrameRate = 30.0;
//        exportSession.outputUrl = self.recordSession.outputUrl;
//        exportSession.outputFileType = AVFileTypeMPEG4;
//        
//        /////********************************************
//        
//        CGPoint myPoint = caption.center;
//        
//        NSLog(@"My Point.y = %f", myPoint.y);
//        
//        
//        UILabel *label = [UILabel new];
//        label.textColor = [UIColor whiteColor];
//        label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.70];
//        //label.backgroundColor = [UIColor clearColor];
//        label.font = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:18];
//        [label setTextAlignment:NSTextAlignmentCenter];
//        label.text = self.caption.text;
//        //[label setNeedsDisplay];
//        //[label setNeedsLayout];
//        //label.frame = CGRectMake(-1, 0, 500, 40);
//        //[label sizeToFit];
//        [label setBounds:CGRectMake(0, myPoint.y * 1.25, self.view.frame.size.width, 30)];
//        
//        
//        NSLog(@"%@", self.caption.text);
//        
//        UIGraphicsBeginImageContext(label.frame.size);
//        [label.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        
//        CGRect watermarkFrame = exportSession.videoConfiguration.watermarkFrame;
//        CGSize videoSize = CGSizeZero;
//        
//        exportSession.videoConfiguration.watermarkImage = image;
//        exportSession.videoConfiguration.watermarkFrame = CGRectMake(0, -myPoint.y + 150, self.view.frame.size.width, 30);
//        exportSession.videoConfiguration.watermarkAnchorLocation = watermarkFrame.origin.y += videoSize.height - watermarkFrame.size.height;
//        
//        [exportSession exportAsynchronouslyWithCompletionHandler:^{
//            completionHandler(exportSession.outputUrl, exportSession.error);
//            self.daVid = exportSession.outputUrl;
//            
//            [self uploadToS3:self.daVid];
//            
//        }];
//    }
//}
//
//////////////////**************************************************************
//
//-(void)uploadToS3:(NSURL *)videoUrl {
//    
//    
//    [_recordSession cancelSession:nil];
//    
//    _uploadRequest = [AWSS3TransferManagerUploadRequest new];
//    _uploadRequest.bucket = @"storiesbucket";
//    _uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
//    
//    
//    NSString * uuidStr = [[NSUUID UUID] UUIDString];
//    NSString *textBody = @"photos/PIC_KEY.mp4";
//    NSString* newString = [textBody stringByReplacingOccurrencesOfString:@"PIC_KEY" withString:uuidStr];
//    
//    
//    _uploadRequest.key = newString;
//    //_uploadRequest.key = @"photos/image.png";
//    _uploadRequest.contentType = @"video/mp4";
//    _uploadRequest.body = videoUrl;
//    
//    
//    NSString *daAwsRegion = @"https://s3-us-west-2.amazonaws.com/storiesbucket/";
//    daAwsRegion = [daAwsRegion stringByAppendingString:newString];
//    _awsPicUrl = daAwsRegion;
//    
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
//    }];
//}
//
//-(void)createThumbnail {
//    
//    NSLog(@"creating thumbnail");
//    
//    AVURLAsset *asset = [AVURLAsset assetWithURL:self.recordSession.outputUrl];
//    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
//    CMTime time = kCMTimeZero;
//    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
//    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//    
//    self.thumbnail = thumbnail;
//    if (self.thumbnail.size.width > 140) self.thumbnail = ResizeImage(self.thumbnail, 140, 140);
//    
//    PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.png" data:UIImagePNGRepresentation(self.thumbnail)];
//    [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        
//        if (error) {
//            
//            NSLog(@"ERROR: %@", error.userInfo);
//            [ProgressHUD dismiss];
//        }
//        
//        if (error == nil) {
//            
////            [[PFUser currentUser] incrementKey:@"userScore"];
////            [[PFUser currentUser] saveInBackground];
//            //[self uploadToParse:fileThumbnail];
//            
//        }
//    }];
//}
//
//-(void)uploadToParse {
//    
////    NSString *city = [[PFUser currentUser] objectForKey:@"userCity"];
////    NSString *event = [self.event objectForKey:@"storyName"];
//    
//    PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
//    [userPhoto setObject:_awsPicUrl forKey:@"videoUrl"];
//    [userPhoto setObject:@"video" forKey:@"postType"];
//    //[userPhoto setObject:thumbnail forKey:@"thumbnailPic"];
//    //[userPhoto setObject:self.userLocation forKey:@"postLocation"];
////    [userPhoto setObject:[[PFUser currentUser] objectForKey:@"userCity"] forKey:@"cityName"];
////    
////    if (self.eventLocation != nil) {
////        [userPhoto setObject:self.eventLocation forKey:@"postLocation"];
////        [userPhoto setObject:event forKey:@"eventName"];
////        [userPhoto setObject:city forKey:@"cityName"];
////    }
////    
////    else {
////        [userPhoto setObject:city forKey:@"cityName"];
////        [userPhoto setObject:city forKey:@"eventName"];
////    }
////    
////    [userPhoto setObject:[PFUser currentUser] forKey:@"user"];
//    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        
//        if (succeeded) {
//            
////            [[PFUser currentUser] incrementKey:@"postCount"];
////            [[PFUser currentUser] saveInBackground];
//            NSLog(@"Succeeeeeded");
//            
//        }
//        else {
//            
//            NSLog(@"error uploading to parse");
//            
//        }
//    }];
//}
//
//-(void)queryForEventNearby {
//    
//    PFQuery *query = [PFQuery queryWithClassName:@"FeaturedStories"];
//    [query whereKey:@"storyLocation" nearGeoPoint:self.userLocation withinMiles:0.5];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        
//        if (object == nil) {
//            
//            NSString *city = [[PFUser currentUser] objectForKey:@"userCity"];
//            NSString *textBody = @"Post to LOCATION";
//            NSString *newString = [textBody stringByReplacingOccurrencesOfString:@"LOCATION" withString:city];
//            [self.postButton setTitle:newString forState:UIControlStateNormal];
//            
//        }
//        
//        else {
//            
//            self.event = object;
//            self.eventLocation = [object objectForKey:@"storyLocation"];
//            NSString *location = [self.event objectForKey:@"storyName"];
//            NSString *textBody = @"Post to LOCATION";
//            NSString *newString = [textBody stringByReplacingOccurrencesOfString:@"LOCATION" withString:location];
//            [self.postButton setTitle:newString forState:UIControlStateNormal];
//            
//        }
//    }];
//}
//
//
//
//- (IBAction)bounce {
//    NSLog(@"Boucning");
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
//
//
////*********************************************
//// Resize the Image Properly
//
//UIImage* ResizeImage(UIImage *image, CGFloat width, CGFloat height) {
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
//
//@end
