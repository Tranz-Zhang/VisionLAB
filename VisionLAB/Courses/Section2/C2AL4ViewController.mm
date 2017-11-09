//
//  C2AL4ViewController.m
//  VisionLAB
//
//  Created by chance on 9/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "C2AL4ViewController.h"
#import "VLImageMatTools.h"
#import "VLDrawView.h"

using namespace VLImageKit;
using namespace cv;

@interface C2AL4ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet VLDrawView *markView;

@end


@implementation C2AL4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultView.image = [UIImage imageNamed:@"inhouse_512.jpg"];
}


- (IBAction)onTestTemplateMatch:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // prepare mask image
        UIImage *maskImage = [UIImage imageNamed:@"template_inhouse_21.png"];
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
        
        VLPoint matchPoint = VLPointMake(0, 0);
        double maxValue = DBL_MIN;
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        VLSize size = sourceMat->size();
        for (int row = 0; row < size.height; row++) {
            for (int col = 0; col < size.width; col++) {
                double value = [self correlationValueAtLocation:VLPointMake(col, row)
                                                        atImage:sourceMat
                                                      usingMask:mask
                                               normalizingParam:totalMaskValue];
                if (value > maxValue) {
                    maxValue = value;
                    matchPoint = VLPointMake(col, row);
                }
                resultMat->setValue(MAX(MIN(value * 255, 255), 0), col, row);
            }
            
            if (row != 0 && row % 10 == 0) {
                UIImage *tempImage = UIImageWithGrayImageMat(resultMat);
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGSize imageSize = sourceImage.size;
                    CGSize canvasSize = self.markView.bounds.size;
                    CGPoint dotLocation = CGPointMake(canvasSize.width / imageSize.width * matchPoint.x,
                                                      canvasSize.height / imageSize.height * matchPoint.y);
                    VLDot *dot = [VLDot dotWithLocation:dotLocation];
                    dot.color = [UIColor greenColor];
                    dot.dotSize = 2;
                    [self.markView updateWithObjects:@[dot]];
                    self.resultView.image = tempImage;
                    self.infoLabel.text = [NSString stringWithFormat:@"MatchPoint: (%.0f, %.0f) -MAX:%.3f", matchPoint.x, matchPoint.y, maxValue];
                });
            }
        }
        
        NSLog(@"Done with matchPoint: (%.0f, %.0f) -MAX:%.3f", matchPoint.x, matchPoint.y, maxValue);
//        UIImage *resultImage = UIImageWithGrayImageMat(resultMat);
        dispatch_async(dispatch_get_main_queue(), ^{
            CGSize maskSize = maskImage.size;
            CGSize canvasSize = self.markView.bounds.size;
            CGSize imageSize = sourceImage.size;
            CGRect resultRect = CGRectMake((matchPoint.x - floor(maskSize.width / 2)) * canvasSize.width / imageSize.width,
                                           (matchPoint.y - floor(maskSize.height / 2)) * canvasSize.height / imageSize.height,
                                           maskSize.width * canvasSize.width / imageSize.width,
                                           maskSize.height * canvasSize.height / imageSize.height);
            VLRectangle *rect = [VLRectangle rectangleWithRect:resultRect];
            rect.color = [UIColor greenColor];
            [self.markView updateWithObjects:@[rect]];
            self.resultView.image = sourceImage;
            self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
        });
        
        delete sourceMat;
        delete resultMat;
        sourceMat = nullptr;
        resultMat = nullptr;
    });
}

