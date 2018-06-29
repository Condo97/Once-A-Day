//
//  TodayTableViewController.m
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/18/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "TodayTableViewController.h"
#import "TodayTableViewCell.h"
#import "AddExerciseView.h"
#import "Defines.pch"

@interface TodayTableViewController ()

@property (strong, nonatomic) NSArray<ExerciseObject *> *exercises;
@property (strong, nonatomic) NSArray<NSString *> *predefinedIntervals;
@property (strong, nonatomic) AddExerciseView *addExerciseView;
@property (strong, nonatomic) UIVisualEffectView *blur;

@property (strong, nonatomic) UIPickerView *periodPicker; //Should be period picker
@property (strong, nonatomic) UIToolbar *pickerToolbar;

@end

@implementation TodayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAndUpdate];
    
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [self.pickerToolbar sizeToFit];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneButtonPressed:)];
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"AddExercise" owner:self options:nil];
    self.addExerciseView = [subviewArray objectAtIndex:0];
    [self.addExerciseView setFrame:CGRectMake((self.view.frame.size.width - 300) / 2, (self.view.frame.size.height - 325) / 3.5, 300, 325)];
    [self.addExerciseView.cancelButton addTarget:self action:@selector(cancelAddExercise:) forControlEvents:UIControlEventTouchDown];
    [self.addExerciseView.saveButton addTarget:self action:@selector(saveAddExercise:) forControlEvents:UIControlEventTouchDown];
    
    [self.pickerToolbar setItems:@[doneBtn] animated:YES];
    
    self.predefinedIntervals = PREDEFINED_INTERVALS;
    
    self.periodPicker = [[UIPickerView alloc] init];
    
    [self.periodPicker setDelegate:self];
    [self.periodPicker setDataSource:self];
    
    [self.addExerciseView.intervalField setInputView:self.periodPicker];
    [self.addExerciseView.intervalField setInputAccessoryView:self.pickerToolbar];
    [self.addExerciseView.nameField setInputAccessoryView:self.pickerToolbar];
    [self.addExerciseView.incrementField setInputAccessoryView:self.pickerToolbar];
    [self.addExerciseView.goalField setInputAccessoryView:self.pickerToolbar];
    
    [self.addExerciseView.intervalField addTarget:self action:@selector(tappedIntervalField:) forControlEvents:UIControlEventEditingDidBegin];
    [self.addExerciseView.nameField addTarget:self action:@selector(checkExerciseFieldsFilled:) forControlEvents:UIControlEventAllEditingEvents];
    [self.addExerciseView.intervalField addTarget:self action:@selector(checkExerciseFieldsFilled:) forControlEvents:UIControlEventAllEditingEvents];
    [self.addExerciseView.goalField addTarget:self action:@selector(checkExerciseFieldsFilled:) forControlEvents:UIControlEventAllEditingEvents];
    [self.addExerciseView.incrementField addTarget:self action:@selector(checkExerciseFieldsFilled:) forControlEvents:UIControlEventAllEditingEvents];
    
    [self.addExerciseView.saveButton setEnabled:NO];
    
    self.blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self.blur setFrame:self.view.bounds];
    
    [self.blur setAlpha:0.0];
    [self.addExerciseView setAlpha:0.0];
    
    [self.blur setHidden:YES];
    [self.addExerciseView setHidden:YES];
    
    [self.view addSubview:self.blur];
    [self.view addSubview:self.addExerciseView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadAndUpdate];
    [self.tableView reloadData];
}

