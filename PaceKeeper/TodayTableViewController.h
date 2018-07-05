//
//  TodayTableViewController.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/18/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreKitManager.h"

@interface TodayTableViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *motivationalQuote;
@property (weak, nonatomic) IBOutlet UILabel *motivationalAuthor;

@end
