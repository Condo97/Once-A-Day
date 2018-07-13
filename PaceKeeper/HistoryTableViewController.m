//
//  HistoryTableViewController.m
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/20/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "NotificationTableViewCell.h"
#import "NetworkManager.h"
#import "KFKeychain.h"
#import "MetaTableViewCell.h"

@interface HistoryTableViewController ()

@property (strong, nonatomic) NSArray<ExerciseObject *> *exercises;
@property (strong, nonatomic) UIPickerView *hourPicker;
@property (strong, nonatomic) UIToolbar *pickerToolbar;
@property (nonatomic) int globalHour;
//@property (strong, nonatomic) NSMutableArray *differentDates;

@property (strong, nonatomic) GADBannerView *bannerView;
@property (strong, nonatomic) UIPickerView *periodPicker;;
@property (strong, nonatomic) ExerciseObject *tempExercise;

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:self.currentExercise.name];
    
    self.hourPicker = [[UIPickerView alloc] init];
    [self.hourPicker setDelegate:self];
    [self.hourPicker setDataSource:self];
    
    self.periodPicker = [[UIPickerView alloc] init];
    [self.periodPicker setDelegate:self];
    [self.periodPicker setDataSource:self];
    
    [[StoreKitManager sharedManager] setDelegate:self];
    
    self.globalHour = self.currentExercise.notificationHour;
    
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [self.pickerToolbar sizeToFit];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneButtonPressed:)];
    
    [self.pickerToolbar setItems:@[doneBtn] animated:YES];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    self.exercises = [[[CDManager sharedManager] getPastExercises:self.currentExercise.name] sortedArrayUsingDescriptors:@[descriptor]];
    
    [[NetworkManager sharedManager] setNotificationHour:[KFKeychain loadObjectForKey:@"DeviceToken"] exerciseName:self.currentExercise.name notificationHour:self.globalHour];
    [[NetworkManager sharedManager] toggleNotifications:[KFKeychain loadObjectForKey:@"DeviceToken"] exerciseName:self.currentExercise.name enabled:self.currentExercise.notificationsEnabled];
    
    //Google Mobile Ads Setup
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    [self.bannerView setAdUnitID:HISTORY_AD_UNIT];
    [self.bannerView setRootViewController:self];
    [self.bannerView loadRequest:[GADRequest request]];
    [self.bannerView setFrame:CGRectMake(0, self.tableView.frame.size.height - 50 - [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom, self.tableView.frame.size.width, 50)];
}