- (void)loadAndUpdate {
    NSArray<ExerciseObject *> *allTodaysExercises = [[CDManager sharedManager] getTodaysExercises];
    NSArray<ExerciseObject *> *allAddedExercises = [[CDManager sharedManager] getAddedExercises];
    
    for(ExerciseObject *te in allTodaysExercises) {
        BOOL contained = NO;
        for(ExerciseObject *ae in allAddedExercises) {
            if(te.name == ae.name)
                contained = YES;
        }
        
        if(!contained) {
            ExerciseObject *recent = [[CDManager sharedManager] getMostRecentExercise:te.name];
            
            int newGoal = te.goal;
            if(te.goal == te.completed)
                newGoal = te.goal + te.increment;
            else if(te.completed > te.goal)
                newGoal = te.completed;
            
            ExerciseObject *temp = [[ExerciseObject alloc] initWithName:te.name goal:newGoal completed:0 increment:te.increment period:te.period identifier:te.identifier + 1 date:[NSDate date]];
            [[CDManager sharedManager] saveExercise:temp];
        }
    }
    
    self.exercises = [[CDManager sharedManager] getTodaysExercises];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.exercises.count == 0) {
        UILabel *empty = [[UILabel alloc] init];
        [empty setTextAlignment:NSTextAlignmentCenter];
        [empty setTextColor:[UIColor whiteColor]];
        [empty setText:@"No workouts today. Tap + to add one!"];
        [self.tableView setBackgroundView:empty];
        return 0;
    }
    
    [self.tableView setBackgroundView:[[UILabel alloc] init]];
    return self.exercises.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"exerciseCell" forIndexPath:indexPath];
    ExerciseObject *exercise = self.exercises[indexPath.row];
    
    [cell.exerciseLabel setText:[NSString stringWithFormat:@"%d %@", exercise.goal, exercise.name]];
    [cell.progressLabel setText:[NSString stringWithFormat:@"%d Completed", exercise.completed]]; //Maybe completed yesterday?
    
    UIImage *customImage = [[UIImage imageNamed:@"Custom"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.customImageView setImage:customImage];
    
    UIButton *checkButton = [[UIButton alloc] initWithFrame:cell.checkBackground.bounds];
    UIButton *customButton = [[UIButton alloc] initWithFrame:cell.customBackground.bounds];
    [checkButton setTag:indexPath.row];
    [customButton setTag:indexPath.row];
    
    [checkButton addTarget:self action:@selector(checkButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [customButton addTarget:self action:@selector(customButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    [cell.checkBackground addSubview:checkButton];
    [cell.customBackground addSubview:customButton];
    
    if(exercise.completed >= exercise.goal) {
        UIImage *checkFilledImage = [[UIImage imageNamed:@"CheckFilled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.checkImageView setImage:checkFilledImage];
        [cell.checkImageView setTintColor:GREEN];
    } else {
         UIImage *checkImage = [[UIImage imageNamed:@"Check"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.checkImageView setImage:checkImage];
        [cell.checkImageView setTintColor:BLUE];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

#pragma mark - IBActions

- (IBAction)addExerciseAction:(id)sender {
    [self.tableView setScrollEnabled:NO];
    
    [self.addExerciseView setAlpha:0.0];
    [self.blur setAlpha:0.0];
    
    [self.addExerciseView setHidden:NO];
    [self.blur setHidden:NO];
    
    [self.view bringSubviewToFront:self.blur];
    [self.view bringSubviewToFront:self.addExerciseView];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.addExerciseView setAlpha:1.0];
        [self.blur setAlpha:1.0];
    }];
}

#pragma mark - Targets

- (void)cancelAddExercise:(id)sender {
    [self.tableView setScrollEnabled:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.addExerciseView setAlpha:0.0];
        [self.blur setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.addExerciseView setHidden:YES];
        [self.blur setHidden:YES];
        [self resetFields];
        [self resignAll];
    }];
}

- (void)saveAddExercise:(id)sender {
    [self.tableView setScrollEnabled:YES];
    
    if([[CDManager sharedManager] nameExists:self.addExerciseView.nameField.text]) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Exercise exists!" message:[NSString stringWithFormat:@"An exercise named %@ already exists. Please try another name.", self.addExerciseView.nameField.text] preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            [self.addExerciseView setAlpha:0.0];
            [self.blur setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.addExerciseView setHidden:YES];
            [self.blur setHidden:YES];
            
            ExerciseObject *obj = [[ExerciseObject alloc] init];
            [obj setName:self.addExerciseView.nameField.text];
            [obj setGoal:self.addExerciseView.goalField.text.intValue];
            [obj setPeriod:(int)[self.periodPicker selectedRowInComponent:0]];
            [obj setIncrement:self.addExerciseView.incrementField.text.intValue];
            [obj setDate:[NSDate date]];
            [[CDManager sharedManager] saveExercise:obj];
            
            [self.tableView beginUpdates];
            self.exercises = [[CDManager sharedManager] getTodaysExercises];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView reloadData];
            [self.tableView endUpdates];
            
            [self resetFields];
            [self resignAll];
        }];
    }
}

- (void)resetFields {
    self.addExerciseView.nameField.text = @"";
    self.addExerciseView.goalField.text = @"";
    self.addExerciseView.intervalField.text = @"";
    self.addExerciseView.incrementField.text = @"";
    [self.periodPicker selectRow:0 inComponent:0 animated:NO];
    [self.addExerciseView.saveButton setEnabled:NO];
}

- (void)checkExerciseFieldsFilled:(id)sender {
    if(self.addExerciseView.nameField.text.length > 0 && self.addExerciseView.goalField.text.length > 0 && self.addExerciseView.intervalField.text.length > 0 && self.addExerciseView.incrementField.text.length > 0)
        [self.addExerciseView.saveButton setEnabled:YES];
    else
        [self.addExerciseView.saveButton setEnabled:NO];
}

- (void)pickerDoneButtonPressed:(id)sender {
    [self resignAll];
}

- (void)resignAll {
    [self.addExerciseView.nameField resignFirstResponder];
    [self.addExerciseView.goalField resignFirstResponder];
    [self.addExerciseView.intervalField resignFirstResponder];
    [self.addExerciseView.incrementField resignFirstResponder];
}

- (void)checkButtonPressed:(UIButton *)sender {
    ExerciseObject *temp = self.exercises[sender.tag];
    if(temp.completed < temp.goal) {
        temp.completed = temp.goal;
        
        [[CDManager sharedManager] updateLatestExercise:temp.name withExercise:temp];
        self.exercises = [[CDManager sharedManager] getTodaysExercises];
    } else {
        temp.completed = 0;
        
        [[CDManager sharedManager] updateLatestExercise:temp.name withExercise:temp];
        self.exercises = [[CDManager sharedManager] getTodaysExercises];
    }
    
    [self.tableView reloadData];
}

- (void)customButtonPressed:(UIButton *)sender {
    ExerciseObject *temp = self.exercises[sender.tag];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Custom" message:[NSString stringWithFormat:@"Enter the amount of %@ you've done.", self.exercises[sender.tag].name] preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setPlaceholder:@"Tap to enter..."];
    }];
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        temp.completed = ac.textFields[0].text.intValue;
        [[CDManager sharedManager] updateLatestExercise:temp.name withExercise:temp];
        self.exercises = [[CDManager sharedManager] getTodaysExercises];
        
        [self.tableView reloadData];
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.predefinedIntervals.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.predefinedIntervals[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.addExerciseView.intervalField.text = self.predefinedIntervals[row];
}

- (void)tappedIntervalField:(id)sender {
    if(self.addExerciseView.intervalField.text.length == 0) {
        [self.periodPicker selectRow:0 inComponent:0 animated:NO];
        [self.addExerciseView.intervalField setText:self.predefinedIntervals[0]];
    }
}

@end
