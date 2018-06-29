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
- (void)registerDevice:(NSData *)deviceToken exerciseName:(NSString *)exerciseName interval:(int)interval;

@end
