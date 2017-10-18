//
//  C2BL1ViewController.m
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#include <iostream>

#import "C2BL1ViewController.h"
#import "VLDrawView.h"

using namespace cv;
using namespace std;

@interface C2BL1ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet VLDrawView *assistView;


@end

@implementation C2BL1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (IBAction)onTestHoughTransform:(id)sender {
    //inhouse_512.jpg
//    Mat sourceMat;
//    Mat grayMat;
//    Mat resultMat;
//    UIImage *img = [UIImage imageNamed:@"house_1024.jpg"];
//    UIImageToMat(img, sourceMat);
//    cvtColor(sourceMat, grayMat, CV_RGB2GRAY);
//    blur(grayMat, resultMat, cv::Size(3, 3));
//    Canny(resultMat, resultMat, self.thresholdSlider1.value, self.thresholdSlider2.value);
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    Mat src_mat;
    Mat gray_mat;
    Mat edge_mat;
    UIImage *sourceImage = [UIImage imageNamed:@"inhouse_512.jpg"];
    UIImageToMat(sourceImage, src_mat);
    
    // Canny Edge Calculation
    cvtColor(src_mat, gray_mat, CV_RGB2GRAY);
    Canny(gray_mat, edge_mat, 100, 250);
    
    // Hough Transform
    vector<Vec2f> lines;
    HoughLines(edge_mat, lines, 1, CV_PI / 180, 150);
    
    // end of performance measure
    self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
    
    // draw out lines
    NSMutableArray *drawingLines = [NSMutableArray arrayWithCapacity:lines.size()];
    for (size_t i = 0; i < lines.size(); i++) {
        float rho = lines[i][0];
        float theta = lines[i][1];
        double a = cos(theta);
        double b = sin(theta);
        double x0 = a * rho * self.assistView.bounds.size.width / src_mat.cols;
        double y0 = b * rho * self.assistView.bounds.size.height / src_mat.rows;
        CGPoint startPoint = CGPointMake(cvRound(x0 + 500 *(-b)),
                                         cvRound(y0 + 500 * a));
        CGPoint endPoint = CGPointMake(cvRound(x0 - 500 *(-b)),
                                       cvRound(y0 - 500 * a));
        VLLine *drawingLine = [VLLine lineWithStartPoint:startPoint
                                                endPoint:endPoint];
        drawingLine.color = [[UIColor greenColor] colorWithAlphaComponent:1];
        [drawingLines addObject:drawingLine];
    }
    
    self.resultView.image = sourceImage;// MatToUIImage(edge_mat);
    [self.assistView updateWithObjects:drawingLines];
}


- (void)testDraw {
    VLLine *line = [VLLine lineWithStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(arc4random() % 300, 100)];
    VLRectangle *rect = [VLRectangle rectangleWithRect:CGRectInset(self.assistView.bounds, 20, 50)];
    VLCircle *circle = [VLCircle circleWithCenter:CGPointMake(120, 200) radius:50];
    [self.assistView updateWithObjects:@[line, rect, circle]];
}


@end
