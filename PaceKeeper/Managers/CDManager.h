//
//  CDHandler.h
//  Calc
//
//  Created by Alex Coundouriotis on 6/13/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "ExerciseObject.h"

@interface CDManager : NSObject

+ (id)sharedManager;
- (int)getHighestId:(NSString *)name;
- (int)getIncrement:(NSString *)name;
- (ExerciseObject *)getMostRecentExercise:(NSString *)name;
- (NSArray *)getPastExercises:(NSString *)name;
- (int)getTotalForExercise:(NSString *)name;
- (int)getCountForExercise:(NSString *)name;
- (NSArray<ExerciseObject *> *)getAllRecentExercises;
- (NSArray<ExerciseObject *> *)getTodaysExercises;
- (NSArray<ExerciseObject *> *)getAddedExercises;
- (void)saveExercise:(ExerciseObject *)exercise;
- (void)deleteExercise:(ExerciseObject *)exercise;
- (void)deleteExerciseNamed:(NSString *)name;
- (void)deleteAllExercisesNamed:(NSString *)name;
- (void)updateLatestExercise:(NSString *)oldName withExercise:(ExerciseObject *)exercise;
- (BOOL)nameExists:(NSString *)name;

@end
