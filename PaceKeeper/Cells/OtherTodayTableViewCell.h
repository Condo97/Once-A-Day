//
//  OtherTodayTableViewCell.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 7/16/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherTodayTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIImageView *shareImage;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;

@end
