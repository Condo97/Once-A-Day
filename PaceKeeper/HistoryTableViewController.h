//
//  HistoryTableViewController.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/20/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.pch"
#import "StoreKitManager.h"

@interface HistoryTableViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, StoreKitManagerDelegate>

@property (strong, nonatomic) ExerciseObject *currentExercise;

@end
