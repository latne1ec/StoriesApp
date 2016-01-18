//
//  ViewContentViewController.m
//  Spotshot
//
//  Created by Evan Latner on 7/18/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "ViewContentViewController.h"
#import "SDWebImageManager.h"
#import "YZSwipeBetweenViewController.h"


@interface ViewContentViewController ()

@property (nonatomic, strong) YZSwipeBetweenViewController *yzBaby;
@property BOOL replayViewShowing;
@property BOOL currentlyQuerying;
@property BOOL firstObjectVideo;
@property (nonatomic, strong) NSMutableArray *updatedVideoArray;
@property (nonatomic, strong) UIImageView *imageViewTwo;

@property (nonatomic, strong) UIView *playerOneView;
@property (nonatomic, strong) UIView *playerTwoView;


@end

@implementation ViewContentViewController

int currentIndex;
int skipIndex;
int tempIndex;
int videoCount;
int imageCount;
int currentSkipCount;
int canSkip;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstObjectVideo = NO;
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    self.imageViewTwo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:[self.avPlayer currentItem]];
    
    [self queryForMedia];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.322 green:0.545 blue:0.737 alpha:1];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goHome:)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:swipe];

    self.yzBaby = [[YZSwipeBetweenViewController alloc] init];
    self.delegate = self.yzBaby;
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    self.indicator.center = self.view.center;
    
//    [self.indicator setHidden:NO];
//    [self.indicator startAnimating];
//    [self.view addSubview:self.indicator];
    
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.frame = CGRectMake(0,-40, self.view.frame.size.width, 40);
    self.subtitleLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
    self.subtitleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.93];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.subtitleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:16]];
    
    [self.view addSubview:self.subtitleLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(methodToShowViewOnTop)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    UIColor *tintColor = [UIColor lightGrayColor];
    [[UISlider appearance] setMinimumTrackTintColor:tintColor];
    [[CERoundProgressView appearance] setTintColor:tintColor];
    
    self.progressView.trackColor = [UIColor colorWithRed:0.322 green:0.545 blue:0.737 alpha:1];
    
    self.progressView.startAngle = (3.0*M_PI)/2.0;
    self.progressView.hidden = YES;
    
    self.progressViewTwo.trackColor = [UIColor whiteColor];
    self.progressViewTwo.startAngle = (3.0*M_PI)/2.0;
    self.progressViewTwo.hidden = YES;
    
    self.skipTimer = [NSTimer timerWithTimeInterval:0.32 target:self selector:@selector(this) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.skipTimer forMode:NSDefaultRunLoopMode];
    
    [self tryThis];
    
    self.playerOneView = [[UIView alloc] initWithFrame:self.view.frame];
    self.avPlayer = [[AVPlayer alloc] init];
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer: self.avPlayer];
    self.avPlayerLayer.frame = self.view.layer.bounds;
    self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.playerOneView.layer addSublayer:self.avPlayerLayer];
    [self.view addSubview:self.playerOneView];
    
    
    self.playerTwoView = [[UIView alloc] initWithFrame:self.view.frame];
    self.avPlayerTwo = [[AVPlayer alloc] init];
    self.avPlayerLayerTwo = [AVPlayerLayer playerLayerWithPlayer: self.avPlayerTwo];
    self.avPlayerLayerTwo.frame = self.view.layer.bounds;
    self.avPlayerLayerTwo.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.playerTwoView.layer addSublayer:self.avPlayerLayerTwo];
    [self.view addSubview:self.playerTwoView];


}

-(void)this {
    
    canSkip = 0;
}

-(void)setupTapTimer {
    
    PFObject *currentContent = [self.contentArray objectAtIndex:currentIndex];
    
    if ([[currentContent objectForKey:@"postType"] isEqualToString:@"video"]) {
        
        if (tempIndex  == 1) {
            tempIndex = 0;
            AVPlayerItem *playerItem = [self.avPlayer currentItem];
            
            double dur = CMTimeGetSeconds([[playerItem asset] duration]);
            double time = dur;
            self.handleTapTimer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(handleSingleTap) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.handleTapTimer forMode:NSDefaultRunLoopMode];
        } else {
            
            //NSLog(@"Setting up timer video");
            self.handleTapTimer = [NSTimer timerWithTimeInterval:[self playerItemDuration] target:self selector:@selector(handleSingleTap) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.handleTapTimer forMode:NSDefaultRunLoopMode];

        }
        
    } else {
        //NSLog(@"Setting up timer Photo");
        self.handleTapTimer = [NSTimer timerWithTimeInterval:7.0 target:self selector:@selector(handleSingleTap) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.handleTapTimer forMode:NSDefaultRunLoopMode];
    }
}

