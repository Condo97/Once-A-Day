//
//  CDHandler.m
//  Calc
//
//  Created by Alex Coundouriotis on 6/13/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "CDManager.h"
#import "AppDelegate.h"

@implementation CDManager

+ (id)sharedManager {
    static CDManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (int)getHighestId:(NSString *)name {
    int identifier = 0;
    
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        int temp = ((NSNumber *)[object valueForKey:@"id"]).intValue;
        if(temp > identifier)
            identifier = temp;
    }
    
    return identifier;
}

- (ExerciseObject *)getMostRecentExercise:(NSString *)name {
    ExerciseObject *obj = [[ExerciseObject alloc] init];
    int objID = -1;
    
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        int temp = ((NSNumber *)[object valueForKey:@"id"]).intValue;
        if([[object valueForKey:@"name"] isEqualToString:name]) {
            if(temp > objID) {
                objID = obj.identifier;
                obj = [[ExerciseObject alloc] initWithName:[object valueForKey:@"name"]
                                                    goal:((NSNumber *)[object valueForKey:@"goal"]).intValue
                                                    completed:((NSNumber *)[object valueForKey:@"completed"]).intValue
                                                 increment:((NSNumber *)[object valueForKey:@"increment"]).intValue
                                                    period:((NSNumber *)[object valueForKey:@"period"]).intValue
                                                identifier:((NSNumber *)[object valueForKey:@"id"]).intValue
                                                      date:[object valueForKey:@"date"] notificationsEnabled:((NSNumber *)[object valueForKey:@"notificationsEnabled"]).boolValue notificationHour:((NSNumber *)[object valueForKey:@"notificationHour"]).intValue];
            }
        }
    }
    
    return obj;
}

- (int)getIncrement:(NSString *)name {
    int increment = 0;
    int identifier = [self getHighestId:name];
    
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        if([[object valueForKey:@"name"] isEqualToString:name] && ((NSNumber *)[object valueForKey:@"id"]).intValue == identifier) {
            increment = ((NSNumber *)[object valueForKey:@"increment"]).intValue;
        }
    }
    
    return increment;
}

- (NSArray *)getPastExercises:(NSString *)name {
    NSMutableArray *exercises = [[NSMutableArray alloc] init];
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        if([[object valueForKey:@"name"] isEqualToString:name]) {
            ExerciseObject *obj = [[ExerciseObject alloc] initWithName:[object valueForKey:@"name"]
                                                                  goal:((NSNumber *)[object valueForKey:@"goal"]).intValue
                                                             completed:((NSNumber *)[object valueForKey:@"completed"]).intValue
                                                             increment:((NSNumber *)[object valueForKey:@"increment"]).intValue
                                                                period:((NSNumber *)[object valueForKey:@"period"]).intValue
                                                            identifier:((NSNumber *)[object valueForKey:@"id"]).intValue
                                                                  date:[object valueForKey:@"date"] notificationsEnabled:((NSNumber *)[object valueForKey:@"notificationsEnabled"]).boolValue notificationHour:((NSNumber *)[object valueForKey:@"notificationHour"]).intValue];
            [exercises addObject:obj];
        }
    }
    
    return exercises;//[[exercises reverseObjectEnumerator] allObjects];
}

- (int)getTotalForExercise:(NSString *)name {
    int total = 0;
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        if([[object valueForKey:@"name"] isEqualToString:name]) {
            total += ((NSNumber *)[object valueForKey:@"completed"]).intValue;
        }
    }
    
    return total;
}

- (int)getCountForExercise:(NSString *)name {
    int count = 0;
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        if([[object valueForKey:@"name"] isEqualToString:name]) {
            count++;
        }
    }
    
    return count;
}

- (NSArray<ExerciseObject *> *)getAllRecentExercises {
    NSMutableArray<ExerciseObject *> *exercises = [[NSMutableArray alloc] init];
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        BOOL contains = NO;
        for(ExerciseObject *exercise in exercises) {
            if([exercise.name isEqualToString:[object valueForKey:@"name"]])
                contains = YES;
        }
        
        if(!contains) {
            ExerciseObject *obj = [self getMostRecentExercise:[object valueForKey:@"name"]];
            [exercises addObject:obj];
        }
    }
    
    return exercises;//[[exercises reverseObjectEnumerator] allObjects];
}

- (NSArray<ExerciseObject *> *)getTodaysExercises {
    NSMutableArray<ExerciseObject *> *exercises = [[NSMutableArray alloc] init];
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        BOOL contains = NO;
        for(ExerciseObject *exercise in exercises) {
            if([exercise.name isEqualToString:[object valueForKey:@"name"]])
                contains = YES;
        }
        
        if(!contains) {
            ExerciseObject *obj = [self getMostRecentExercise:[object valueForKey:@"name"]];
            if([self exerciseIsToday:obj])
                [exercises addObject:obj];
        }
    }
    
    return exercises;//[[exercises reverseObjectEnumerator] allObjects];
}

- (NSArray<ExerciseObject *> *)getAddedExercises {
    NSMutableArray<ExerciseObject *> *exercises = [[NSMutableArray alloc] init];
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        BOOL contains = NO;
        for(ExerciseObject *exercise in exercises) {
            if([exercise.name isEqualToString:[object valueForKey:@"name"]])
                contains = YES;
        }
        
        if(!contains) {
            ExerciseObject *obj = [self getMostRecentExercise:[object valueForKey:@"name"]];
            if([self exerciseAlreadyAdded:obj])
                [exercises addObject:obj];
        }
    }
    
    return exercises;//[[exercises reverseObjectEnumerator] allObjects];
}

