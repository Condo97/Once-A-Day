//
//  TodayTableViewCell.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/18/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *exerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UIView *checkBackground;

@property (weak, nonatomic) IBOutlet UIImageView *customImageView;
@property (weak, nonatomic) IBOutlet UIView *customBackground;

@end
