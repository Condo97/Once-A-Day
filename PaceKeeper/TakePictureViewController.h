//
//  TakePictureViewController.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 7/16/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.pch"

@interface TakePictureViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet RoundedView *takePhotoView;
@property (weak, nonatomic) IBOutlet UIImageView *takePhotoImage;
@property (weak, nonatomic) IBOutlet RoundedView *selectPhotoView;
@property (weak, nonatomic) IBOutlet UIImageView *selectPhotoImage;

@end
