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
//@property (strong, nonatomic) NSMutableArray *differentDates;

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:self.currentExercise.name];
    
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
    if(section == 0)
        return 1;
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
        NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
        [cell.notificationSwitch addTarget:self action:@selector(notificationSwitchSwitched:) forControlEvents:UIControlEventValueChanged];
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

- (void)notificationSwitchSwitched:(id)sender {
    NSData *deviceID = [KFKeychain loadObjectForKey:@"DeviceToken"];
    //([deviceID isEqualToString:@""])
    
    [[NetworkManager sharedManager] registerDevice:deviceID exerciseName:self.currentExercise.name interval:self.currentExercise.period];
}

@end
