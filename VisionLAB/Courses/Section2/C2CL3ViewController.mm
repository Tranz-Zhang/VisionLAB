//
//  C2CL3ViewController.m
//  VisionLAB
//
//  Created by chance on 21/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#include <iostream>

#import "C2CL3ViewController.h"
#import "VLImageMatTools.h"
#import "LabUtils.h"

using namespace VLImageKit;
using namespace cv;
using namespace std;

@interface C2CL3ViewController () {
    
}

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *aliasingSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *antialiasingSegment;

@end

@implementation C2CL3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultView.image = [UIImage imageNamed:@"inhouse_512.jpg"];
}

- (IBAction)onTestAliasingImageScale:(UIButton *)btn {
    int segmentIndex = (int)self.aliasingSegment.selectedSegmentIndex;
    self.infoLabel.text = segmentIndex != 0 ? @"Scale Image Normally" : @"";
    UIImage *sourceImage = [UIImage imageNamed:@"inhouse_512.jpg"];
    if (segmentIndex == 0) {
        self.resultView.image = [LabUtils grayScaleImage:sourceImage];
        return;
    }
    
    int scaleFactor = pow(2, segmentIndex);
    VLSize size = VLSizeMake(sourceImage.size.width / scaleFactor,
                                   sourceImage.size.height / scaleFactor);
    GrayImageMat *sourceMat = CreateGrayImageMatWithUIImage(sourceImage);
    GrayImageMat *resultMat = new GrayImageMat(size);
    for (int row = 0; row < size.height; row++) {
        for (int col = 0; col < size.width; col++) {
            uint8_t value = sourceMat->getValue(col * scaleFactor, row * scaleFactor);
            resultMat->setValue(value, col, row);
        }
    }
    
    self.resultView.image = UIImageWithGrayImageMat(resultMat);
    delete resultMat;
    delete sourceMat;
}


- (IBAction)onTestAntialiasingImageScale:(UIButton *)btn {
    int segmentIndex = (int)self.antialiasingSegment.selectedSegmentIndex;
    self.infoLabel.text = segmentIndex != 0 ? @"Scale Image after removing high frequencies" : @"";
    UIImage *sourceImage = [UIImage imageNamed:@"inhouse_512.jpg"];
    if (segmentIndex == 0) {
        self.resultView.image = [LabUtils grayScaleImage:sourceImage];
        return;
    }
    
    // apply gaussian filter to remove high frequencies
    Mat source_mat;
    UIImageToMat(sourceImage, source_mat);
    float guassianSize = pow(3, segmentIndex);
    GaussianBlur(source_mat, source_mat, cv::Size(guassianSize, guassianSize), 0);
    sourceImage = MatToUIImage(source_mat);
    
    int scaleFactor = pow(2, segmentIndex);
    VLSize size = VLSizeMake(sourceImage.size.width / scaleFactor,
                             sourceImage.size.height / scaleFactor);
    GrayImageMat *sourceMat = CreateGrayImageMatWithUIImage(sourceImage);
    GrayImageMat *resultMat = new GrayImageMat(size);
    for (int row = 0; row < size.height; row++) {
        for (int col = 0; col < size.width; col++) {
            uint8_t value = sourceMat->getValue(col * scaleFactor, row * scaleFactor);
            resultMat->setValue(value, col, row);
        }
    }
    
    self.resultView.image = UIImageWithGrayImageMat(resultMat);
    delete resultMat;
    delete sourceMat;
}


- (IBAction)onChangeResultViewContentMode:(UISwitch *)sender {
    self.resultView.contentMode = sender.on ? UIViewContentModeCenter : UIViewContentModeScaleToFill;
}


@end





