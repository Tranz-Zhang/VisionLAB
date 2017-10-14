//
//  EdgeDetectionViewController.m
//  VisionLAB
//
//  Created by chance on 14/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "EdgeDetectionViewController.h"

using namespace cv;

@interface EdgeDetectionViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *thresholdLabel1;
@property (weak, nonatomic) IBOutlet UISlider *thresholdSlider1;
@property (weak, nonatomic) IBOutlet UILabel *thresholdLabel2;
@property (weak, nonatomic) IBOutlet UISlider *thresholdSlider2;

@end

@implementation EdgeDetectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Edge Detection";
    self.thresholdLabel1.text = [NSString stringWithFormat:@"Threshold01: %.2f", self.thresholdSlider1.value];
    self.thresholdLabel2.text = [NSString stringWithFormat:@"Threshold02: %.2f", self.thresholdSlider1.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onCannyEdgeProcess:(id)sender {
    Mat sourceMat;
    Mat grayMat;
    Mat resultMat;
    UIImage *img = [UIImage imageNamed:@"avatar"];
    UIImageToMat(img, sourceMat);
    cvtColor(sourceMat, grayMat, CV_RGB2GRAY);
    blur(grayMat, resultMat, cv::Size(3, 3));
    Canny(resultMat, resultMat, self.thresholdSlider1.value, self.thresholdSlider2.value);
    
    self.resultView.image = MatToUIImage(resultMat);
}


- (IBAction)onThresholdSlider1Changed:(UISlider *)slider {
    self.thresholdLabel1.text = [NSString stringWithFormat:@"Threshold01: %.2f", slider.value];
}

- (IBAction)onThresholdSlider2Changed:(UISlider *)slider {
    self.thresholdLabel2.text = [NSString stringWithFormat:@"Threshold02: %.2f", slider.value];
}


@end
