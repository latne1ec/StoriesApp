//
//  FeaturedTableCell.h
//  Stories
//
//  Created by Evan Latner on 2/27/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface FeaturedTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *featuredStoryName;

@property (strong, nonatomic) IBOutlet UIImageView *featuredStoryImage;

@property (nonatomic, strong) PFGeoPoint *storyLocation;
@property (strong, nonatomic) IBOutlet UIView *bkgView;

@end
