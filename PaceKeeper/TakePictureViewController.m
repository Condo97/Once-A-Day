//
//  TakePictureViewController.m
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 7/16/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "TakePictureViewController.h"

@interface TakePictureViewController ()

@end

@implementation TakePictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *photoImage = [[UIImage imageNamed:@"Picture"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *selectImage = [[UIImage imageNamed:@"Custom"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *photoButton = [[UIButton alloc] initWithFrame:self.takePhotoView.bounds];
    UIButton *selectButton = [[UIButton alloc] initWithFrame:self.selectPhotoView.bounds];
    
    [photoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [selectButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.takePhotoImage setImage:photoImage];
    [self.selectPhotoImage setImage:selectImage];
    
    [self.takePhotoImage setTintColor:BLUE];
    [self.selectPhotoImage setTintColor:BLUE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)takePhoto:(id)sender {
    
}

- (void)selectPhoto:(id)sender {
    
}

@end
