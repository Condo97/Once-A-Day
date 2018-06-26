//
//  RoundedTextField.m
//  EReceipts
//
//  Created by Alex Coundouriotis on 5/11/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "RoundedTextField.h"

@implementation RoundedTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setClipsToBounds:NO];
    
    //UIView *roundedView = [[UIView alloc] initWithFrame:self.bounds];
    [self setBackgroundColor:self.theBackgroundColor];
    [self.layer setCornerRadius:self.cornerRadius];
    [self.layer setMasksToBounds:YES];
    
    if(self.useBorder) {
        [self.layer setBorderColor:self.theBorderColor.CGColor];
        [self.layer setBorderWidth:self.theBorderWidth];
    }
    
    //[self addSubview:roundedView];
    
    if(self.image != NULL) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        [imageView setFrame:self.bounds];
        [self addSubview:imageView];
        [self sendSubviewToBack:imageView];
    }
    
    //[self sendSubviewToBack:roundedView];
}

- (void)setTheBorderColorLater:(UIColor *)theBorderColor {
    [self.layer setBorderColor:theBorderColor.CGColor];
}

@end
