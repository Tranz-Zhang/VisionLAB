//
//  C2BL2ViewController.m
//  VisionLAB
//
//  Created by chance on 13/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//


#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#include <iostream>

#import "C2BL2ViewController.h"
#import "VLDrawView.h"

using namespace cv;
using namespace std;

@interface C2BL2ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet VLDrawView *markView;

@end

@implementation C2BL2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultView.image = [UIImage imageNamed:@"simple_shapes_512.png"];
}


#pragma mark - Hough Transform using OpenCV

- (IBAction)onTestHoughTransformUsingOpenCV:(id)sender {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    Mat source_image;
    UIImageToMat([UIImage imageNamed:@"simple_shapes_512.png"], source_image);
    cvtColor(source_image, source_image, CV_RGB2GRAY);
    
    // reduce the noise so we avoid false circle detection
//    GaussianBlur(source_image, source_image, cv::Size(3, 3), 0, 0);
    
    // Hough Transform
    Mat result_image;
    vector<Vec3f> circles;
    HoughCircles(source_image, circles, CV_HOUGH_GRADIENT, 1, 1);
    
    // end of performance measure
    self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
    
    // draw out lines
    double scale = self.markView.bounds.size.width / source_image.cols;
    NSMutableArray *drawingCircles = [NSMutableArray arrayWithCapacity:circles.size()];
    for (size_t i = 0; i < circles.size(); i++) {
        float centerX = circles[i][0];
        float centerY = circles[i][1];
        float radius = circles[i][2];
        VLCircle *circle = [VLCircle circleWithCenter:CGPointMake(centerX * scale, centerY * scale)
                                               radius:radius * scale];
        circle.color = [UIColor greenColor];
        [drawingCircles addObject:circle];
    }
    
    self.resultView.image = [UIImage imageNamed:@"simple_shapes_512.png"];// MatToUIImage(edge_mat);
    [self.markView updateWithObjects:drawingCircles];
}


@end


