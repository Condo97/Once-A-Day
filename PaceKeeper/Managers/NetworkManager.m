//
//  NetworkManager.m
//  EReceipts
//
//  Created by Alex Coundouriotis on 2/27/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "NetworkManager.h"
#import "CDManager.h"
#import "ExerciseObject.h"

#define BASE_URL @"https://onceaday.acapplications.com/"

@implementation NetworkManager

+ (id)sharedManager {
    static NetworkManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

- (void)registerDevice:(NSData *)deviceToken exerciseName:(NSString *)exerciseName interval:(int)interval date:(NSDate *)date {
    NSError __block *error;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *startDate = [dateFormatter stringFromDate:date];
    NSString *encodedDeviceToken = [NSString stringWithFormat:@"%@", deviceToken];
    
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             encodedDeviceToken, @"DeviceToken",
                             exerciseName, @"ExerciseName",
                             [NSString stringWithFormat:@"%d", interval], @"Interval",
                             startDate, @"StartDate",
                             nil];
    NSError *toPostSerializationError;
    NSData *dataToPost = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&toPostSerializationError];
    
    if(toPostSerializationError == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@saveDevice", BASE_URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:dataToPost];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *urlResponse,
                                        NSError *httpError) {
                        if(httpError == nil) {
                            NSError *errorJSON;
                            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
                            if(errorJSON == nil) {
                                if((int)[[responseJSON objectForKey:@"Success"] intValue] == 1) {
                                    NSLog(@"Yay it worked!");
                                } else {
                                    NSLog(@"Error1!\n%@", errorJSON);
                                }
                            } else {
                                NSLog(@"Error2!\n%@", errorJSON);
                            }
                        } else {
                            NSLog(@"Error3!\n%@", error);
                        }
                    }] resume];
    } else {
        NSLog(@"Error4!\n%@", error);
    }
}

- (void)toggleNotifications:(NSData *)deviceToken exerciseName:(NSString *)exerciseName enabled:(BOOL)enabled {
    NSError __block *error;
    NSString *encodedDeviceToken = [NSString stringWithFormat:@"%@", deviceToken];
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             encodedDeviceToken, @"DeviceToken",
                             exerciseName, @"ExerciseName",
                             [NSString stringWithFormat:@"%d", enabled], @"Enabled",
                             nil];
    NSError *toPostSerializationError;
    NSData *dataToPost = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&toPostSerializationError];
    
    if(toPostSerializationError == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@toggleNotifications", BASE_URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:dataToPost];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *urlResponse,
                                        NSError *httpError) {
                        if(httpError == nil) {
                            NSError *errorJSON;
                            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
                            if(errorJSON == nil) {
                                if((int)[[responseJSON objectForKey:@"Success"] intValue] == 1) {
                                    NSLog(@"Yay it worked!");
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        ExerciseObject *eo = [[CDManager sharedManager] getMostRecentExercise:[responseJSON objectForKey:@"ExerciseName"]];
                                        BOOL enabled = ((NSNumber *)[responseJSON objectForKey:@"Enabled"]).boolValue;
                                        
                                        [[CDManager sharedManager] updateNotificationsEnabled:eo enabled:enabled];
                                    });
                                } else {
                                    NSLog(@"Error1!\n%@", errorJSON);
                                }
                            } else {
                                NSLog(@"Error2!\n%@", errorJSON);
                            }
                        } else {
                            NSLog(@"Error3!\n%@", error);
                        }
                    }] resume];
    } else {
        NSLog(@"Error4!\n%@", error);
    }
}

