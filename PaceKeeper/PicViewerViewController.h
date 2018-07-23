//
//  PicViewerViewController.h
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 7/17/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import "Defines.pch"
#import "HJImagesToVideo.h"

@interface PicViewerViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet PreviewRoundedView *previewView;
@property (weak, nonatomic) IBOutlet ImageScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *speedImage;
@property (weak, nonatomic) IBOutlet UIImageView *playImage;
@property (weak, nonatomic) IBOutlet UIImageView *downloadImage;

@property (weak, nonatomic) IBOutlet UIButton *speedButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
