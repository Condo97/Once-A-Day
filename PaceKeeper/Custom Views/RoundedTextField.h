//
//  RoundedTextField.h
//  EReceipts
//
//  Created by Alex Coundouriotis on 5/11/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundedTextField : UITextField

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

- (void)setTheBorderColorLater:(UIColor *)theBorderColor;

@end
