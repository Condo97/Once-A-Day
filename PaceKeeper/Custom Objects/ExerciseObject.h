//
//  ExerciseObject.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/18/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExerciseObject : NSObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic) int goal, completed, increment, period, identifier, notificationHour;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic) BOOL notificationsEnabled;

- (id)init;
- (id)initWithName:(NSString *)name goal:(int)goal completed:(int)completed increment:(int)increment period:(int)period identifier:(int)identifier date:(NSDate *)date notificationsEnabled:(BOOL)notificationsEnabled notificationHour:(int)notificationHour;

@end
