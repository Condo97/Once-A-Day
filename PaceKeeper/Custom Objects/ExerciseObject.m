//
//  ExerciseObject.m
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/18/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "ExerciseObject.h"

@implementation ExerciseObject

- (id)init {
    self = [super init];
    
    self.name = @"";
    self.goal = -1;
    self.completed = 0;
    self.increment = -1;
    self.period = -1;
    self.identifier = 0;
    self.date = nil;
    self.notificationsEnabled = NO;
    self.notificationHour = 10;
    
    return self;
}

- (id)initWithName:(NSString *)name goal:(int)goal completed:(int)completed increment:(int)increment period:(int)period identifier:(int)identifier date:(NSDate *)date notificationsEnabled:(BOOL)notificationsEnabled notificationHour:(int)notificationHour {
    self = [super init];
    
    self.name = name;
    self.goal = goal;
    self.completed = completed;
    self.increment = increment;
    self.period = period;
    self.identifier = identifier;
    self.date = date;
    self.notificationsEnabled = notificationsEnabled;
    self.notificationHour = notificationHour;
    
    return self;
}

@end
