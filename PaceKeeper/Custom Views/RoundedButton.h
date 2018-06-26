//
//  RoundedButton.h
//  EReceipts
//
//  Created by Alex Coundouriotis on 3/1/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundedButton : UIButton

@property (nonatomic) IBInspectable UIColor *shadowColor;
@property (nonatomic) IBInspectable CGFloat shadowRadius;
@property (nonatomic) IBInspectable CGSize shadowOffset;
@property (nonatomic) IBInspectable CGFloat shadowOpacity;

@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable UIColor *theBackgroundColor;
@property (nonatomic) IBInspectable UIImage *image;

@property (nonatomic) IBInspectable BOOL useBorder;
@property (nonatomic) IBInspectable CGFloat theBorderWidth;
@property (nonatomic) IBInspectable UIColor *theBorderColor;

@property (strong, nonatomic) UITapGestureRecognizer* tap;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UIButton *roundedView;

- (void)setActivityIndicatorAnimating:(BOOL)animating;
- (void)setTheBorderColorLater:(UIColor *)theBorderColor;
- (void)setTitleColorLater:(UIColor *)titleColor forControlState:(UIControlState)controlState;

@end
