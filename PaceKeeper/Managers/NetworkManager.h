//
//  NetworkManager.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 6/29/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (id)sharedManager;
- (void)registerDevice:(NSData *)deviceToken exerciseName:(NSString *)exerciseName interval:(int)interval date:(NSDate *)date;
- (void)toggleNotifications:(NSData *)deviceToken exerciseName:(NSString *)exerciseName enabled:(BOOL)enabled;
- (void)setToday:(NSData *)deviceToken exerciseName:(NSString *)exerciseName;
- (void)setNotificationHour:(NSData *)deviceToken exerciseName:(NSString *)exerciseName notificationHour:(int)notificationHour;
- (void)deleteNotifications:(NSData *)deviceToken exerciseName:(NSString *)exerciseName;

@end
