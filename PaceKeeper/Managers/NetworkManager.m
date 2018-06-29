//
//  NetworkManager.m
//  EReceipts
//
//  Created by Alex Coundouriotis on 2/27/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "NetworkManager.h"
#import "CDManager.h"

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

- (void)registerDevice:(NSData *)deviceToken exerciseName:(NSString *)exerciseName interval:(int)interval {
    NSError __block *error;
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             deviceToken.bytes, @"DeviceToken",
                             exerciseName, @"ExerciseName",
                             [NSString stringWithFormat:@"%d", interval], @"Interval",
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

@end

