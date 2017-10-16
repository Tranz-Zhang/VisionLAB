//
//  HelloOpenCVViewController.m
//  VisionLAB
//
//  Created by chance on 24/9/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "HelloOpenCVViewController.h"

using namespace cv;

@interface HelloOpenCVViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *resultView;

@end

@implementation HelloOpenCVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Hello OpenCV";
    Mat kernal;
}

- (IBAction)onButtonClicked:(UIButton *)sender {
    // UIImage to Mat (0.5ms)
    Mat matImage;
    UIImage *sourceImage = [UIImage imageNamed:@"house_1024.jpg"];
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    UIImageToMat(sourceImage, matImage);
    printf("UIImage to Mat: %.4f ms\n", (CFAbsoluteTimeGetCurrent() - startTime) * 1000);
    
    // Mat to UIImage (0.1ms)
    startTime = CFAbsoluteTimeGetCurrent();
    UIImage *processedImage = MatToUIImage(matImage);
    printf("Mat to UIImage: %.4f ms\n", (CFAbsoluteTimeGetCurrent() - startTime) * 1000);
    
    self.resultView.image = processedImage;
}


@end
