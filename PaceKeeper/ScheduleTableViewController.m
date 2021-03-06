//
//  ScheduleTableViewController.m
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/20/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "ScheduleTableViewController.h"
#import "ScheduleTableViewCell.h"
#import "HistoryTableViewController.h"
#import "NetworkManager.h"
#import "KFKeychain.h"

@interface ScheduleTableViewController ()

@property (strong, nonatomic) NSArray<ExerciseObject *> *exercises, *todaysExercises;
@property (strong, nonatomic) NSArray<NSString *> *predefinedIntervals;

@property (strong, nonatomic) GADBannerView *bannerView;

@end

@implementation ScheduleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.predefinedIntervals = PREDEFINED_INTERVALS;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Google Mobile Ads Setup
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    [self.bannerView setAdUnitID:SCHEDULE_AD_UNIT];
    [self.bannerView setRootViewController:self];
    [self.bannerView loadRequest:[GADRequest request]];
    [self.bannerView setFrame:CGRectMake(0, self.tableView.frame.size.height - 50 - [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom, self.tableView.frame.size.width, 50)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.todaysExercises = [[CDManager sharedManager] getTodaysExercises];
    [self loadEverything];
    
    if(!((NSNumber *)[KFKeychain loadObjectForKey:PREMIUM_PURCHASED]).boolValue) {
        [self.navigationController.view addSubview:self.bannerView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if(!((NSNumber *)[KFKeychain loadObjectForKey:PREMIUM_PURCHASED]).boolValue) {
        [self.bannerView removeFromSuperview];
    }
}

- (void)loadEverything {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    self.exercises = [[[CDManager sharedManager] getAllRecentExercises] sortedArrayUsingDescriptors:@[descriptor]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.exercises.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:11.0]];
    [label setTextColor:[UIColor lightTextColor]];
    [label setText:@"Swipe right to do an exercise today."];
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    double totalCompleted = [[CDManager sharedManager] getTotalForExercise:self.exercises[indexPath.row].name];
    double count = [[CDManager sharedManager] getCountForExercise:self.exercises[indexPath.row].name];
    
    [cell.name setText:self.exercises[indexPath.row].name];
    [cell.increment setText:[NSString stringWithFormat:@"+%d %@", self.exercises[indexPath.row].increment, self.predefinedIntervals[self.exercises[indexPath.row].period]]];
    [cell.total setText:[NSString stringWithFormat:@"%0.0f Complete", totalCompleted]];
    [cell.average setText:[NSString stringWithFormat:@"%0.0f Average", totalCompleted / count]];
    
    BOOL isToday = NO;
    for(ExerciseObject *e in self.todaysExercises) {
        if([e.name isEqualToString:self.exercises[indexPath.row].name]) {
            isToday = YES;
        }
    }
    
    if(isToday) {
        [cell.arrowImageView setImage:nil];
        
        [cell.editLeadingConstraint setConstant:-10.0];
    } else {
        UIImage *arrow = [UIImage imageNamed:@"Arrow"];
        [cell.arrowImageView setImage:[arrow imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [cell.arrowImageView setTintColor:GREEN];
        
        [cell.editLeadingConstraint setConstant:0.0];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"toHistory" sender:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"toHistory"]) {
        NSIndexPath *ip = (NSIndexPath *)sender;
        HistoryTableViewController *hvc = (HistoryTableViewController *)segue.destinationViewController;
        [hvc setCurrentExercise:self.exercises[ip.row]];
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isToday = NO;
    for(ExerciseObject *e in self.todaysExercises) {
        if([e.name isEqualToString:self.exercises[indexPath.row].name]) {
            isToday = YES;
        }
    }
    
    if(!isToday) {
        UIContextualAction *doToday = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Do Today" handler:^(UIContextualAction *action, UIView *sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Do Today?" message:@"If you confirm, you MUST to do it today ;)" preferredStyle:UIAlertControllerStyleAlert];
            [ac addAction:[UIAlertAction actionWithTitle:@"Wimp Out" style:UIAlertActionStyleCancel handler:nil]];
            [ac addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                ExerciseObject *e = self.exercises[indexPath.row];
                int newGoal = e.goal;
                if(e.goal == e.completed)
                    newGoal = e.goal + e.increment;
                else if(e.completed > e.goal)
                    newGoal = e.completed;
                
                ExerciseObject *temp = [[ExerciseObject alloc] initWithName:e.name goal:newGoal completed:0 increment:e.increment period:e.period identifier:e.identifier + 1 date:[NSDate date] notificationsEnabled:e.notificationsEnabled notificationHour:e.notificationHour];
                [[CDManager sharedManager] saveExercise:temp];
                
                //Change the colors and stuff
                self.todaysExercises = [[CDManager sharedManager] getTodaysExercises];
                [self.tableView reloadData];
                
                [[NetworkManager sharedManager] setToday:[KFKeychain loadObjectForKey:@"DeviceToken"] exerciseName:temp.name];
            }]];
            [self presentViewController:ac animated:YES completion:nil];
        }];
        
        //:UITableViewRowActionStyleNormal title:@"Do Today" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [doToday setBackgroundColor:GREEN];
        
        return [UISwipeActionsConfiguration configurationWithActions:@[doToday]];
    }
    return nil;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Delete?" message:@"Are you sure you want to delete this exercise? You will lose all historical data!" preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NetworkManager sharedManager] deleteNotifications:[KFKeychain loadObjectForKey:@"DeviceToken"] exerciseName:self.exercises[indexPath.row].name];
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [[CDManager sharedManager] deleteAllExercisesNamed:self.exercises[indexPath.row].name];
            [self loadEverything];
            [self.tableView endUpdates];
            [self.tableView reloadData];
        }]];
        [ac addAction:[UIAlertAction actionWithTitle:@"No Way" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    }];
    
    return @[delete];
}

- (void)tappedDoTodayRedundant:(UIButton *)sender {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"That's right!" message:@"You've got to do it today. No procrastination. It would be faster to do it than change it anyways ;)" preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Fine" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

@end
