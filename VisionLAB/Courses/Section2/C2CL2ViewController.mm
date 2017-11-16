//
//  C2CL2ViewController.m
//  VisionLAB
//
//  Created by chance on 16/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#include <iostream>

#import "C2CL2ViewController.h"

using namespace cv;
using namespace std;

@interface C2CL2ViewController () {
    Mat _complex_dft_img;
    Mat _modified_complex_dft_img;
}

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end


@implementation C2CL2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultView.image = [UIImage imageNamed:@"inhouse_512.jpg"];
    
    Mat source_img;
    UIImageToMat(self.resultView.image, source_img);
    cvtColor(source_img, source_img, CV_RGB2GRAY);
    source_img.convertTo(source_img, CV_32F);
    
    // FFT
    dft(source_img, _complex_dft_img, DFT_COMPLEX_OUTPUT);
    _modified_complex_dft_img = _complex_dft_img;
    cout << "Discrete Fourier Transform Done!" << endl;
}


- (IBAction)onChangeFrequencyMask:(UIButton *)btn {
    NSString *imageName = [NSString stringWithFormat:@"frequency_mask%d.png", (int)btn.tag];
    Mat mask;
    UIImageToMat([UIImage imageNamed:imageName], mask);
    cvtColor(mask, mask, CV_RGB2GRAY);
    mask.convertTo(mask, CV_32F);
    normalize(mask, mask, 0, 1, CV_MINMAX);
    
    Mat planes[2];
    split(_complex_dft_img, planes);
    [self switchMat:planes[0]];
    [self switchMat:planes[1]];
    multiply(planes[0], mask, planes[0]);
    multiply(planes[1], mask, planes[1]);
    [self switchMat:planes[0]];
    [self switchMat:planes[1]];
    Mat modified_result;
    merge(planes, 2, modified_result);
    _modified_complex_dft_img = modified_result;
    
    Mat result_img;
    magnitude(planes[0], planes[1], result_img);
    [self switchMat:result_img];
    
    result_img += Scalar::all(1);
    log(result_img, result_img);
    normalize(result_img, result_img, 0, 1, CV_MINMAX);
    result_img.convertTo(result_img, CV_8U, 255, 0);
    self.resultView.image = MatToUIImage(result_img);
}



- (IBAction)showFequencyDomainImage:(id)sender {
    _modified_complex_dft_img = _complex_dft_img;
    
    Mat planes[2];
    Mat result_img;
    split(_complex_dft_img, planes);
    magnitude(planes[0], planes[1], result_img);
    [self switchMat:result_img];
    
    result_img += Scalar::all(1);
    log(result_img, result_img);
    normalize(result_img, result_img, 0, 1, CV_MINMAX);
    result_img.convertTo(result_img, CV_8U, 1, 0);
    self.resultView.image = MatToUIImage(result_img);
}


/*
 0 | 1     3 | 2
 -----  >> -----
 2 | 3     1 | 0
 */
- (void)switchMat:(Mat &)mat {
    int centerX = mat.cols / 2;
    int centerY = mat.rows / 2;
    Mat q0(mat, cv::Rect(0, 0, centerX, centerY));            // top-left
    Mat q1(mat, cv::Rect(centerX, 0, centerX, centerY));      // top-right
    Mat q2(mat, cv::Rect(0, centerY, centerX, centerY));      // bottom-left
    Mat q3(mat, cv::Rect(centerX, centerY, centerX, centerY));// bottom-right
    Mat temp_img;
    q0.copyTo(temp_img);
    q3.copyTo(q0);
    temp_img.copyTo(q3);
    
    q1.copyTo(temp_img);
    q2.copyTo(q1);
    temp_img.copyTo(q2);
}


- (IBAction)onInverseFourierTransform:(id)sender {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    // IFFT
    std::cout << "Inverse transform...\n";
    Mat inverseTransform;
    dft(_modified_complex_dft_img, inverseTransform, DFT_SCALE|DFT_INVERSE|DFT_REAL_OUTPUT);
    
    self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
    
    // Back to 8-bits
    cv::Mat finalImage;
    inverseTransform.convertTo(finalImage, CV_8U);
    
    self.resultView.image = MatToUIImage(finalImage);
}


- (void)printFloatMat:(Mat &)mat {
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



- (void)testMat {
    Mat source_img;
    UIImageToMat([UIImage imageNamed:@"sunset_256.png"], source_img);
    cvtColor(source_img, source_img, CV_RGB2GRAY);
    source_img.convertTo(source_img, CV_32F);
    
    Mat result_img;
    Mat operator_mat = Mat::ones(source_img.size(), CV_32F);
    addWeighted(source_img, 1, operator_mat, 1, 128, result_img);
    [self printFloatMat:result_img];
//    multiply(operator_mat, operator_mat, operator_mat, 0.5);
//    multiply(source_img, operator_mat, result_img);
    
    
//    normalize(result_img, result_img, 0, 1, CV_RELATIVE);
    [self printFloatMat:result_img];
    result_img.convertTo(result_img, CV_8U, 1, 0);
    self.resultView.image = MatToUIImage(result_img);
    
}


@end




