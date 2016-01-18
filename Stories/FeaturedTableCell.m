//
//  FeaturedTableCell.m
//  Stories
//
//  Created by Evan Latner on 2/27/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "FeaturedTableCell.h"

@implementation FeaturedTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.featuredStoryImage.tag = 25;
    
    
    self.featuredStoryImage.image = [UIImage imageNamed:@"placeholder"];
    
}

@end
