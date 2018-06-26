//
//  HistoryTableViewController.m
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/20/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "HistoryTableViewController.h"

@interface HistoryTableViewController ()

@property (strong, nonatomic) NSArray<ExerciseObject *> *exercises;
//@property (strong, nonatomic) NSMutableArray *differentDates;

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:self.exerciseName];
    
    self.exercises = [[CDManager sharedManager] getPastExercises:self.exerciseName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.exercises.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%d Total %@!", [[CDManager sharedManager] getTotalForExercise:self.exerciseName], self.exerciseName];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    [myLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [myLabel setTextColor:[UIColor whiteColor]];
    [myLabel setText:[self tableView:tableView titleForHeaderInSection:section]];
    [myLabel setTextAlignment:NSTextAlignmentCenter];
    return myLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

@end
