//
//  C2CL1ViewController.m
//  VisionLAB
//
//  Created by chance on 15/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#include <iostream>

#import "C2CL1ViewController.h"

using namespace cv;
using namespace std;

@interface C2CL1ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end


@implementation C2CL1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultView.image = [UIImage imageNamed:@"inhouse_512.jpg"];
}

- (IBAction)onTestFourierTransform:(id)sender {
    Mat source_img; //inhouse_512.jpg simple_shapes_512.png
    UIImageToMat([UIImage imageNamed:@"inhouse_512.jpg"], source_img);
    cvtColor(source_img, source_img, CV_RGB2GRAY);
    
    self.resultView.image = MatToUIImage(source_img);;
    
    int optimal_width = getOptimalDFTSize(source_img.cols);
    int optimal_height = getOptimalDFTSize(source_img.rows);
    printf("optimal DFT size: (%d, %d) -> (%d, %d)\n", source_img.cols, source_img.rows, optimal_width, optimal_height);
    
    Mat padded;
    copyMakeBorder(source_img, padded, 0, optimal_height - source_img.rows, 0, optimal_width - source_img.cols, BORDER_CONSTANT, Scalar::all(0));
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    // create two planes for real value and imaginary value for image
    Mat planes[2] = {Mat_<float>(padded), Mat::zeros(padded.size(), CV_32FC1)};
    Mat complex_img;
    merge(planes, 2, complex_img); // complex_result 拥有两个通道
    
    // do discrete fourier transform
    dft(complex_img, complex_img);
    
    self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
    
    // computer the magnitude and convert ro logarithmic scale for easier view
    split(complex_img, planes);
    Mat magnitude_img;
    magnitude(planes[0], planes[1], magnitude_img);
    
    magnitude_img += Scalar::all(1);
    log(magnitude_img, magnitude_img);

    // 确保图像是偶数大小
    magnitude_img = magnitude_img(cv::Rect(0, 0, magnitude_img.cols & -2, magnitude_img.rows & -2));
    
    /*
     0 | 1     3 | 2
     -----  >> -----
     2 | 3     1 | 0
     */
    int centerX = magnitude_img.cols / 2;
    int centerY = magnitude_img.rows / 2;
    Mat q0(magnitude_img, cv::Rect(0, 0, centerX, centerY));            // top-left
    Mat q1(magnitude_img, cv::Rect(centerX, 0, centerX, centerY));      // top-right
    Mat q2(magnitude_img, cv::Rect(0, centerY, centerX, centerY));      // bottom-left
    Mat q3(magnitude_img, cv::Rect(centerX, centerY, centerX, centerY));// bottom-right
    Mat temp_img;
    q0.copyTo(temp_img);
    q3.copyTo(q0);
    temp_img.copyTo(q3);
    
    q1.copyTo(temp_img);
    q2.copyTo(q1);
    temp_img.copyTo(q2);
    
    normalize(magnitude_img, magnitude_img, 0, 1, CV_MINMAX);
//    [self pringFloatMat:magnitude_img];
    magnitude_img.convertTo(magnitude_img, CV_8U, 255, 0);
//    [self printMat:magnitude_img];
    self.resultView.image = MatToUIImage(magnitude_img);

}


- (void)printMat:(Mat &)mat {
    int nRows = mat.rows;
    int nCols = mat.cols * mat.channels();
    if (mat.isContinuous()) {
        nCols *= nRows;
        nRows = 1;
    }
    for(int i = 0; i < nRows; ++i)  {
        uchar* row_pixels = mat.ptr<uchar>(i);
        for (int j = 0; j < nCols; ++j)  {
            printf("%d ", (int)*(row_pixels + j));
        }
        printf("\n");
    }
}

- (void)pringFloatMat:(Mat &)mat {
    int nRows = mat.rows;
    int nCols = mat.cols * mat.channels();
    if (mat.isContinuous()) {
        nCols *= nRows;
        nRows = 1;
    }
    for(int i = 0; i < nRows; ++i)  {
        float* row_pixels = mat.ptr<float>(i);
        for (int j = 0; j < nCols; ++j)  {
            printf("%.1f ", (float)*(row_pixels + j));
        }
        printf("\n");
    }
}


@end

