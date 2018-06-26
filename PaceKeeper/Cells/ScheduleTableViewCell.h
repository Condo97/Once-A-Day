//
//  ScheduleTableViewCell.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/20/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *increment;
@property (weak, nonatomic) IBOutlet UILabel *total;
@property (weak, nonatomic) IBOutlet UILabel *average;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *doTodayBackground;
@property (weak, nonatomic) IBOutlet UILabel *doTodayText;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIView *arrowBackground;

@end
