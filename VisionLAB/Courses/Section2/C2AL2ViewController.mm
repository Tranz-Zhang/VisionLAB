//
//  C2AL2ViewController.m
//  VisionLAB
//
//  Created by chance on 2/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "C2AL2ViewController.h"
#import "LabUtils.h"
#import "VLImageMatTools.h"

using namespace VLImageKit;

@interface C2AL2ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) NSString *gaussianMaskName;

@end

@implementation C2AL2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gaussianMaskName = @"guassian_mask1.png";
    self.resultView.image = [UIImage imageNamed:@"inhouse_512.jpg"];
}


#pragma mark - Gaussian Blur

- (IBAction)onUsingGaussianMask1:(UIButton *)button {
    self.gaussianMaskName = [NSString stringWithFormat:@"guassian_mask%d.png", (int)button.tag];
}


- (IBAction)onTestGaussianBlurFilter:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // prepare mask image
        UIImage *maskImage = [UIImage imageNamed:self.gaussianMaskName];
        unsigned long totalMaskValue = 0; // for normalizing mask values
        GrayImageMat *mask = CreateGrayImageMatWithUIImage(maskImage);
        for (int row = 0; row < mask->size().width; row++) {
            for (int col = 0; col < mask->size().height; col++) {
                totalMaskValue += mask->getValue(col, row);
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
                Byte avarage = [self valueUsingEdgeWrapAtLocation:VLPointMake(col, row)
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
                    float weight = (maskValue / (float)normalizingParam);
                    totalValue += imageMat->getValue(sourceLocationX, sourceLocationY) * weight;
                    
                } else {
                    totalValue += imageMat->getValue(sourceLocationX, sourceLocationY) * (maskValue / 256.0);
                }
                
            }
        }
    }
    
    return totalValue;
}


// 带边界修正的高斯模糊算法
- (Byte)valueUsingEdgeWrapAtLocation:(VLPoint)location
                             atImage:(GrayImageMat *)imageMat
                           usingMask:(GrayImageMat *)mask
                    normalizingParam:(unsigned long)normalizingParam {
    VLSize blockSize = mask->size();
    VLSize imageSize = imageMat->size();
    double totalValue = 0;
    for (int col = 0; col < blockSize.width; col++) {
        for (int row = 0; row < blockSize.height; row++) {
            int sourceLocationX = abs(col + location.x - (blockSize.width - 1) / 2);
            if (sourceLocationX >= imageSize.width) {
                sourceLocationX = 2 * imageSize.width - sourceLocationX - 2;
            }
            int sourceLocationY = abs(row + location.y - (blockSize.height - 1) / 2);
            if (sourceLocationY >= imageSize.height) {
                sourceLocationY = 2 * imageSize.height - sourceLocationY - 2;
            }
            
            int maskValue = mask->getValue(col, row);
            if (normalizingParam) {
                float weight = (maskValue / (float)normalizingParam);
                totalValue += imageMat->getValue(sourceLocationX, sourceLocationY) * weight;
                
            } else {
                totalValue += imageMat->getValue(sourceLocationX, sourceLocationY) * (maskValue / 256.0);
            }
        }
    }
    
    return totalValue;
}


#pragma mark - Averate Blur

- (IBAction)onTestAnotherFilter:(UIButton *)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *sourceImage = [UIImage imageNamed:@"inhouse_512.jpg"];
        
        GrayImageMat *grayMat = CreateGrayImageMatWithUIImage(sourceImage);
        GrayImageMat *resultMat = new GrayImageMat(VLSizeMake(sourceImage.size.width, sourceImage.size.height));
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        VLSize size = grayMat->size();
        for (int row = 0; row < size.height; row++) {
            for (int col = 0; col < size.width; col++) {
                VLPoint location = VLPointMake(col, row);
                Byte avarage = [self averageValueAtLocation:location
                                                    atImage:grayMat];
                resultMat->setValue(avarage, col, row);
            }
        }
        
        // show image
        
        self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
        UIImage *resultImage = UIImageWithGrayImageMat(resultMat);
        //    self.resultView.contentMode = UIViewContentModeCenter;
        self.resultView.image = resultImage;
        
        delete grayMat;
        if (resultMat != grayMat) {
            delete resultMat;
        }
        grayMat = nullptr;
        resultMat = nullptr;
        
    });
}



- (IBAction)onTestAverageFilter:(UIButton *)sender {
    // row first
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *sourceImage = [UIImage imageNamed:@"inhouse_512.jpg"];
        GrayImageMat *grayMat = CreateGrayImageMatWithUIImage(sourceImage);
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        VLSize size = grayMat->size();
        for (int col = 0; col < size.width; col++) {
            for (int row = 0; row < size.height; row++) {
                VLPoint location = VLPointMake(col, row);
                Byte avarage = [self averageValueUsingEdgeWrapAtLocation:location
                                                                 atImage:grayMat];
                grayMat->setValue(avarage, col, row);
            }
            if (col != 0 && col % 10 == 0) {
                NSLog(@"Pause and show");
                UIImage *grayImage = UIImageWithGrayImageMat(grayMat);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultView.image = grayImage;
                });
//                sleep(1);
            }
        }
        
        // show image
        UIImage *grayImage = UIImageWithGrayImageMat(grayMat);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
            self.resultView.image = grayImage;
        });

        delete grayMat;
        grayMat = nullptr;
        
    });
    
}


#define kBlockSize 21
// 普通平均模糊算法
- (Byte)averageValueAtLocation:(VLPoint)location
                       atImage:(GrayImageMat *)imageMat {
    int startX = location.x - (kBlockSize - 1) / 2;
    int startY = location.y - (kBlockSize - 1) / 2;
    unsigned int totalValue = 0;
    for (int col = startX; col < startX + kBlockSize; col++) {
        for (int row = startY; row < startY + kBlockSize; row++) {
            if (col < 0 || col >= imageMat->size().width || row < 0 || row >= imageMat->size().height) {
                totalValue += 0;
                
            } else {
                totalValue += imageMat->getValue(col, row);
            }
        }
    }
    Byte avarage = totalValue / (kBlockSize * kBlockSize);
    return avarage;
}


// 带边界修正的平均模糊算法
- (Byte)averageValueUsingEdgeWrapAtLocation:(VLPoint)location
                                    atImage:(GrayImageMat *)imageMat {
    VLSize imageSize = imageMat->size();
    double totalValue = 0;
    for (int col = 0; col < kBlockSize; col++) {
        for (int row = 0; row < kBlockSize; row++) {
            int sourceLocationX = abs(col + location.x - (kBlockSize - 1) / 2);
            if (sourceLocationX >= imageSize.width) {
                sourceLocationX = 2 * imageSize.width - sourceLocationX - 2;
            }
            int sourceLocationY = abs(row + location.y - (kBlockSize - 1) / 2);
            if (sourceLocationY >= imageSize.height) {
                sourceLocationY = 2 * imageSize.height - sourceLocationY - 2;
            }
            
            totalValue += imageMat->getValue(sourceLocationX, sourceLocationY);
        }
    }
    
    Byte avarage = totalValue / (kBlockSize * kBlockSize);
    return avarage;
}


@end


