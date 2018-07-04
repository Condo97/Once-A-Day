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

@interface HistoryTableViewController ()

@property (strong, nonatomic) NSArray<ExerciseObject *> *exercises;
@property (strong, nonatomic) UIPickerView *hourPicker;
@property (strong, nonatomic) UIToolbar *pickerToolbar;
@property (nonatomic) int globalHour;
//@property (strong, nonatomic) NSMutableArray *differentDates;

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:self.currentExercise.name];
    
    self.hourPicker = [[UIPickerView alloc] init];
    [self.hourPicker setDelegate:self];
    [self.hourPicker setDataSource:self];
    
    [[StoreKitManager sharedManager] setDelegate:self];
    
    self.globalHour = self.currentExercise.notificationHour;
    
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [self.pickerToolbar sizeToFit];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneButtonPressed:)];
    
    [self.pickerToolbar setItems:@[doneBtn] animated:YES];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    self.exercises = [[[CDManager sharedManager] getPastExercises:self.currentExercise.name] sortedArrayUsingDescriptors:@[descriptor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        if(((NSNumber *)[KFKeychain loadObjectForKey:PREMIUM_PURCHASED]).boolValue)
            return 2;
        return 3;
    }
    return self.exercises.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return [NSString stringWithFormat:@"%d Total %@!", [[CDManager sharedManager] getTotalForExercise:self.currentExercise.name], self.currentExercise.name];
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 0) {
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
        if(indexPath.row == 0 && !((NSNumber *)[KFKeychain loadObjectForKey:PREMIUM_PURCHASED]).boolValue) {
            NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"premiumCell"];
            [cell.getPremiumButton addTarget:self action:@selector(getPremium:) forControlEvents:UIControlEventTouchUpInside];
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
        NotificationTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [cell.timePlaceholder setEnabled:YES];
    } else {
        [[NetworkManager sharedManager] toggleNotifications:deviceID exerciseName:self.currentExercise.name enabled:NO];
        [self.currentExercise setNotificationsEnabled:NO];
        NotificationTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [cell.timePlaceholder setEnabled:NO];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(component == 0)
        return 12;
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
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
    NotificationTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell.timePlaceholder setText:[NSString stringWithFormat:@"%ld:00 %@", hour, am]];
}

- (void)pickerDoneButtonPressed:(id)sender {
    self.currentExercise.notificationHour = self.globalHour;
    [[NetworkManager sharedManager] setNotificationHour:[KFKeychain loadObjectForKey:@"DeviceToken"] exerciseName:self.currentExercise.name notificationHour:self.globalHour];
    
    NotificationTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell.timePlaceholder resignFirstResponder];
}

- (void)getPremium:(id)sender {
    [[StoreKitManager sharedManager] startPremiumPurchase];
}

- (void)purchaseSuccessful {
    [KFKeychain saveObject:[NSNumber numberWithBool:YES] forKey:PREMIUM_PURCHASED];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView reloadData];
    [self.tableView endUpdates];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Thank you!" message:@"Thank you for your purchase! You now have access to premium features." preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Sounds good!" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)purchaseUnsuccessful {
    
}

@end
