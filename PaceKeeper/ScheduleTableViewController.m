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

@interface ScheduleTableViewController ()

@property (strong, nonatomic) NSArray<ExerciseObject *> *exercises, *todaysExercises;
@property (strong, nonatomic) NSArray<NSString *> *predefinedIntervals;

@end

@implementation ScheduleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.todaysExercises = [[CDManager sharedManager] getTodaysExercises];
    self.predefinedIntervals = PREDEFINED_INTERVALS;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadEverything];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
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
//
//    if(isToday) {
//        [cell.doTodayText setTextColor:[UIColor lightTextColor]];
//        [cell.doTodayBackground setBackgroundColor:GREEN];
//        UIButton *button = [[UIButton alloc] initWithFrame:cell.doTodayBackground.bounds];
//        [button setTag:indexPath.row];
//        [button addTarget:self action:@selector(tappedDoTodayRedundant:) forControlEvents:UIControlEventTouchDown];
//        [cell.doTodayBackground addSubview:button];
//
//    } else {
//        [cell.doTodayText setTextColor:GREEN];
//        [cell.doTodayBackground setBackgroundColor:[UIColor whiteColor]];
//
//        UIButton *button = [[UIButton alloc] initWithFrame:cell.doTodayBackground.bounds];
//        [button setTag:indexPath.row];
//        [button addTarget:self action:@selector(tappedDoToday:) forControlEvents:UIControlEventTouchDown];
//        [cell.doTodayBackground addSubview:button];
//    }
    
//    if(self.isEditing)
//       [cell.editLeadingConstraint setConstant:0];
//    else
//        [cell.editLeadingConstraint setConstant:-75];
    
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
        [hvc setExerciseName:self.exercises[ip.row].name];
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
                ExerciseObject *temp = [[ExerciseObject alloc] initWithName:e.name goal:e.goal completed:0 increment:e.increment period:e.period identifier:e.identifier + 1 date:[NSDate date]];
                [[CDManager sharedManager] saveExercise:temp];
                
                //Change the colors and stuff
                self.todaysExercises = [[CDManager sharedManager] getTodaysExercises];
                [self.tableView reloadData];
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
    
//    BOOL isToday = NO;
//    for(ExerciseObject *e in self.todaysExercises) {
//        if([e.name isEqualToString:self.exercises[indexPath.row].name]) {
//            isToday = YES;
//        }
//    }
//
//    if(!isToday) {
//        UITableViewRowAction *doToday = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Do Today" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Do Today?" message:@"If you confirm, you MUST to do it today ;)" preferredStyle:UIAlertControllerStyleAlert];
//            [ac addAction:[UIAlertAction actionWithTitle:@"Wimp Out" style:UIAlertActionStyleCancel handler:nil]];
//            [ac addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                ExerciseObject *e = self.exercises[indexPath.row];
//                ExerciseObject *temp = [[ExerciseObject alloc] initWithName:e.name goal:e.goal completed:0 increment:e.increment period:e.period identifier:e.identifier + 1 date:[NSDate date]];
//                [[CDManager sharedManager] saveExercise:temp];
//
//                //Change the colors and stuff
//                self.todaysExercises = [[CDManager sharedManager] getTodaysExercises];
//                [self.tableView reloadData];
//            }]];
//            [self presentViewController:ac animated:YES completion:nil];
//        }];
//
//        [doToday setBackgroundColor:GREEN];
//
//        return @[delete, doToday];
//    }
    
    return @[delete];
}

- (void)tappedDoTodayRedundant:(UIButton *)sender {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"That's right!" message:@"You've got to do it today. No procrastination. It would be faster to do it than change it anyways ;)" preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Fine" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

@end
