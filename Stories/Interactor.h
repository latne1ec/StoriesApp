//
//  Interactor.h
//  Stories
//
//  Created by Evan Latner on 2/15/16.
//  Copyright © 2016 stories. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Interactor : UIPercentDrivenInteractiveTransition

@property (nonatomic) BOOL hasStarted;
@property (nonatomic) BOOL shouldFinish;

@end
