//
//  PreviewRoundedView.m
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 7/17/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "PreviewRoundedView.h"

@implementation PreviewRoundedView

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor cornerRadius:(int)cornerRadius {
    self = [super initWithFrame:frame];
    
    self.theBackgroundColor = backgroundColor;
    self.cornerRadius = cornerRadius;
    //[self.imageView.layer setMinificationFilter:kCAFilterTrilinear];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self.roundedView setFrame:rect];
    
    CGRect imageViewFrame = rect;
    imageViewFrame.size.height = imageViewFrame.size.height + 1;
    [self.imageView setFrame:imageViewFrame];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //    [self.layer setShadowColor:self.shadowColor.CGColor];
    //    [self.layer setShadowRadius:self.shadowRadius];
    //    [self.layer setShadowOffset:self.shadowOffset];
    //    [self.layer setShadowOpacity:self.shadowOpacity / 100];
    [self setClipsToBounds:YES];
    
    self.roundedView = [[UIView alloc] initWithFrame:self.bounds];
    [self.roundedView setBackgroundColor:self.theBackgroundColor];
    [self.roundedView.layer setCornerRadius:self.cornerRadius];
    [self.roundedView.layer setMasksToBounds:YES];
    
    if(self.useBorder) {
        [self.roundedView.layer setBorderColor:self.theBorderColor.CGColor];
        [self.roundedView.layer setBorderWidth:self.theBorderWidth];
    }
    
    [self addSubview:self.roundedView];

    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    CGRect imageViewFrame = self.roundedView.bounds;
    imageViewFrame.size.height = imageViewFrame.size.height + 1;
    [self.imageView setFrame:imageViewFrame];
    [self.imageView setClipsToBounds:YES];
    [self.roundedView addSubview:self.imageView];
    
    [self sendSubviewToBack:self.roundedView];
}

- (void)setTheBackgroundColorLater:(UIColor *)theBackgroundColor {
    [self.roundedView setBackgroundColor:theBackgroundColor];
}

- (void)setTheBorderColorLater:(UIColor *)theBorderColor {
    [self.roundedView.layer setBorderColor:theBorderColor.CGColor];
}

@end
