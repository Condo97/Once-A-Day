//
//  CustomImage.m
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 7/16/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "CustomImage.h"

@implementation CustomImage

- (id)initWithImage:(UIImage *)image date:(NSDate *)date {
    self = [super init];
    
    self.image = image;
    self.date = date;
    
    return self;
}

@end
