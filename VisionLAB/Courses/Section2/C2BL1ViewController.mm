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
@property (weak, nonatomic) IBOutlet VLDrawView *markView;


@end

@implementation C2BL1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}


#pragma mark - Hough Transform using OpenCV

- (IBAction)onTestHoughTransformUsingOpenCV:(id)sender {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    Mat src_mat;
    Mat gray_mat;
    Mat edge_mat;
    UIImage *sourceImage = [UIImage imageNamed:@"hough_line_test.png"];
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
        NSLog(@"get line theta: %.2f rho: %.2f", theta, rho);
        double a = cos(theta);
        double b = sin(theta);
        double x0 = a * rho * self.markView.bounds.size.width / src_mat.cols;
        double y0 = b * rho * self.markView.bounds.size.height / src_mat.rows;
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
    [self.markView updateWithObjects:drawingLines];
}


#pragma mark - Hough Transform
#define kThetaCount 180

- (IBAction)onTestHoughTransform:(id)sender {
    Mat source_image;
    Mat result_image;
    UIImageToMat([UIImage imageNamed:@"hough_line_test.png"], source_image);
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    // Canny Edge Calculation
    cvtColor(source_image, source_image, CV_RGB2GRAY);
    Canny(source_image, result_image, 50, 250);
    
    /* create hough table
      ^
      |
    d |
      |
      -------->
        theta
     */
    const int maxDistance = sqrt(pow(result_image.cols, 2) + pow(result_image.rows, 2));
    const int tableSize = kThetaCount * maxDistance * 2;
    int *houghTable = new int[tableSize]();
    
    // scan image and get lines
    int linePixelCount = 0;
    int nRows = result_image.rows;
    int nCols = result_image.cols * result_image.channels();
    if (result_image.isContinuous()) {
        nCols *= nRows;
        nRows = 1;
    }
    for(int i = 0; i < nRows; ++i)  {
        uchar* row_pixels = result_image.ptr<uchar>(i);
        for (int j = 0; j < nCols; ++j)  {
            if (row_pixels[j] <= 0) {
                continue;
            }
            int x = j, y = i;
            if (result_image.isContinuous()) {
                x = j % result_image.cols;
                y = j / result_image.cols;
            }
            linePixelCount++;
            [self fillHoughTable:houghTable withX:x Y:y maxDistance:maxDistance];
        }
    }
    
    self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
    NSLog(@"Line Pixel Count: %d (%.2f%%)", linePixelCount, linePixelCount / (512.0f * 512) * 100);
    
    NSMutableArray *lines = [NSMutableArray array];
    double maxVote = 0;
    for (int i = 0; i < tableSize; i++) {
        int vote = *(houghTable + i);
        if (vote > 150) {
            float theta = M_PI * (i % kThetaCount) / kThetaCount;
            float rho = (i / kThetaCount - maxDistance);
            NSLog(@"get line theta: %.2f rho: %.2f", theta, rho);
            double a = cos(theta);
            double b = sin(theta);
            double x0 = a * rho * self.markView.bounds.size.width / source_image.cols;
            double y0 = b * rho * self.markView.bounds.size.height / source_image.rows;
            CGPoint startPoint = CGPointMake(cvRound(x0 + 500 *(-b)),
                                             cvRound(y0 + 500 * a));
            CGPoint endPoint = CGPointMake(cvRound(x0 - 500 *(-b)),
                                           cvRound(y0 - 500 * a));
            VLLine *drawingLine = [VLLine lineWithStartPoint:startPoint
                                                    endPoint:endPoint];
            [lines addObject:drawingLine];
        }
        if (maxVote < vote) {
            maxVote = vote;
        }
    }
    NSLog(@"Line Count: %d", (int)lines.count);
    [self.markView updateWithObjects:lines];
    
    // show hough table
    //Mat(int rows, int cols, int type, void* data, size_t step=AUTO_STEP);
    Byte *houghTableData = new Byte[tableSize]();
    for (int i = 0; i < tableSize; i++) {
        Byte value = *(houghTable + i) / maxVote * 255.0f;
        if (value < 128) {
            value = value * 10;
        }
        *(houghTableData + i) = value;
    }
    Mat *houghTableImage = new Mat((int)maxDistance * 2, (int)kThetaCount, CV_8U, houghTableData);
    
//    self.resultView.image = [UIImage imageNamed:@"hough_line_test.png"];
    self.resultView.image = MatToUIImage(*houghTableImage);
    delete [] houghTable;
}

- (void)fillHoughTable:(int *)houghTable withX:(int)x Y:(int)y maxDistance:(int)maxDistance {
    for (int i = 0; i < kThetaCount; i++) {
        double theta = M_PI * i / kThetaCount;
        int d = cos(theta) * x + sin(theta) * y + maxDistance;
        *(houghTable + (d * kThetaCount + i)) += 1;
//        printf("hough table (%d, %d) = %d\n", x, y, *(houghTable + (d * 180 + i)));
    }
}

//- (void)testDraw {
//    VLLine *line = [VLLine lineWithStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(arc4random() % 300, 100)];
//    VLRectangle *rect = [VLRectangle rectangleWithRect:CGRectInset(self.markView.bounds, 20, 50)];
//    VLCircle *circle = [VLCircle circleWithCenter:CGPointMake(120, 200) radius:50];
//    [self.markView updateWithObjects:@[line, rect, circle]];
//}


@end



