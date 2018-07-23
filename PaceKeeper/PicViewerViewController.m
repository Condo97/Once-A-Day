//
//  PicViewerViewController.m
//  PaceKeeper
//
//  Created by Alex Coundouriotis on 7/17/18.
//  Copyright © 2018 Alex Coundouriotis. All rights reserved.
//

#import "PicViewerViewController.h"

#define PREVIEW_SIZE 67.0
#define FRAME_LENGTH (1.0/(1.5 * (1.0 + (double)self.speed)))

@interface PicViewerViewController ()

@property (strong, nonatomic) NSArray<CustomImage *> *imageArray;
@property (strong, nonatomic) NSArray<UIImage *> *speedImages;
@property (strong, nonatomic) NSTimer *scrollViewTimer;

@property (nonatomic) int speed, currentFrame;
@property (nonatomic) BOOL playing;

@end

@implementation PicViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Progress"];
    
    self.speed = 1;
    self.playing = NO;
    self.speedImages = [[NSArray alloc] initWithObjects:
                        [[UIImage imageNamed:@"Tortoise"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                        [[UIImage imageNamed:@"Hare"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                        [[UIImage imageNamed:@"HareRunning"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate], nil];
    
    [self.playImage setImage:[[UIImage imageNamed:@"Play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.speedImage setImage:self.speedImages[self.speed]];
    [self.downloadImage setImage:[[UIImage imageNamed:@"Download"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    [self.playImage setTintColor:BLUE];
    [self.speedImage setTintColor:BLUE];
    [self.downloadImage setTintColor:BLUE];
    
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator stopAnimating];
    
    self.imageArray = [[CDManager sharedManager] getAllImages].copy;
    
    if(self.imageArray.count != 0)
        [self updateScrollView:0];
    
    if(self.imageArray.count <= 1) {
        [self.playImage setTintColor:[UIColor lightGrayColor]];
        [self.speedImage setTintColor:[UIColor lightGrayColor]];
        [self.downloadImage setTintColor:[UIColor lightGrayColor]];
        
        [self.playButton setEnabled:NO];
        [self.speedButton setEnabled:NO];
        [self.downloadButton setEnabled:NO];
    } else {
        [self.playImage setTintColor:BLUE];
        [self.speedImage setTintColor:BLUE];
        [self.downloadImage setTintColor:BLUE];
    }
    
    [self.imageScrollView.theScrollView setContentSize:CGSizeMake(self.imageArray.count * PREVIEW_SIZE, PREVIEW_SIZE)];
    [self.imageScrollView.theScrollView setDelegate:self];
    
    for(int i = 0; i < self.imageArray.count; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithImage:self.imageArray[i].image];
        [iv setFrame:CGRectMake(i * PREVIEW_SIZE, 0, PREVIEW_SIZE, PREVIEW_SIZE)];
        
        [self.imageScrollView.theScrollView addSubview:iv];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (IBAction)shareButton:(id)sender {
//
//}

- (void)updateScrollView:(int)selectedView {
    if(selectedView >= self.imageArray.count || selectedView < 0 || self.imageArray.count == 0)
        return;
    
    [self.previewView.imageView setImage:self.imageArray[selectedView].image];
    
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:self.imageArray[selectedView].date];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:[NSDate date]];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    NSString *formattedString = [df stringFromDate:self.imageArray[selectedView].date];
    
    if(difference.day == 0)
        formattedString = @"Today";
    else if(difference.day == 1)
        formattedString = @"Yesterday";
    else if(difference.day < 7)
        formattedString = [NSString stringWithFormat:@"%ld days ago", (long)difference.day];
    
    [self.dateLabel setText:[NSString stringWithFormat:@"Taken %@", formattedString]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int selectedView = (int)round(scrollView.contentOffset.x / PREVIEW_SIZE);
    [self updateScrollView:selectedView];
}

- (IBAction)downloadTimelapse:(id)sender {
    [self.downloadButton setEnabled:NO];
    [self.downloadImage setTintColor:[UIColor lightGrayColor]];
    [self.downloadImage setImage:[[UIImage imageNamed:@"DownloadFilled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.activityIndicator startAnimating];
    
    [self renderVideo];
//    NSMutableArray *uiimageArray = [[NSMutableArray alloc] init];
//    for(CustomImage *image in self.imageArray) {
//        [uiimageArray addObject:image.image];
//    }
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self makeAnimatedGif:uiimageArray completion:^(BOOL success) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.downloadButton setEnabled:YES];
//                [self.downloadImage setTintColor:BLUE];
//                [self.downloadImage setImage:[[UIImage imageNamed:@"Download"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
//                
//                if(success) {
//                    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Success!" message:@"Your timelapse has been successfully saved in your photo library!" preferredStyle:UIAlertControllerStyleAlert];
//                    [ac addAction:[UIAlertAction actionWithTitle:@"Cool!" style:UIAlertActionStyleCancel handler:nil]];
//                    [self presentViewController:ac animated:YES completion:nil];
//                } else {
//                    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was an error saving your timelapse to your photo library. Please try again or contact the developer if this keeps happening!" preferredStyle:UIAlertControllerStyleAlert];
//                    [ac addAction:[UIAlertAction actionWithTitle:@"Cool!" style:UIAlertActionStyleCancel handler:nil]];
//                    [self presentViewController:ac animated:YES completion:nil];
//                }
//            });
//        }];
//    });
}

- (IBAction)speedButton:(id)sender {
    if(self.speed == 2)
        self.speed = 0;
    else
        self.speed++;
    
    [self.speedImage setImage:self.speedImages[self.speed]];
}

- (IBAction)playButton:(id)sender {
    if(!self.playing) {
        [self.playImage setImage:[[UIImage imageNamed:@"Pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        
        if(self.currentFrame != 0) {
            [self.imageScrollView.theScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            self.currentFrame = 0;
            
            if(self.speed == 2) {
                [self performSelector:@selector(startTimer:) withObject:nil afterDelay:0.075];
            } else {
                [self moveToNextFrame:nil];
                self.currentFrame = 1;
                [self startTimer:nil];
            }
        } else {
            [self moveToNextFrame:nil];
            self.currentFrame = 1;
            [self startTimer:nil];
        }
        
        [self.playImage setImage:[[UIImage imageNamed:@"Pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        
        self.playing = YES;
        
        [self.speedButton setEnabled:NO];
        [self.speedImage setTintColor:[UIColor lightGrayColor]];
    } else {
        self.playing = NO;
        
        [self.speedButton setEnabled:YES];
        [self.speedImage setTintColor:BLUE];
        
        [self.scrollViewTimer invalidate];
        [self.playImage setImage:[[UIImage imageNamed:@"Play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
}

- (void)startTimer:(id)sender {
    self.scrollViewTimer = [NSTimer scheduledTimerWithTimeInterval:FRAME_LENGTH target:self selector:@selector(moveToNextFrame:) userInfo:nil repeats:YES];
}

- (void)moveToNextFrame:(id)sender {
    [self.imageScrollView.theScrollView setContentOffset:CGPointMake(self.currentFrame * PREVIEW_SIZE, 0) animated:YES];
    self.currentFrame++;
    
    if(self.currentFrame == self.imageArray.count) {
        [self.scrollViewTimer invalidate];
        [self.playImage setImage:[[UIImage imageNamed:@"Play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        self.playing = NO;
        
        [self.speedButton setEnabled:YES];
        [self.speedImage setTintColor:BLUE];
    }
}

- (IBAction)shareButton:(id)sender {
    [self performSegueWithIdentifier:@"toShareView" sender:nil];
}

- (UIImage *)rotate:(UIImage*)src andOrientation:(UIImageOrientation)orientation {
    CGSize contextSize = CGSizeMake(1008, 1334);
    UIGraphicsBeginImageContext(contextSize);
    CGContextRef context = (UIGraphicsGetCurrentContext());
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, 90/180*M_PI) ;
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, -90/180*M_PI);
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, 90/180*M_PI);
    }
    
    if(src.size.width > src.size.height) {
        [src drawInRect:CGRectMake(0, (contextSize.height - contextSize.width) / 2, contextSize.height, contextSize.width)];
    } else {
        [src drawInRect:CGRectMake(0, 0, contextSize.width, contextSize.height)];
    }
    //[src drawInRect:CGRectMake(0, 0, 500, 500)];
    //[src drawAtPoint:CGPointMake(0, 0)];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
}

//static void makeAnimatedGif(void) {
//    static NSUInteger kFrameCount = 16;
//
//    NSDictionary *fileProperties = @{
//                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
//                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
//                                             }
//                                     };
//
//    NSDictionary *frameProperties = @{
//                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
//                                              (__bridge id)kCGImagePropertyGIFDelayTime: @0.02f, // a float (not double!) in seconds, rounded to centiseconds in the GIF data
//                                              }
//                                      };
//
//    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
//    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"animated.gif"];
//
//    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
//    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
//
//    for (NSUInteger i = 0; i < kFrameCount; i++) {
//        @autoreleasepool {
//            UIImage *image = frameImage(CGSizeMake(300, 300), M_PI * 2 * i / kFrameCount);
//            CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
//        }
//    }
//
//    if (!CGImageDestinationFinalize(destination)) {
//        NSLog(@"failed to finalize image destination");
//    }
//    CFRelease(destination);
//
//    NSLog(@"url=%@", fileURL);
//}

//
- (void)renderVideo {
    [self.activityIndicator startAnimating];

    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/renderedVideo.mp4"];
    [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
    NSMutableArray *uiimageArray = [[NSMutableArray alloc] init];
    for(CustomImage *image in self.imageArray) {
        [uiimageArray addObject:[self rotate:image.image andOrientation:UIImageOrientationUp]];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [HJImagesToVideo saveVideoToPhotosWithImages:uiimageArray withFPS:(int)(1.0 / FRAME_LENGTH) animateTransitions:NO withCallbackBlock:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
                UIViewController *vc = [[UIViewController alloc] init];
                [vc.view setBackgroundColor:[UIColor clearColor]];
                [window setRootViewController:vc];
                [window setWindowLevel:UIWindowLevelAlert + 1];
                [window makeKeyAndVisible];

                if(success) {
                    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Video Saved" message:@"Your progress video has been successfully saved!" preferredStyle:UIAlertControllerStyleAlert];
                    [ac addAction:[UIAlertAction actionWithTitle:@"Cool!" style:UIAlertActionStyleCancel handler:nil]];
                    [vc presentViewController:ac animated:YES completion:nil];
                } else {
                    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was an error saving your progress video. Please make sure the app is open until the video is finished saving!" preferredStyle:UIAlertControllerStyleAlert];
                    [ac addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
                    [vc presentViewController:ac animated:YES completion:nil];
                }

                [self.downloadButton setEnabled:YES];
                [self.downloadImage setTintColor:BLUE];
                [self.downloadImage setImage:[[UIImage imageNamed:@"Download"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                [self.activityIndicator stopAnimating];
            });
        }];
    });
}
//
- (void)makeAnimatedGif:(NSArray<UIImage *> *)imgArray completion:(void (^)(BOOL success))completion {
    NSUInteger kFrameCount = imgArray.count;

    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };

    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime:@FRAME_LENGTH, // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                              }
                                      };

    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"animated.gif"];

    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);

    for(NSUInteger i = 0; i < kFrameCount; i++) {
        @autoreleasepool {
            UIImage *image = [imgArray objectAtIndex:i];
            image = [self rotate:image andOrientation:UIImageOrientationUp];
            //CGImageRef *imageRef = image.CGImage;
            
            
            CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }

    if(!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
        completion(NO);
    } else {
        NSData *data = [NSData dataWithContentsOfFile:[fileURL path]];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        } completionHandler:^(BOOL success, NSError *error) {
            completion(success);
        }];
        //UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:[fileURL path]], nil, nil, nil); 
    }
}

@end
