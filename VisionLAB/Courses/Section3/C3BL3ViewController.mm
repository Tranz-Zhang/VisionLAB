//
//  C3BL3ViewController.m
//  VisionLAB
//
//  Created by chance on 7/12/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/calib3d/calib3d.hpp>
#import <opencv2/imgproc/imgproc.hpp>
#import "stereo.hpp"
#import "C3BL3ViewController.h"

// Ref: https://docs.opencv.org/2.4/modules/contrib/doc/stereo.html


using namespace cv;

@interface C3BL3ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end


@implementation C3BL3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)onTestStereoBinaryBM:(id)sender {
    Mat leftImage;
    UIImageToMat([UIImage imageNamed:@"stereo_left.png"], leftImage);
    cvtColor(leftImage, leftImage, CV_RGB2GRAY);
    leftImage.convertTo(leftImage, CV_8UC1);
    
    Mat rightImage;
    UIImageToMat([UIImage imageNamed:@"stereo_right.png"], rightImage);
    cvtColor(rightImage, rightImage, CV_RGB2GRAY);
    rightImage.convertTo(rightImage, CV_8UC1);
    
    // params
    Mat imageDisparity8U2 = Mat(leftImage.rows, leftImage.cols, CV_8UC1);
    int kernel_size = 9;
    int number_of_disparities = 128;
    int aggregation_window = 9;
    float scale = 1.01593;
    int binary_descriptor_type = cv::stereo::CV_MODIFIED_CENSUS_TRANSFORM;

    Ptr<cv::stereo::StereoBinaryBM> sbm = cv::stereo::StereoBinaryBM::create(number_of_disparities, kernel_size);
    // we set the corresponding parameters
    sbm->setPreFilterCap(31);
    sbm->setMinDisparity(0);
    sbm->setTextureThreshold(10);
    sbm->setUniquenessRatio(0);
    sbm->setSpeckleWindowSize(400); // speckle size
    sbm->setSpeckleRange(200);
    sbm->setDisp12MaxDiff(0);
    sbm->setScalleFactor((int)scale); // the scaling factor
    sbm->setBinaryKernelType(binary_descriptor_type); // binary descriptor kernel
    sbm->setAgregationWindowSize(aggregation_window);
    // the user can choose between the average speckle removal algorithm or
    // the classical version that was implemented in OpenCV
    sbm->setSpekleRemovalTechnique(cv::stereo::CV_SPECKLE_REMOVAL_AVG_ALGORITHM);
    sbm->setUsePrefilter(false);
    //-- calculate the disparity image
    NSLog(@"Computing...");
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    sbm->compute(leftImage, rightImage, imageDisparity8U2);
    
    self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
    self.resultView.image = MatToUIImage(imageDisparity8U2);
    self.resultView.contentMode = UIViewContentModeScaleAspectFit;
    sbm.release();
}


- (IBAction)onTestStereoBinarySGBM:(id)sender {
    Mat leftImage;
    UIImageToMat([UIImage imageNamed:@"stereo_left.png"], leftImage);
    cvtColor(leftImage, leftImage, CV_RGB2GRAY);
    leftImage.convertTo(leftImage, CV_8UC1);
    
    Mat rightImage;
    UIImageToMat([UIImage imageNamed:@"stereo_right.png"], rightImage);
    cvtColor(rightImage, rightImage, CV_RGB2GRAY);
    rightImage.convertTo(rightImage, CV_8UC1);
    
    // params
    Mat imageDisparity16S2 = Mat(leftImage.rows, leftImage.cols, CV_16S);
    int kernel_size = 9;
    int number_of_disparities = 128;
    int P1 = 100;
    int P2 = 1000;
    int binary_descriptor_type = cv::stereo::CV_MODIFIED_CENSUS_TRANSFORM;
    
    // we set the corresponding parameters
    Ptr<cv::stereo::StereoBinarySGBM> sgbm = cv::stereo::StereoBinarySGBM::create(0, number_of_disparities, kernel_size);
    // setting the penalties for sgbm
    sgbm->setP1(P1);
    sgbm->setP2(P2);
    sgbm->setMinDisparity(0);
    sgbm->setUniquenessRatio(5);
    sgbm->setSpeckleWindowSize(400);
    sgbm->setSpeckleRange(0);
    sgbm->setDisp12MaxDiff(1);
    sgbm->setBinaryKernelType(binary_descriptor_type);
    sgbm->setSpekleRemovalTechnique(cv::stereo::CV_SPECKLE_REMOVAL_AVG_ALGORITHM);
    sgbm->setSubPixelInterpolationMethod(cv::stereo::CV_SIMETRICV_INTERPOLATION);
    NSLog(@"Computing...");
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    sgbm->compute(leftImage, rightImage, imageDisparity16S2);
    /*Alternative for scalling
     imgDisparity16S2.convertTo(imgDisparity8U2, CV_8UC1, scale);
     */
    double minVal; double maxVal;
    minMaxLoc(imageDisparity16S2, &minVal, &maxVal);
    imageDisparity16S2.convertTo(imageDisparity16S2, CV_8UC1, 255 / (maxVal - minVal));
    
    self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
    self.resultView.image = MatToUIImage(imageDisparity16S2);
    self.resultView.contentMode = UIViewContentModeScaleAspectFit;
    sgbm.release();
}

@end