- (void)viewWillAppear:(BOOL)animated {
    if(!((NSNumber *)[KFKeychain loadObjectForKey:PREMIUM_PURCHASED]).boolValue) {
        [self.navigationController.view addSubview:self.bannerView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if(!((NSNumber *)[KFKeychain loadObjectForKey:PREMIUM_PURCHASED]).boolValue) {
        [self.bannerView removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 4;
    } else if(section == 1) {
        if(((NSNumber *)[KFKeychain loadObjectForKey:PREMIUM_PURCHASED]).boolValue)
            return 2;
        return 3;
    }
    return self.exercises.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Tap \"Edit\" to change fields!";
    else if(section == 2)
        return [NSString stringWithFormat:@"%d Total %@!", [[CDManager sharedManager] getTotalForExercise:self.currentExercise.name], self.currentExercise.name];
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 0 || section == 2) {
        UILabel *myLabel = [[UILabel alloc] init];
        [myLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [myLabel setTextColor:[UIColor whiteColor]];
        [myLabel setText:[self tableView:tableView titleForHeaderInSection:section]];
        [myLabel setTextAlignment:NSTextAlignmentCenter];
        return myLabel;
    }
    
    return [[UIView alloc] init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        MetaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"metaCell"];
        [cell.textField setInputAccessoryView:self.pickerToolbar];
        [cell.textField setDelegate:self];

        if(self.isEditing)
           [cell.textField setEnabled:YES];
        else
            [cell.textField setEnabled:NO];
        
        switch(indexPath.row) {
            case 0: {
                [cell.title setText:@"Name:"];
                [cell.textField setText:self.currentExercise.name];
                break;
            }
            case 1: {
                [cell.title setText:@"Initial Goal:"];
                [cell.textField setText:[NSString stringWithFormat:@"%d", self.currentExercise.goal]];
                [cell.textField setKeyboardType:UIKeyboardTypeNumberPad];

                break;
            }
            case 2: {
                [cell.title setText:@"Interval:"];
                [cell.textField setText:PREDEFINED_INTERVALS[self.currentExercise.period]];
                [cell.textField setInputView:self.periodPicker];
                [self.periodPicker selectRow:self.currentExercise.period inComponent:0 animated:NO];
                break;
            }
            case 3: {
                [cell.title setText:@"Increment:"];
                [cell.textField setText:[NSString stringWithFormat:@"%d", self.currentExercise.goal]];
                [cell.textField setKeyboardType:UIKeyboardTypeNumberPad];
                break;
            }
        }
        
        return cell;
    } else if(indexPath.section == 1) {
        if(indexPath.row == 0 && !((NSNumber *)[KFKeychain loadObjectForKey:PREMIUM_PURCHASED]).boolValue) {
            NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"premiumCell"];
            [cell.getPremiumButton addTarget:self action:@selector(getPremium:) forControlEvents:UIControlEventTouchUpInside];
            [cell.premiumInfoButton addTarget:self action:@selector(premiumInfoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        } else if((indexPath.row == 0 && ((NSNumber *)[KFKeychain loadObjectForKey:PREMIUM_PURCHASED]).boolValue) || (indexPath.row == 1 && !((NSNumber *)[KFKeychain loadObjectForKey:PREMIUM_PURCHASED]).boolValue)) {
            NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
            [cell.notificationSwitch addTarget:self action:@selector(notificationSwitchSwitched:) forControlEvents:UIControlEventValueChanged];
            [cell.notificationSwitch setOn:self.currentExercise.notificationsEnabled];
            
            if(((NSNumber *)[KFKeychain loadObjectForKey:PREMIUM_PURCHASED]).boolValue)
                [cell.notificationSwitch setEnabled:YES];
            else
                [cell.notificationSwitch setEnabled:NO];
            
            return cell;
        }
        
        NSArray *predefinedIntervals = PREDEFINED_INTERVALS;
        NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCellTime"];
        [cell.timeLabel setText:[NSString stringWithFormat:@"%@ at:", predefinedIntervals[self.currentExercise.period]]];
        [cell.timePlaceholder setInputView:self.hourPicker];
        [cell.timePlaceholder setInputAccessoryView:self.pickerToolbar];
        
        NSString *am = @"am";
        int hour = self.currentExercise.notificationHour;
        if(self.currentExercise.notificationHour > 12) {
            am = @"pm";
            hour -= 12;
            [self.hourPicker selectRow:hour - 1 inComponent:0 animated:NO];
            [self.hourPicker selectRow:1 inComponent:1 animated:NO];
        } else {
            [self.hourPicker selectRow:hour - 1 inComponent:0 animated:NO];
            [self.hourPicker selectRow:0 inComponent:1 animated:NO];
        }
        
        if(self.currentExercise.notificationHour == 12) {
            am = @"pm";
            [self.hourPicker selectRow:hour - 1 inComponent:0 animated:NO];
            [self.hourPicker selectRow:1 inComponent:1 animated:NO];
        } else if(self.currentExercise.notificationHour == 0) {
            hour = 12;
            am = @"am";
            [self.hourPicker selectRow:hour - 1 inComponent:0 animated:NO];
            [self.hourPicker selectRow:0 inComponent:1 animated:NO];
        }
        
        if(self.currentExercise.notificationsEnabled) {
            [cell.timePlaceholder setEnabled:YES];
            [cell.timePlaceholder setText:[NSString stringWithFormat:@"%d:00 %@", hour, am]];
        } else {
            [cell.timePlaceholder setEnabled:NO];
            [cell.timePlaceholder setText:[NSString stringWithFormat:@"%d:00 %@", hour, am]];
        }
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMMM dd, h:mm a"];
    NSString *formattedDate = [format stringFromDate:self.exercises[indexPath.row].date];
    
    [cell.textLabel setText:formattedDate];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%d", self.exercises[indexPath.row].completed]];
    
    return cell;
}

- (NSDate *)dateAtBeginningOfMonth:(NSDate *)inputDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:inputDate];
    
    [dateComps setDay:0];
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)notificationSwitchSwitched:(UISwitch *)sender {
    NSData *deviceID = [KFKeychain loadObjectForKey:@"DeviceToken"];
    //([deviceID isEqualToString:@""])
    
    if(sender.on) {
        [[NetworkManager sharedManager] registerDevice:deviceID exerciseName:self.currentExercise.name interval:self.currentExercise.period + 1 date:self.currentExercise.date];
        [[NetworkManager sharedManager] toggleNotifications:deviceID exerciseName:self.currentExercise.name enabled:YES];
        [self.currentExercise setNotificationsEnabled:YES];
        NotificationTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        [cell.timePlaceholder setEnabled:YES];
    } else {
        [[NetworkManager sharedManager] toggleNotifications:deviceID exerciseName:self.currentExercise.name enabled:NO];
        [self.currentExercise setNotificationsEnabled:NO];
        NotificationTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        [cell.timePlaceholder setEnabled:NO];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if([pickerView isEqual:self.periodPicker])
        return 1;
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if([pickerView isEqual:self.periodPicker])
        return PREDEFINED_INTERVALS.count;
    
    if(component == 0)
        return 12;
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if([pickerView isEqual:self.periodPicker])
        return PREDEFINED_INTERVALS[row];
    
    if(component == 1) {
        if(row == 0)
            return @"am";
        return @"pm";
    }
    
    if(row + 1 > 12)
        return [NSString stringWithFormat:@"%ld", (long)row + 1 - 12];
    return [NSString stringWithFormat:@"%ld", (long)row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if([pickerView isEqual:self.periodPicker]) {
        [self.tempExercise setPeriod:(int)row];
        [((MetaTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]).textField setText:PREDEFINED_INTERVALS[row]];
    } else {
        long hour = -1;
        NSString *am = @"am";
        if(component == 0) {
            hour = row + 1;
            if([pickerView selectedRowInComponent:1] == 0) {
                if(row == 11) {
                    self.globalHour = 0;
                } else {
                    self.globalHour = (int)row + 1;
                }
            } else {
                if(row == 11) {
                    self.globalHour = 12;
                } else {
                    self.globalHour = (int)row + 1 + 12;
                }
                am = @"pm";
            }
        } else {
            hour = [pickerView selectedRowInComponent:0] + 1;
            if(row == 0) {
                if(hour == 12)
                    self.globalHour = 0;
                else
                    self.globalHour = (int)hour;
            } else {
                if(hour == 12)
                    self.globalHour = 12;
                else
                    self.globalHour = (int)hour + 12;
                am = @"pm";
            }
        }
        
        NSLog(@"%d", self.globalHour);
        NotificationTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        [cell.timePlaceholder setText:[NSString stringWithFormat:@"%ld:00 %@", hour, am]];
    }
}

- (void)pickerDoneButtonPressed:(id)sender {
    self.currentExercise.notificationHour = self.globalHour;
    [[NetworkManager sharedManager] setNotificationHour:[KFKeychain loadObjectForKey:@"DeviceToken"] exerciseName:self.currentExercise.name notificationHour:self.globalHour];
    
    NotificationTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    [cell.timePlaceholder resignFirstResponder];
    
    for(int i = 0; i < 4; i++)
        [((MetaTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]).textField resignFirstResponder];
}

- (void)getPremium:(id)sender {
    [[StoreKitManager sharedManager] startPremiumPurchase];
}

- (void)premiumInfoButtonPressed:(id)sender {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Premium" message:@"Premium lets you set custom notifications to remind you to exercise! If you've already purchased Premium, select \"Restore\"." preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Restore" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[StoreKitManager sharedManager] restorePurchases];
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if(editing) {
        self.tempExercise = [[ExerciseObject alloc] initWithName:self.currentExercise.name goal:self.currentExercise.goal completed:self.currentExercise.completed increment:self.currentExercise.increment period:self.currentExercise.period identifier:self.currentExercise.identifier date:self.currentExercise.date notificationsEnabled:self.currentExercise.notificationsEnabled notificationHour:self.currentExercise.notificationHour];
        [self.tableView reloadData];
    } else {
        [self.tempExercise setName:((MetaTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField.text];
        [self.tempExercise setGoal:((MetaTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField.text.intValue];
        [self.tempExercise setIncrement:((MetaTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]]).textField.text.intValue];
        
        [[CDManager sharedManager] updateLatestExercise:self.currentExercise.name withExercise:self.tempExercise];
        
        [self setTitle:self.tempExercise.name];
        
        for(int i = 0; i < 4; i++)
            [((MetaTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]).textField resignFirstResponder];
        
        self.currentExercise = self.tempExercise;
        [self.tableView reloadData];
    }
}

- (void)purchaseSuccessful {
    [KFKeychain saveObject:[NSNumber numberWithBool:YES] forKey:PREMIUM_PURCHASED];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView reloadData];
    [self.tableView endUpdates];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Thank you!" message:@"Thank you for your purchase! You now have access to premium features." preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Sounds good!" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)purchaseUnsuccessful {
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.!?@#"] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    return ([string isEqualToString:filtered] && newLength <= 59);
}

@end