- (void)saveExercise:(ExerciseObject *)exercise {
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:context];

    [managedObject setValue:exercise.name forKey:@"name"];
    [managedObject setValue:[NSNumber numberWithInt:exercise.goal] forKey:@"goal"];
    [managedObject setValue:[NSNumber numberWithInt:exercise.completed] forKey:@"completed"];
    [managedObject setValue:[NSNumber numberWithInt:exercise.increment] forKey:@"increment"];
    [managedObject setValue:[NSNumber numberWithInt:exercise.period] forKey:@"period"];
    [managedObject setValue:[NSNumber numberWithInt:exercise.identifier] forKey:@"id"];
    [managedObject setValue:exercise.date forKey:@"date"];
    [managedObject setValue:[NSNumber numberWithBool:exercise.notificationsEnabled] forKey:@"notificationsEnabled"];
    [managedObject setValue:[NSNumber numberWithInt:exercise.notificationHour] forKey:@"notificationHour"];
    
    NSError *error;
    [context save:&error];
}

- (void)deleteExerciseNamed:(NSString *)name {
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        if([[object valueForKey:@"name"] isEqualToString:name])
            [context deleteObject:object];
    }
    
    NSError *error2;
    [context save:&error2];
}

- (void)deleteExercise:(ExerciseObject *)exercise {
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        if([[object valueForKey:@"name"] isEqualToString:exercise.name])
            if([[object valueForKey:@"date"] isEqual:exercise.date])
                [context deleteObject:object];
    }
    
    NSError *error2;
    [context save:&error2];
}

- (void)deleteAllExercisesNamed:(NSString *)name {
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        if([[object valueForKey:@"name"] isEqualToString:name])
            [context deleteObject:object];
    }
    
    NSError *error2;
    [context save:&error2];
}

- (void)updateLatestExercise:(NSString *)oldName withExercise:(ExerciseObject *)exercise {
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *managedObjects = [context executeFetchRequest:request error:&error];
    
    ExerciseObject *tempExercise = [self getMostRecentExercise:oldName];
    
    for(NSManagedObject *object in managedObjects) {
        if([oldName isEqualToString:[object valueForKey:@"name"]] && [[object valueForKey:@"date"] isEqualToDate:tempExercise.date]) {
            [object setValue:exercise.name forKey:@"name"];
            [object setValue:[NSNumber numberWithInt:exercise.goal] forKey:@"goal"];
            [object setValue:[NSNumber numberWithInt:exercise.completed] forKey:@"completed"];
            [object setValue:[NSNumber numberWithInt:exercise.increment] forKey:@"increment"];
            [object setValue:[NSNumber numberWithInt:exercise.period] forKey:@"period"];
            [object setValue:[NSNumber numberWithInt:exercise.identifier] forKey:@"id"];
            [object setValue:exercise.date forKey:@"date"];
            [object setValue:[NSNumber numberWithBool:exercise.notificationsEnabled] forKey:@"notificationsEnabled"];
            [object setValue:[NSNumber numberWithInt:exercise.notificationHour] forKey:@"notificationHour"];
            
            
        }
    }
    
    NSError *error2;
    [context save:&error2];
}

- (BOOL)exerciseIsToday:(ExerciseObject *)exercise {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:exercise.date];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:[NSDate date]];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    if(difference.day % (exercise.period + 1) == 0)
        return YES;
    return NO;
}

- (BOOL)exerciseAlreadyAdded:(ExerciseObject *)exercise {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:exercise.date];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:[NSDate date]];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    if(difference.day == 0)
        return YES;
    return NO;
}

- (BOOL)nameExists:(NSString *)name {
    BOOL exists = NO;
    
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *object in resultArray) {
        if([[object valueForKey:@"name"] isEqualToString:name])
            exists = YES;
    }
    
    return exists;
}

- (void)updateNotificationsEnabled:(ExerciseObject *)exercise enabled:(BOOL)enabled {
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *managedObjects = [context executeFetchRequest:request error:&error];
    
    ExerciseObject *tempExercise = [self getMostRecentExercise:exercise.name];
    
    for(NSManagedObject *object in managedObjects) {
        if([exercise.name isEqualToString:[object valueForKey:@"name"]] && [[object valueForKey:@"date"] isEqualToDate:tempExercise.date]) {
            [object setValue:[NSNumber numberWithBool:enabled] forKey:@"notificationsEnabled"];
        }
    }
    
    NSError *error2;
    [context save:&error2];
}

- (void)updateNotificationHour:(ExerciseObject *)exercise hour:(int)hour {
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSError *error;
    NSArray *managedObjects = [context executeFetchRequest:request error:&error];
    
    ExerciseObject *tempExercise = [self getMostRecentExercise:exercise.name];
    
    for(NSManagedObject *object in managedObjects) {
        if([exercise.name isEqualToString:[object valueForKey:@"name"]] && [[object valueForKey:@"date"] isEqualToDate:tempExercise.date]) {
            [object setValue:[NSNumber numberWithInt:hour] forKey:@"notificationHour"];
        }
    }
    
    NSError *error2;
    [context save:&error2];
}

@end
