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
#import "Defines.pch"

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
- (void)updateNotificationsEnabled:(ExerciseObject *)exercise enabled:(BOOL)enabled;
- (void)updateNotificationHour:(ExerciseObject *)exercise hour:(int)hour;
- (void)saveImage:(CustomImage *)image;
- (NSArray<CustomImage *> *)getAllImages;
- (NSArray<UIImage *> *)getAllImagesWithoutDate;
- (BOOL)imageExistsToday;
- (NSDate *)getLastPictureDate;

@end
