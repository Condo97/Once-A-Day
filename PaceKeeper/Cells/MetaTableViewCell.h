//
//  MetaTableViewCell.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 7/13/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MetaTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
