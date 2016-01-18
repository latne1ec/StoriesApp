//
//  ViewContentViewController.h
//  Spotshot
//
//  Created by Evan Latner on 7/18/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PArse/Parse.h>
#import "ProgressHUD.h"
#import "SCVideoPlayerView.h"
#import "CERoundProgressView.h"



@class ViewContentViewController;

@protocol ViewContentViewControllerDelegate <NSObject>

-(void)disableScroll;
-(void)enableScroll;


@end


@interface ViewContentViewController : UIViewController <UIGestureRecognizerDelegate>

@property(nonatomic,weak) IBOutlet id<ViewContentViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *contentArray;
@property (nonatomic, strong) AVAsset *avAsset;
@property (nonatomic, strong) AVURLAsset *urlAsset;
@property (nonatomic, strong) AVPlayerItem *avPlayerItem;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayer *avPlayerTwo;
@property (nonatomic, strong) AVAsset *avAssetTwo;
@property (nonatomic, strong) AVURLAsset *urlAssetTwo;
@property (nonatomic, strong) AVPlayerItem *avPlayerItemTwo;
@property (nonatomic, strong) AVQueuePlayer *qPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayerTwo;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UITapGestureRecognizer *tapTap;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) NSTimer *skipTimer;
@property (nonatomic, strong) NSTimer *dasTimer;
@property (nonatomic, strong) NSTimer *handleTapTimer;
@property (nonatomic, strong) UIView *replayView;
@property (nonatomic, strong) UIButton *replayButton;


@property (weak, nonatomic) IBOutlet CERoundProgressView *progressView;

@property (weak, nonatomic) IBOutlet CERoundProgressView *progressViewTwo;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (nonatomic, strong) NSMutableArray *videoArray;
@property (nonatomic, strong) NSMutableArray *imageArray;


@end