// ref: https://isas.uka.de/Publikationen/SPIE01_BriechleHanebeck_CrossCorr.pdf
- (double)correlationValueAtLocation:(VLPoint)location
                           atImage:(GrayImageMat *)imageMat
                         usingMask:(GrayImageMat *)mask
                  normalizingParam:(unsigned long)normalizingParam {
    VLSize blockSize = mask->size();
    
    // calculate total value
    double totalPixelValue = 0;
    for (int col = 0; col < blockSize.width; col++) {
        for (int row = 0; row < blockSize.height; row++) {
            // 遍历的时候坐标反一下
            int sourceLocationX = col + location.x - (blockSize.width - 1) / 2;
            int sourceLocatinoY = row + location.y - (blockSize.height - 1) / 2;
            if (sourceLocationX < 0 || sourceLocationX >= imageMat->size().width ||
                sourceLocatinoY < 0 || sourceLocatinoY >= imageMat->size().height) {
                totalPixelValue += 0;
                
            } else {
                totalPixelValue += imageMat->getValue(sourceLocationX, sourceLocatinoY);
            }
        }
    }
    
    double averageMaskValue = normalizingParam / (blockSize.width * blockSize.height);
    double averagePixelValue = totalPixelValue / (blockSize.width * blockSize.height);
    
    double varianceValue = 0;
    double powMaskValue = 0;
    double powPixelValue = 0;
    for (int col = 0; col < blockSize.width; col++) {
        for (int row = 0; row < blockSize.height; row++) {
            // 遍历的时候坐标反一下
            Byte pixelValue;
            int sourceLocationX = col + location.x - (blockSize.width - 1) / 2;
            int sourceLocatinoY = row + location.y - (blockSize.height - 1) / 2;
            if (sourceLocationX < 0 || sourceLocationX >= imageMat->size().width ||
                sourceLocatinoY < 0 || sourceLocatinoY >= imageMat->size().height) {
                pixelValue = 128;
                
            } else {
                pixelValue = imageMat->getValue(sourceLocationX, sourceLocatinoY);
            }
            Byte maskValue = mask->getValue(col, row);
            varianceValue += (pixelValue - averagePixelValue) * (maskValue - averageMaskValue);
            powPixelValue += pow(pixelValue - averagePixelValue, 2);
            powMaskValue += pow(maskValue - averageMaskValue, 2);
        }
    }
    
    
    double nccValue = varianceValue / sqrt(powPixelValue * powMaskValue);
    return nccValue;
}


#pragma mark - Template Matching OpenCV
- (IBAction)onTemplateMatchingUsingOpenCV:(id)sender {
//    UIImage *image = [UIImage imageNamed:@"inhouse_512.jpg"];
    Mat sourceImage;
    UIImageToMat([UIImage imageNamed:@"inhouse_512.jpg"], sourceImage);
    Mat templateImage;
    UIImageToMat([UIImage imageNamed:@"template_inhouse_21.png"], templateImage);
    Mat resultImage;
    int result_cols = sourceImage.cols - templateImage.cols + 1;
    int result_rows = sourceImage.rows - templateImage.rows + 1;
    resultImage.create(result_rows, result_cols, CV_32FC1);
    
    // Matching and Normalize
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    matchTemplate(sourceImage, templateImage, resultImage, TM_CCORR_NORMED);
    normalize(resultImage, resultImage, 0, 1, NORM_MINMAX, -1, Mat());
    
    // Localizing the best match with minMaxLoc
    double minValue;
    double maxValue;
    cv::Point minLocation;
    cv::Point maxLocation;
    cv::Point matchLocation;
    minMaxLoc(resultImage, &minValue, &maxValue, &minLocation, &maxLocation, Mat());
    matchLocation = maxLocation;
    
    self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
    self.resultView.image = [UIImage imageNamed:@"inhouse_512.jpg"];
    
    CGSize maskSize = CGSizeMake(templateImage.cols, templateImage.rows);
    CGSize canvasSize = self.markView.bounds.size;
    CGSize imageSize = CGSizeMake(resultImage.cols, resultImage.rows);
    CGRect resultRect = CGRectMake((matchLocation.x - floor(maskSize.width / 2)) * canvasSize.width / imageSize.width,
                                   (matchLocation.y - floor(maskSize.height / 2)) * canvasSize.height / imageSize.height,
                                   maskSize.width * canvasSize.width / imageSize.width,
                                   maskSize.height * canvasSize.height / imageSize.height);
    VLRectangle *rect = [VLRectangle rectangleWithRect:resultRect];
    rect.color = [UIColor greenColor];
    [self.markView updateWithObjects:@[rect]];
}



@end



