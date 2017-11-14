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
        printf("(%.2f, %.2f, %.2f)\n", centerX, centerY, radius);
        VLCircle *circle = [VLCircle circleWithCenter:CGPointMake(centerX * scale, centerY * scale)
                                               radius:radius * scale];
        circle.color = [UIColor greenColor];
        [drawingCircles addObject:circle];
    }
    
    self.resultView.image = [UIImage imageNamed:@"simple_shapes_512.png"];// MatToUIImage(edge_mat);
    [self.markView updateWithObjects:drawingCircles];
}



#pragma mark - Hough Transform Circles
#define ENABLE_GRADIENT_CALCULATION 0

- (IBAction)onTestHoughTransfromCircles:(id)sender {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    Mat source_image;
    Mat result_image;
    UIImageToMat([UIImage imageNamed:@"simple_shapes_512.png"], source_image);
    cvtColor(source_image, result_image, CV_RGB2GRAY);
    
    // reduce the noise so we avoid false circle detection
    // GaussianBlur(source_image, source_image, cv::Size(3, 3), 0, 0);
    
    Mat grad_x, grad_y;
    spatialGradient(result_image, grad_x, grad_y);
    
    Mat abs_grad_x, abs_grad_y;
    convertScaleAbs(grad_x, abs_grad_x);
    convertScaleAbs(grad_y, abs_grad_y);
    addWeighted(abs_grad_x, 0.5, abs_grad_y, 0.5, 0, result_image);
    
    float maxRadius = 80;// MIN(source_image.rows, source_image.cols) / 2;
    const int tableSize = source_image.rows * source_image.cols * maxRadius;
    int *houghTable = new int[tableSize](); // 3 dimension
    
    int nRows = result_image.rows;
    int nCols = result_image.cols * result_image.channels();
    if (result_image.isContinuous()) {
        nCols *= nRows;
        nRows = 1;
    }
    int calculationPixels = 0;
    for(int i = 0; i < nRows; ++i)  {
        uchar* row_pixels = result_image.ptr<uchar>(i);
        for (int j = 0; j < nCols; ++j)  {
            if (row_pixels[j] <= 10) {
                continue;
            }
            calculationPixels++;
            int x = j, y = i;
            if (result_image.isContinuous()) {
                x = j % result_image.cols;
                y = j / result_image.cols;
            }
            [self fillHoughTable:houghTable
                           width:source_image.cols
                          height:source_image.rows
              withGradientTableX:abs_grad_x
                  gradientTableY:abs_grad_y
                      atLocation:CGPointMake(x, y)
                       maxRadius:maxRadius];
        }
    }
    NSLog(@"Finish Hough Table Creation, pixel count: %d (%.2f%%)", calculationPixels, (float)calculationPixels / (source_image.rows * source_image.cols) * 100);
    
    // get circles
    double scale = self.markView.bounds.size.width / source_image.cols;
    NSMutableArray *drawingCircles = [NSMutableArray array];
    
    for (int a = 0; a < source_image.cols; a++) {
        for (int b = 0; b < source_image.rows; b++) {
            for (int r = 0; r < maxRadius; r++) {
                int vote = *(houghTable + r * source_image.cols * source_image.rows + b * source_image.cols + a);
                if (vote > (ENABLE_GRADIENT_CALCULATION ? 20 : 350)) {
                    printf("(%d, %d, %d) - %d\n", a, b, r, vote);
                    float centerX = a;
                    float centerY = b;
                    float radius = r;
                    VLCircle *circle = [VLCircle circleWithCenter:CGPointMake(centerX * scale, centerY * scale)
                                                           radius:radius * scale];
                    circle.color = [UIColor greenColor];
                   [drawingCircles addObject:circle];
                }
            }
        }
    }
    
    self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
    self.resultView.image = MatToUIImage(result_image);
    [self.markView updateWithObjects:drawingCircles];
    
    delete [] houghTable;
}


- (void)fillHoughTable:(int *)houghTable
                 width:(int)width
                height:(int)height
    withGradientTableX:(Mat &)gradientTableX
        gradientTableY:(Mat &)gradientTableY
            atLocation:(CGPoint)location
             maxRadius:(float)maxRadius {
#if ENABLE_GRADIENT_CALCULATION
    float gradx = gradientTableX.at<uchar>(cv::Point(location.x, location.y));
    float grady = gradientTableY.at<uchar>(cv::Point(location.x, location.y));
    float theta = atan2(gradx, grady);
    for (int r = 30; r < maxRadius; r++) {
        for (int i = 0; i < 4; i++) {
            int a = location.x - cos(theta + i * M_PI_2) * r;
            int b = location.y - sin(theta + i * M_PI_2) * r;
            if (a < width && b < height) {
                *(houghTable + r * width * height + b * width + a)+=1;
            }
        }
    }
#else
    for (int r = 30; r < maxRadius; r++) {
        for (int theta = 0; theta < 360; theta++) {
            int a = location.x - cos(theta * M_PI / 180) * r;
            int b = location.y - sin(theta * M_PI / 180) * r;
            if (a < width && b < height) {
                *(houghTable + r * width * height + b * width + a)+=1;
            }
        }
    }
#endif
}



@end



