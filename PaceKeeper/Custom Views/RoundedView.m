//
//  RoundedView.m
//  EReceipts
//
//  Created by Alex Coundouriotis on 3/1/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "RoundedView.h"

@implementation RoundedView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

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
}

- (void)awakeFromNib {
    [super awakeFromNib];
//    [self.layer setShadowColor:self.shadowColor.CGColor];
//    [self.layer setShadowRadius:self.shadowRadius];
//    [self.layer setShadowOffset:self.shadowOffset];
//    [self.layer setShadowOpacity:self.shadowOpacity / 100];
    [self setClipsToBounds:NO];
    
    self.roundedView = [[UIView alloc] initWithFrame:self.bounds];
    [self.roundedView setBackgroundColor:self.theBackgroundColor];
    [self.roundedView.layer setCornerRadius:self.cornerRadius];
    [self.roundedView.layer setMasksToBounds:YES];
    
    if(self.useBorder) {
        [self.roundedView.layer setBorderColor:self.theBorderColor.CGColor];
        [self.roundedView.layer setBorderWidth:self.theBorderWidth];
    }
    
    [self addSubview:self.roundedView];
    
    if(self.image != NULL) {
        self.imageView = [[UIImageView alloc] initWithImage:self.image];
        [self.imageView setFrame:self.bounds];
        [self addSubview:self.imageView];
        [self sendSubviewToBack:self.imageView];
    }
    
    [self sendSubviewToBack:self.roundedView];
}

- (void)setTheBackgroundColorLater:(UIColor *)theBackgroundColor {
    [self.roundedView setBackgroundColor:theBackgroundColor];
}

- (void)setTheBorderColorLater:(UIColor *)theBorderColor {
    [self.roundedView.layer setBorderColor:theBorderColor.CGColor];
}

- (void)setImageLater:(UIImage *)image {
    [self.imageView setImage:image];
}


@end
