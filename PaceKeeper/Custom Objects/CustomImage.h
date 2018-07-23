//
//  CustomImage.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 7/16/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CustomImage : NSObject

- (id)initWithImage:(UIImage *)image date:(NSDate *)date;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSDate *date;

@end