-(void)showReplayView {
    
    _replayViewShowing = true;
    //self.progressView.hidden = YES;
    //self.progressViewTwo.hidden = YES;
    [self.avPlayer pause];
    [self.avPlayerTwo pause];
    self.countDownLabel.text = @"";
    
    self.subtitleLabel.hidden = YES;
    
    PFObject *lastObject = [self.contentArray lastObject];
    [[NSUserDefaults standardUserDefaults] setObject:lastObject.objectId forKey:@"lastSeenContentId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.replayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.replayView];
    self.replayView.backgroundColor = [UIColor clearColor];
    self.replayButton = [[UIButton alloc] init];
    self.replayButton.frame = CGRectMake(0, 0, 300, 100);
    self.replayButton.center = self.view.center;
    [self.replayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.replayButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:20];
    self.replayButton.titleLabel.numberOfLines = 2;
    [self.replayButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.replayButton setTitle:@"no new posts 🔄\ntap to replay" forState:UIControlStateNormal];
    [self.replayButton addTarget:self action:@selector(replayShow) forControlEvents:UIControlEventTouchUpInside];
    self.replayView.alpha = 0;
    [self.replayView addSubview:self.replayButton];
    
    [UIView animateWithDuration:0.16 delay:0.29 options:0 animations:^{
        self.replayView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)replayShow {
    
    self.replayView.alpha = 0.0;
    [self.view sendSubviewToBack:self.replayView];
    
    self.subtitleLabel.text = @"";
    
    currentIndex = 0;
    currentSkipCount = 0;
    self.countDownLabel.text = @"";
    self.imageView.hidden = YES;
    self.imageViewTwo.hidden = YES;
    self.avPlayerLayer.hidden = YES;
    
    [self.contentArray removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.replayView removeFromSuperview];
    });
    
    [self.replayView removeFromSuperview];
    [self.view bringSubviewToFront:self.imageView];
    [self replayQuery];
    
}

-(void)methodToShowViewOnTop {
    
    [self goHome:self];
}

-(void)didReceiveMemoryWarning {
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];

    [super didReceiveMemoryWarning];
    
}

-(void)setupTimer {
    
    self.dasTimer = [NSTimer timerWithTimeInterval:0.75 target:self selector:@selector(resumeTheVideo) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.dasTimer forMode:NSDefaultRunLoopMode];
}

-(void)resumeTheVideo {
    
    if (self.contentArray.count > 0) {
        if (currentIndex >= self.contentArray.count) {
            
        } else {
         
            PFObject *currentContent = [self.contentArray objectAtIndex:currentIndex];
            if ([[currentContent objectForKey:@"postType"] rangeOfString:@"video"].location != NSNotFound) {
                
                
                if (videoCount % 2 == 0) {
                    // even
                    [self.avPlayer play];
                } else {
                    [self.avPlayerTwo play];
                }
            }
        }
    }
}
//
//-(void)playerItemDidReachEnd:(NSNotification *)notification  {
//    
//    if (currentIndex+1 >= self.contentArray.count) {
//        [self.dasTimer invalidate];
//        [self.handleTapTimer invalidate];
//        self.dasTimer = nil;
//    }
//    NSLog(@"Did reach end: %@", notification);
//    
//    [self.handleTapTimer invalidate];
//    [self.avPlayer pause];
//    [self.avPlayerTwo pause];
//    [self handleSingleTap];
//}

-(void)viewWillAppear:(BOOL)animated {
 
    currentIndex = 0;
    videoCount = 0;
    imageCount = 0;
    tempIndex = 0;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
}

-(void)addTapTapRecoginzer {
    
    self.tapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    self.tapTap.delegate = (id)self;
    self.tapTap.numberOfTapsRequired = 1;
    self.tapTap.numberOfTouchesRequired = 1;
    self.tapTap.delaysTouchesBegan = YES;
    self.tapTap.delaysTouchesEnded = YES; //Important to add
    [self.view addGestureRecognizer:self.tapTap];
    
}

