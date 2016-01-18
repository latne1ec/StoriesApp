//
//  HomeTableCell.h
//  Stories
//
//  Created by Evan Latner on 2/27/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *homeStoryImage;

@property (strong, nonatomic) IBOutlet UILabel *homeName;

@property (strong, nonatomic) IBOutlet UIView *bkgView;


@end
