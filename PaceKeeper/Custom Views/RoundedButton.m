//
//  RoundedButton.m
//  EReceipts
//
//  Created by Alex Coundouriotis on 3/1/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "RoundedButton.h"

@implementation RoundedButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.layer setShadowColor:self.shadowColor.CGColor];
    [self.layer setShadowRadius:self.shadowRadius];
    [self.layer setShadowOffset:self.shadowOffset];
    [self.layer setShadowOpacity:self.shadowOpacity / 100];
    [self setClipsToBounds:NO];
    NSLog(@"%@", [NSThread currentThread]);

    self.roundedView = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.roundedView setFrame:self.bounds];
    [self.roundedView addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.roundedView setBackgroundColor:self.theBackgroundColor];
    [self.roundedView.layer setMasksToBounds:YES];
    [self.roundedView setTitle:(NSString *)self.currentTitle forState:UIControlStateNormal];
    [self.roundedView.titleLabel setFont:self.titleLabel.font];
    [self.roundedView setTitleColor:self.tintColor forState:UIControlStateNormal];
    [self setTitle:@"" forState:UIControlStateNormal];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:CGPointMake(self.roundedView.frame.size.width * 2 / 3, self.roundedView.frame.size.height / 2)];
    [self addSubview:self.activityIndicator];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator stopAnimating];
    
    if(self.useBorder) {
        [self.roundedView.layer setCornerRadius:self.cornerRadius];
        [self.roundedView.layer setBorderColor:self.theBorderColor.CGColor];
        [self.roundedView.layer setBorderWidth:self.theBorderWidth];
    }

    [self addSubview:self.roundedView];

    if(self.image != NULL) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        [imageView setFrame:self.bounds];
        [self addSubview:imageView];
        [self sendSubviewToBack:imageView];
    }

    [self sendSubviewToBack:self.roundedView];
}

- (void)setActivityIndicatorAnimating:(BOOL)animating {
    if(animating)
        [self.activityIndicator startAnimating];
    else
        [self.activityIndicator stopAnimating];
}

- (void)handleTap:(UIButton *)button {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)setTheBorderColorLater:(UIColor *)theBorderColor {
    [self.roundedView.layer setBorderColor:theBorderColor.CGColor];
}

- (void)setTitleColorLater:(UIColor *)titleColor forControlState:(UIControlState)controlState {
    [self.roundedView setTitleColor:titleColor forState:controlState];
}

@end
