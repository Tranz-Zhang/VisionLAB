//
//  C2AL6ViewController.m
//  VisionLAB
//
//  Created by chance on 12/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//


#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "C2AL6ViewController.h"
#import "VLImageMatTools.h"

using namespace VLImageKit;
using namespace cv;

@interface C2AL6ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation C2AL6ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultView.image = [UIImage imageNamed:@"inhouse_512.jpg"];
}


#pragma mark - Canny Edge
- (IBAction)onTestCannyEdgeOperator:(id)sender {
    Mat sourceImage;
    Mat resultImage;
    UIImageToMat([UIImage imageNamed:@"inhouse_512.jpg"], sourceImage);
    cvtColor(sourceImage, sourceImage, CV_RGB2GRAY);
    
    Canny(sourceImage, resultImage, 50, 255);
    
    self.resultView.image = MatToUIImage(resultImage);
}


#pragma mark - Derivative of Gaussian

- (IBAction)onTestDerivativeOfGaussian:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // prepare mask image
        UIImage *maskImage = [UIImage imageNamed:@"guassian_mask6_small.png"];
        unsigned long totalMaskValue = 0; // for normalizing mask values
        GrayImageMat *mask = CreateGrayImageMatWithUIImage(maskImage);
        for (int row = 0; row < mask->size().width; row++) {
            for (int col = 0; col < mask->size().height; col++) {
                totalMaskValue += abs(mask->getValue(col, row) - 128);
            }
        }
        NSLog(@"total mask value: %lu", totalMaskValue);
        
        // start gaussian correlation
        UIImage *sourceImage = [UIImage imageNamed:@"inhouse_512.jpg"];
        
        GrayImageMat *sourceMat = CreateGrayImageMatWithUIImage(sourceImage);
        GrayImageMat *resultMat = CreateGrayImageMatWithUIImage(self.resultView.image);
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        VLSize size = sourceMat->size();
        for (int row = 0; row < size.height; row++) {
            for (int col = 0; col < size.width; col++) {
                Byte avarage = [self valueAtLocation:VLPointMake(col, row)
                                             atImage:sourceMat
                                           usingMask:mask
                                    normalizingParam:totalMaskValue];
                resultMat->setValue(avarage, col, row);
            }
            
            if (row != 0 && row % 10 == 0) {
                UIImage *tempImage = UIImageWithGrayImageMat(resultMat);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultView.image = tempImage;
                });
            }
        }
        
        NSLog(@"Done");
        UIImage *resultImage = UIImageWithGrayImageMat(resultMat);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultView.image = resultImage;
            self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
        });
        
        delete sourceMat;
        delete resultMat;
        sourceMat = nullptr;
        resultMat = nullptr;
    });
}


// 普通高斯模糊算法
- (Byte)valueAtLocation:(VLPoint)location
                atImage:(GrayImageMat *)imageMat
              usingMask:(GrayImageMat *)mask
       normalizingParam:(unsigned long)normalizingParam {
    VLSize blockSize = mask->size();
    double totalValue = 0;
    for (int col = 0; col < blockSize.width; col++) {
        for (int row = 0; row < blockSize.height; row++) {
            int sourceLocationX = col + location.x - (blockSize.width - 1) / 2;
            int sourceLocationY = row + location.y - (blockSize.height - 1) / 2;
            if (sourceLocationX < 0 || sourceLocationX >= imageMat->size().width ||
                sourceLocationY < 0 || sourceLocationY >= imageMat->size().height) {
                totalValue += 0;
                
            } else {
                int maskValue = mask->getValue(col, row);
                if (normalizingParam) {
                    float weight = ((maskValue - 128) / (float)normalizingParam);
                    totalValue += imageMat->getValue(sourceLocationX, sourceLocationY) * weight;
                    
                } else {
                    totalValue += imageMat->getValue(sourceLocationX, sourceLocationY) * (maskValue / 256.0);
                }
            }
        }
    }
    
    return abs(totalValue);
}



@end