-(void)viewWillDisappear:(BOOL)animated {

    [self.skipTimer invalidate];
    [self.dasTimer invalidate];
    [self.handleTapTimer invalidate];
    [self.avPlayer pause];
    [self.avPlayerTwo pause];
    self.avPlayer = nil;
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)handleSingleTap {
    
    NSLog(@"Tap");
    
    if (canSkip == 1) {
    } else {
    
    if (_replayViewShowing) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"storyViewCount"] intValue];
            [[NSUserDefaults standardUserDefaults] setInteger:i+1 forKey:@"storyViewCount"];
            
        });
        
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            int i = [[[NSUserDefaults standardUserDefaults] objectForKey:@"storyViewCount"] intValue];
            [[NSUserDefaults standardUserDefaults] setInteger:i+1 forKey:@"storyViewCount"];
            
            PFObject *currentContent = [self.contentArray objectAtIndex:currentIndex];
            [[NSUserDefaults standardUserDefaults] setObject:currentContent.objectId forKey:@"lastSeenContentId"];
            
        });
    }
    
    [self.handleTapTimer invalidate];
    [self.avPlayer pause];
    [self.avPlayerTwo pause];
    
    if (currentIndex+1 >= self.contentArray.count) {
        
        [self goHome:self];
        
    } else {
        currentIndex = currentIndex + 1;
        
        double percentage;
        percentage = 100.0*currentIndex/self.contentArray.count;
        self.progressView.progress = percentage/100;
        
        PFObject *currentContent = [self.contentArray objectAtIndex:currentIndex];
        
        if ([[currentContent objectForKey:@"postType"] isEqualToString:@"video"]) {
            
            self.subtitleLabel.hidden = YES;
            
            double percentageTwo;
            percentageTwo = 100.0*7;
            double time = [self playerItemDuration];
            
            self.progressViewTwo.animationDuration = time;
            self.progressViewTwo.progress = 0;
            self.progressViewTwo.progress = percentageTwo/100;
            
            
            
        } else {
            double percentageTwo;
            percentageTwo = 100.0*7;
            double time = 7.00;
            
            self.progressViewTwo.animationDuration = time;
            self.progressViewTwo.progress = 0;
            self.progressViewTwo.progress = percentageTwo/100;
        }
        [self setupTapTimer];
        [self displayContent];
        }
    }
}

- (double)playerItemDuration {
    
    if (videoCount % 2 == 0) {

        AVPlayerItem *playerItem = [self.avPlayer currentItem];
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            
            double dur = CMTimeGetSeconds([[playerItem asset] duration]);
            return dur;
        }

    } else {
        
        AVPlayerItem *playerItem = [self.avPlayerTwo currentItem];
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            
            double dur = CMTimeGetSeconds([[playerItem asset] duration]);
            return dur;
        }
    }
    return 7;
}

-(void)displayContent {
    
    canSkip = 1;
    PFObject *currentContent = [self.contentArray objectAtIndex:currentIndex];
    
    if ([[currentContent objectForKey:@"postType"] rangeOfString:@"video"].location != NSNotFound) {
        
        if (videoCount == 0) {
            
            videoCount = videoCount +1;
            
        } else {
            
            [self playDasVideo];
            [self preloadVideoPlayer];
            
        }
        
    } else {
        
        [self showPicture];
    }
}

-(void)slowlyAddSpinner {
    
    [self.view addSubview:self.indicator];
    [self.indicator setHidden:NO];
    [self.indicator startAnimating];
}

-(void)showVideoImageTemporarily {
    
    PFObject *currentContent = [self.contentArray objectAtIndex:currentIndex];
    SDWebImageManager *managerOne = [SDWebImageManager sharedManager];
    NSString *urlString = [currentContent objectForKey:@"imageUrl"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [managerOne downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    }
                           completed:^(UIImage *images, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                               
                               self.imageView.image = images;
                               //[self addCaption];
                               
                           }];
}

