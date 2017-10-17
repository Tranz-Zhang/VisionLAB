//
//  C2AL1ViewController.m
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "C2AL1ViewController.h"

using namespace cv;

@interface C2AL1ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation C2AL1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)onLoadImage:(id)sender {
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
