/*
 
 Copyright (c) 2014 Yichi Zhang
 https://github.com/yichizhang
 zhang-yi-chi@hotmail.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "YZSwipeBetweenViewController.h"
#import "StoriesTableViewController.h"
#import <Parse/Parse.h>
#import "WelcomeViewController.h"
#import "ViewContentViewController.h"
#import "StoriesTableViewController.h"

@interface YZSwipeBetweenViewController ()

@property (nonatomic, assign) NSInteger daIndex;
@property (nonatomic, strong) UINavigationController *nav;
@property (nonatomic, strong) MainStoriesViewController *mvc;
@property (nonatomic, assign) CGFloat lastContentOffset;

@property (nonatomic, strong) ViewContentViewController *vcvc;
@property (nonatomic, strong) StoriesTableViewController *storiesTable;


@end

@implementation YZSwipeBetweenViewController

bool canscroll = YES;


//int daIndex;
@synthesize nav;
@synthesize mvc;


typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViewControllersForScrollView];
    
    self.storiesTable = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTable"];
    
    self.scrollView.delegate = self;
    
    self.searchBar.delegate = self;
    
    UINavigationController *navCon2 = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewVideoNav"];
    ViewContentViewController *catVC = navCon2.viewControllers[0];
    catVC.delegate = self;
    
    
    ViewContentViewController *cat = [[ViewContentViewController alloc] init];
    
    self.vcvc = cat;
    
    
    cat.delegate = self;
    
    //NSLog(@"YZ DELEGATE: %@ ", cat.delegate);
    
    
    
    
    [self.view setFrame: [self.view bounds]];
    
    
    [self scrollToViewControllerAtIndex:1 animated:NO];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(methodToShowViewOnTop)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    _daIndex = self.initialViewControllerIndex;
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    if ([PFUser currentUser]) {
//        
//        
//    }
//    
//    else {
//        
//        //NSLog(@"SWIPEVIEW PUSH");
//        
//        WelcomeViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
//        
//        [self.navigationController presentViewController:wvc animated:NO completion:nil];
//        
//        
//        
//    }
    
    
    canscroll = YES;
    
    
}


-(void)disableScroll {
    
    //NSLog(@"Disable Scroll");
    
    
    self.scrollView.scrollEnabled = NO;
    
    canscroll = NO;
    
    
}

-(void)enableScroll {
    
    self.scrollView.scrollEnabled = YES;
    canscroll = YES;
    //NSLog(@"ENABLLE THE DAMN SCROLL ");
    
    
}



-(void)methodToShowViewOnTop{
        
    UIImageView *imageView = (UIImageView *)[UIApplication.sharedApplication.keyWindow.subviews.lastObject viewWithTag:101];
    [imageView removeFromSuperview];
    [self reloadInputViews];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self scrollToViewControllerAtIndex:1 animated:NO];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    //[UIApplication sharedApplication].statusBarHidden = YES;
    
}

#pragma mark - Private methods
- (void)removeViewControllersFromScrollView{
    
    for (UIViewController *vc in self.viewControllers) {
        
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        
    }
    
}

- (void)addViewControllersToScrollView {
    
    [self.scrollView removeFromSuperview];
    
    CGRect mainScreenBounds = [[UIScreen mainScreen] bounds];
    
    CGFloat currentOriginX = 0;
    
    for (UIViewController *vc in self.viewControllers) {
        
        CGRect frame = vc.view.frame;
        frame.origin.x = currentOriginX;
        vc.view.frame = frame;
        
        [self addChildViewController:vc];
        [self.scrollView addSubview:vc.view];
        [vc didMoveToParentViewController:self];
        
        currentOriginX += mainScreenBounds.size.width;
        
    }
    
    self.scrollView.contentSize =
    CGSizeMake(
               currentOriginX,
               mainScreenBounds.size.height
               );
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self scrollToViewControllerAtIndex:self.initialViewControllerIndex];
    
    [self.view addSubview:self.scrollView];
    
    
}

- (void)setupViewControllersForScrollView{
    
    [self removeViewControllersFromScrollView];
    [self addViewControllersToScrollView];
    
}

#pragma mark - Public Methods
- (void)setViewControllers:(NSArray *)viewControllers{
    
    _viewControllers = viewControllers;
    
    [self setupViewControllersForScrollView];
    
}

- (void)reloadViewControllers{
    
    [self setupViewControllersForScrollView];
    
}

- (void)scrollToViewControllerAtIndex:(NSInteger)index{
    
    [self scrollToViewControllerAtIndex:index animated:NO];
    
    
    if (index == 0) {
        
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    
    
    if (index == 1) {
        
        [UIApplication sharedApplication].statusBarHidden = YES;
        
    }
}


- (void)scrollToViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated{
    
    //	if (index >= 0 && index < self.viewControllers.count) {
    //
    //        [self.scrollView
    //		 scrollRectToVisible:[self.viewControllers[index] view].frame
    //		 animated:animated
    //		 ];
    //
    //	}
    
    
    [self.scrollView
     scrollRectToVisible:[self.viewControllers[index] view].frame
     animated:animated
     ];
    
    
    
    if (index == 0) {
        
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    
    
    if (index == 1) {
        
        [UIApplication sharedApplication].statusBarHidden = YES;
        
    }
    
    
    
}


#pragma mark - Lazy loading of members
- (UIScrollView *)scrollView{
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:
                       [[UIScreen mainScreen] bounds]
                       ];
    }
    return _scrollView;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    
    [self.searchBar resignFirstResponder];
    [self.view endEditing:YES];
    
    //[self.storiesTable.tableView reloadData];
    
    
    
        
   // if ([PFUser currentUser]) {
        
        // NSLog(@"WE HAVE A USER");
        
        self.scrollView.scrollEnabled = YES;
    
        
        [UIApplication sharedApplication].statusBarHidden = NO;
        
        
        if (scrollView.contentOffset.x < 320) {
            
            self.scrollView.bounces = YES;
            
        }
        
        if (scrollView.contentOffset.x >370) {
            
            self.scrollView.bounces = NO;
        }
        
        else {
            
            //self.scrollView.bounces = YES;
            
        }
        
    //}
    
    
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    

    
    self.scrollView.scrollEnabled = YES;
    
    
    if (canscroll == NO) {
        
        //NSLog(@"NOPe");
        
        self.scrollView.scrollEnabled = NO;
        [UIApplication sharedApplication].statusBarHidden = YES;
        
    }
    
    self.scrollView.scrollEnabled = YES;
    
    
    if (!canscroll) {
        
        self.scrollView.scrollEnabled = YES;
        
        
    }
    
}






- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    
    if (scrollView.contentOffset.x < 320) {
        
        [UIApplication sharedApplication].statusBarHidden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        
        //NSLog(@"Main");
    }
    else if (scrollView.contentOffset.x >=0) {
        
        [UIApplication sharedApplication].statusBarHidden = YES;
        //NSLog(@"Camera");
    }
    
    
    if([UIScreen mainScreen].bounds.size.height <= 568.0) {
        
        //NSLog(@"HERE: %f", scrollView.contentOffset.x);
        if (scrollView.contentOffset.x >319) {
            
            [UIApplication sharedApplication].statusBarHidden = YES;
            
        }
        
    } else {
        
        //NSLog(@"HERE 6: %f", scrollView.contentOffset.x);
        if (scrollView.contentOffset.x >375) {
            
            [UIApplication sharedApplication].statusBarHidden = YES;
            
        }
    }
    
    //NSLog(@"Content Offset: %f", scrollView.contentOffset.x);
    
    
    
}





@end