-(void)showPicture {
        
        PFObject *currentContent = [self.contentArray objectAtIndex:currentIndex];
        
        [self.view bringSubviewToFront:self.countDownLabel];
        
        SDWebImageManager *managerOne = [SDWebImageManager sharedManager];
        NSString *urlString = [currentContent objectForKey:@"imageUrl"];
        NSURL *url = [NSURL URLWithString:urlString];
    
        
        [managerOne downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        }
                               completed:^(UIImage *images, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                   
                                   //self.imageView.hidden = YES;

                                   self.imageView.image = images;
                                   self.countDownLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.contentArray.count - currentIndex];
                                   self.imageView.hidden = NO;
                                   //[self.view addSubview:self.imageView];
                                   [self.avPlayer pause];
                                   [self.avPlayerTwo pause];
                                   self.avPlayerLayer.hidden = YES;
//                                   [self.avPlayerLayer removeFromSuperlayer];
//                                   [self.avPlayerLayerTwo removeFromSuperlayer];
                                   [self.view bringSubviewToFront:self.imageView];
                                   [self.view bringSubviewToFront:self.countDownLabel];
                                   [self addCaption];
                                   
                                   self.progressViewTwo.hidden = NO;
                                   [self.view bringSubviewToFront:self.progressViewTwo];
                                   
                                   self.progressView.hidden = NO;
                                   [self.view bringSubviewToFront:self.progressView];
                                   
                                   double percentageTwo;
                                   percentageTwo = 100.0*7;
                                   double time = 7.00;
                                   
                                   self.progressViewTwo.animationDuration = time;
                                   self.progressViewTwo.progress = 0;
                                   self.progressViewTwo.progress = percentageTwo/100;
                                   
                               }];

}

-(void)addCaption {
    
    PFObject *currentContent = [self.contentArray objectAtIndex:currentIndex];
    CGFloat yOrigin = [[currentContent objectForKey:@"captionLocation"] floatValue];
    float height = [[UIScreen mainScreen] bounds].size.height;
    
    CGRect frame = self.subtitleLabel.frame;
    frame.origin.x = 0;
    frame.origin.y = yOrigin*height;
    self.subtitleLabel.frame = frame;
    
    self.subtitleLabel.text = [currentContent objectForKey:@"contentCaption"];
    
    if ([[currentContent objectForKey:@"contentCaption"] length] > 0) {
        
        if ([[currentContent objectForKey:@"postType"] rangeOfString:@"video"].location != NSNotFound) {
            self.subtitleLabel.hidden = YES;
        } else {
            self.subtitleLabel.hidden = NO;
            [self.view bringSubviewToFront:self.subtitleLabel];

        }
        } else {
        self.subtitleLabel.hidden = YES;
    }
}

-(void)playDasVideo {
    
//     self.imageView.hidden = YES;
    
//    [self.avPlayer pause];
//    [self.avPlayerTwo pause];
    
    if (videoCount % 2 == 0) {
        // even
        NSLog(@"Player One");
        
        [self.avPlayer play];
        [self.view sendSubviewToBack:self.playerTwoView];
        [self.view bringSubviewToFront:self.playerOneView];
        
        [self.view bringSubviewToFront:self.progressViewTwo];
        [self.view bringSubviewToFront:self.progressView];
        
        if (videoCount == 0) {
            NSLog(@"First Video in Player One");
        }
        
    } else {
        //Odd
        NSLog(@"Player Two");
        
        [self.avPlayerTwo play];
        [self.view sendSubviewToBack:self.playerOneView];
        [self.view bringSubviewToFront:self.playerTwoView];
        
        [self.view bringSubviewToFront:self.progressViewTwo];
        [self.view bringSubviewToFront:self.progressView];
        
        if (videoCount == 0) {
            NSLog(@"First Video in Player Two");
        }
    }
    
    videoCount = videoCount + 1;
}

-(void)addVideoCaption {
    
    PFObject *currentContent = [self.contentArray objectAtIndex:currentIndex];
    
    if ([[currentContent objectForKey:@"contentCaption"] length] > 0) {
     
        CGFloat yOrigin = [[currentContent objectForKey:@"captionLocation"] floatValue];
        float height = [[UIScreen mainScreen] bounds].size.height;
        CGRect frame = self.subtitleLabel.frame;
        frame.origin.x = 0;
        frame.origin.y = yOrigin*height;
        self.subtitleLabel.frame = frame;
        self.subtitleLabel.text = [currentContent objectForKey:@"contentCaption"];
        self.subtitleLabel.hidden = NO;
        [self.view bringSubviewToFront:self.subtitleLabel];

    }
}