- (void)setNotificationHour:(NSData *)deviceToken exerciseName:(NSString *)exerciseName notificationHour:(int)notificationHour {
    NSError __block *error;
    NSString *encodedDeviceToken = [NSString stringWithFormat:@"%@", deviceToken];
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             encodedDeviceToken, @"DeviceToken",
                             exerciseName, @"ExerciseName",
                             [NSString stringWithFormat:@"%d", notificationHour], @"Hour",
                             nil];
    NSError *toPostSerializationError;
    NSData *dataToPost = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&toPostSerializationError];
    
    if(toPostSerializationError == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@setNotificationHour", BASE_URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:dataToPost];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *urlResponse,
                                        NSError *httpError) {
                        if(httpError == nil) {
                            NSError *errorJSON;
                            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
                            if(errorJSON == nil) {
                                if((int)[[responseJSON objectForKey:@"Success"] intValue] == 1) {
                                    NSLog(@"Yay it worked!");
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        ExerciseObject *eo = [[CDManager sharedManager] getMostRecentExercise:[responseJSON objectForKey:@"ExerciseName"]];
                                        int hour = ((NSNumber *)[responseJSON objectForKey:@"Hour"]).intValue;
                                        
                                        [[CDManager sharedManager] updateNotificationHour:eo hour:hour];
                                    });
                                } else {
                                    NSLog(@"Error1!\n%@", errorJSON);
                                }
                            } else {
                                NSLog(@"Error2!\n%@", errorJSON);
                            }
                        } else {
                            NSLog(@"Error3!\n%@", error);
                        }
                    }] resume];
    } else {
        NSLog(@"Error4!\n%@", error);
    }
}

- (void)setToday:(NSData *)deviceToken exerciseName:(NSString *)exerciseName {
    NSError __block *error;
    NSString *encodedDeviceToken = [NSString stringWithFormat:@"%@", deviceToken];
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             encodedDeviceToken, @"DeviceToken",
                             exerciseName, @"ExerciseName",
                             nil];
    NSError *toPostSerializationError;
    NSData *dataToPost = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&toPostSerializationError];
    
    if(toPostSerializationError == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@setToday", BASE_URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:dataToPost];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *urlResponse,
                                        NSError *httpError) {
                        if(httpError == nil) {
                            NSError *errorJSON;
                            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
                            if(errorJSON == nil) {
                                if((int)[[responseJSON objectForKey:@"Success"] intValue] == 1) {
                                    NSLog(@"Yay it worked!");
                                } else {
                                    NSLog(@"Error1!\n%@", errorJSON);
                                }
                            } else {
                                NSLog(@"Error2!\n%@", errorJSON);
                            }
                        } else {
                            NSLog(@"Error3!\n%@", error);
                        }
                    }] resume];
    } else {
        NSLog(@"Error4!\n%@", error);
    }
}

- (void)deleteNotifications:(NSData *)deviceToken exerciseName:(NSString *)exerciseName {
    NSError __block *error;
    NSString *encodedDeviceToken = [NSString stringWithFormat:@"%@", deviceToken];
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             encodedDeviceToken, @"DeviceToken",
                             exerciseName, @"ExerciseName",
                             nil];
    NSError *toPostSerializationError;
    NSData *dataToPost = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:&toPostSerializationError];
    
    if(toPostSerializationError == nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@deleteNotifications", BASE_URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:20.0];
        [request setHTTPBody:dataToPost];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *urlResponse,
                                        NSError *httpError) {
                        if(httpError == nil) {
                            NSError *errorJSON;
                            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
                            if(errorJSON == nil) {
                                if((int)[[responseJSON objectForKey:@"Success"] intValue] == 1) {
                                    NSLog(@"Yay it worked!");
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        ExerciseObject *eo = [[CDManager sharedManager] getMostRecentExercise:[responseJSON objectForKey:@"ExerciseName"]];
                                        BOOL enabled = ((NSNumber *)[responseJSON objectForKey:@"Enabled"]).boolValue;
                                        
                                        [[CDManager sharedManager] updateNotificationsEnabled:eo enabled:enabled];
                                    });
                                } else {
                                    NSLog(@"Error1!\n%@", errorJSON);
                                }
                            } else {
                                NSLog(@"Error2!\n%@", errorJSON);
                            }
                        } else {
                            NSLog(@"Error3!\n%@", error);
                        }
                    }] resume];
    } else {
        NSLog(@"Error4!\n%@", error);
    }
}

@end

