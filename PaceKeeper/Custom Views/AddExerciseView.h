//
//  AddExerciseView.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/19/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddExerciseView : UIView

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *goalField;
@property (weak, nonatomic) IBOutlet UITextField *intervalField;
@property (weak, nonatomic) IBOutlet UITextField *incrementField;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end