-(void)showIfFirstObjectIsVideo {

    NSLog(@"show if first");
    PFObject *currentContent = [self.contentArray objectAtIndex:currentIndex];
    NSString *urlString = [currentContent objectForKey:@"videoUrl"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    self.avAsset = [AVAsset assetWithURL:url];
    self.avPlayerItem = [AVPlayerItem playerItemWithAsset:self.avAsset];
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.avPlayerItem];
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer: self.avPlayer];
    self.avPlayerLayer.frame = self.view.layer.bounds;
    self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.avPlayer play];
    [self.view sendSubviewToBack:self.playerTwoView];
    [self.view bringSubviewToFront:self.playerOneView];
    [self.view bringSubviewToFront:self.countDownLabel];
    [self.view bringSubviewToFront:self.subtitleLabel];
    
    self.progressViewTwo.hidden = NO;
    [self.view bringSubviewToFront:self.progressViewTwo];
    self.progressView.hidden = NO;
    [self.view bringSubviewToFront:self.progressView];
    
    [self.handleTapTimer invalidate];
    [self setupTapTimer];

    double percentageTwo;
    percentageTwo = 100.0*7;
    
    AVPlayerItem *playerItem = [self.avPlayer currentItem];
    double dur = CMTimeGetSeconds([[playerItem asset] duration]);
    double time = dur;
    self.progressViewTwo.animationDuration = time;
    self.progressViewTwo.progress = 0;
    self.progressViewTwo.progress = percentageTwo/100;
    
    //[self performSelector:@selector(tryThis) withObject:nil afterDelay:0.6];
    
}

-(void)tryThis {
    
    self.progressViewTwo.hidden = NO;
    [self.view bringSubviewToFront:self.progressViewTwo];
    
    self.progressView.hidden = NO;
    [self.view bringSubviewToFront:self.progressView];

}

-(void)preloadVideoPlayer {
    
    if (videoCount == self.videoArray.count) {

    } else {
    
        if (videoCount % 2 == 0) {
            //Even
            NSLog(@"Preloading One");
            NSString *nextUrlString = [self.videoArray objectAtIndex:videoCount];
            NSURL *url = [NSURL URLWithString:nextUrlString];
            self.avAsset = [AVAsset assetWithURL:url];
            self.avPlayerItem = [AVPlayerItem playerItemWithAsset:self.avAsset];
            [self.avPlayer replaceCurrentItemWithPlayerItem:self.avPlayerItem];
            
        } else {
            //Odd
            NSLog(@"Preloading Two");
            NSString *nextUrlString = [self.videoArray objectAtIndex:videoCount];
            NSURL *url = [NSURL URLWithString:nextUrlString];
            self.avAssetTwo = [AVAsset assetWithURL:url];
            self.avPlayerItemTwo = [AVPlayerItem playerItemWithAsset:self.avAssetTwo];
            
            [self.avPlayerTwo replaceCurrentItemWithPlayerItem:self.avPlayerItemTwo];
            
        }
    }
}


-(void)queryForMedia {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    
    [components setHour:-28];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: [NSDate date] options:0];

    NSString *userSchool = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserContent"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"updatedAt" greaterThanOrEqualTo:yesterday];
    [query whereKey:@"postStatus" equalTo:@"approved"];
    [query whereKey:@"userSchool" equalTo:userSchool];
    [query setLimit:130];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
        } else {
            
            if (objects.count == 0) {
                
                currentIndex = 0;
                [self showReplayView];
                self.countDownLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.contentArray.count-currentIndex];
                return;

            }
        
            self.contentArray = [objects mutableCopy];
            NSArray* reversedArray = [[self.contentArray reverseObjectEnumerator] allObjects];
            self.contentArray = [reversedArray mutableCopy];
            
            skipIndex = 0;
            
            PFObject *lastObject = [self.contentArray lastObject];
        
            [self.indicator setHidden:YES];
            [self.indicator stopAnimating];
           
            
            if ([lastObject.objectId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastSeenContentId"]]) {
                
                currentIndex = 0;
                [self showReplayView];
                self.countDownLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.contentArray.count-currentIndex];
                return;
                
            } else {
                
                self.updatedVideoArray = [[NSMutableArray alloc] init];
                
                    for (PFObject *object in self.contentArray) {
                        NSString *objectId = [object valueForKey:@"objectId"];
                        
                        skipIndex++;
                        
                        //Create new video array to remove older videos
                        if ([[object objectForKey:@"postType"] isEqualToString:@"video"]) {
                            NSString *urlString = [object objectForKey:@"videoUrl"];
                            [self.updatedVideoArray addObject:urlString];
                        }
                    
                    if ([objectId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastSeenContentId"]]) {
                        
                        currentIndex = skipIndex;
                        [self downloadImages];
                        [self getVideos];
                        [self addTapTapRecoginzer];
                        
                        self.countDownLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.contentArray.count-currentIndex];
                        
                        [self checkIfFirstObjectIsVideo];
                        
                        return;
                    }
                }
            }
            [self displayContent];
            [self.updatedVideoArray removeAllObjects];
            [self downloadImages];
            [self getVideos];
            //[self checkIfFirstObjectIsVideo];
            [self addTapTapRecoginzer];
        }
    }];
}

-(void)replayQuery {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    
    [components setHour:-28];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: [NSDate date] options:0];
    
    _currentlyQuerying = true;
    
    NSString *userSchool = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchool"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserContent"];
    [query whereKey:@"postStatus" equalTo:@"approved"];
    [query whereKey:@"updatedAt" greaterThanOrEqualTo:yesterday];
    [query whereKey:@"userSchool" equalTo:userSchool];
    [query orderByDescending:@"createdAt"];
    [query setLimit:130];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
        } else {
            
            if (objects.count == 0) {
                
                currentIndex = 0;
                [self showReplayView];
                self.countDownLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.contentArray.count-currentIndex];
                return;
                
            }
            
            _currentlyQuerying = false;
            self.contentArray = [objects mutableCopy];
            NSArray* reversedArray = [[self.contentArray reverseObjectEnumerator] allObjects];
            self.contentArray = [reversedArray mutableCopy];
            
            currentIndex = 0;
            [self displayContent];
            [self downloadImages];
            [self getVideos];
            [self addTapTapRecoginzer];
            //[self checkIfFirstObjectIsVideo];
            
        }
    }];
}


-(void)checkIfFirstObjectIsVideo {
    
    PFObject *currentContent = [self.contentArray objectAtIndex:currentIndex];
    
    if ([[currentContent objectForKey:@"postType"] isEqualToString:@"video"]) {
        
        tempIndex = 1;
        _firstObjectVideo = YES;
        [self showIfFirstObjectIsVideo];
        
    } else {
        
        [self.handleTapTimer invalidate];
        [self setupTapTimer];
        [self displayContent];
    }
    
    //[self displayContent];
}

-(void)getVideos {
    
    self.videoArray = [[NSMutableArray alloc] init];
    
    for (PFObject *object in self.contentArray) {
        
        NSString *postType = [object valueForKey:@"postType"];
        
        if ([postType isEqualToString:@"video"]) {
            NSString *urlString = [object objectForKey:@"videoUrl"];
            [self.videoArray addObject:urlString];
        }
    }
    
    [self.videoArray removeObjectsInArray:self.updatedVideoArray];
    [self preloadVideoPlayer];
}


-(void)downloadImages {
    
    for (PFObject *object in self.contentArray) {

        NSString *urlString = [object objectForKey:@"imageUrl"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        SDWebImageManager *managerTwo = [SDWebImageManager sharedManager];
        
        if ([managerTwo cachedImageExistsForURL:url]) {
            imageCount = imageCount + 1;

        } else {
            
            [managerTwo downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            }
                                   completed:^(UIImage *images, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                       
                                       imageCount = imageCount + 1;
                                       
                                   }];
            }
        }
}

-(IBAction)goHome:(id)sender {
    
    [UIView animateWithDuration:0.1 animations:^{
        self.subtitleLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
    }];
    
    [self.handleTapTimer invalidate];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(IBAction)goHomeNotAnimated {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

@end
