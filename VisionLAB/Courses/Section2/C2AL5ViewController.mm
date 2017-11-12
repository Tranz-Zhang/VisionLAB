//
//  C2AL5ViewController.m
//  VisionLAB
//
//  Created by chance on 10/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "C2AL5ViewController.h"
#import "VLImageMatTools.h"

using namespace VLImageKit;
using namespace cv;


@interface GradientInfo : NSObject

@property (nonatomic, assign) float direction;
@property (nonatomic, assign) float magnitude;

@end

@implementation GradientInfo

@end


@interface C2AL5ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end


@implementation C2AL5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultView.image = [UIImage imageNamed:@"Lenna_512.png"];
}


#pragma mark - Laplacian Operator Using OpenCV
- (IBAction)onTestLaplacianOperator:(id)sender {
    Mat sourceImage;
    UIImageToMat([UIImage imageNamed:@"Lenna_512.png"], sourceImage);
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    cvtColor(sourceImage, sourceImage, CV_RGB2GRAY);
    GaussianBlur(sourceImage, sourceImage, cv::Size(3, 3), BORDER_DEFAULT);
    
    // apply laplacian operator
    Mat resultImage;
    Laplacian(sourceImage, resultImage, CV_16S, 3, 1, 0, BORDER_DEFAULT);
    convertScaleAbs(resultImage, resultImage);
    
    self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
    self.resultView.image = MatToUIImage(resultImage);
}


#pragma mark - Sobel Operator Using OpenCV
- (IBAction)onTestSobelOperator:(id)sender {
    Mat sourceImage;
    UIImageToMat([UIImage imageNamed:@"Lenna_512.png"], sourceImage);
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    cvtColor(sourceImage, sourceImage, CV_RGB2GRAY);
    GaussianBlur(sourceImage, sourceImage, cv::Size(3, 3), BORDER_DEFAULT);
    
    // apply sobel operator
    Mat grad_x, grad_y;
    Mat abs_grad_x, abs_grad_y;
    Mat resultImage;
    Sobel(sourceImage, grad_x, CV_16S, 1, 0); // 得出X轴方向的边界
    convertScaleAbs(grad_x, abs_grad_x);
    Sobel(sourceImage, grad_y, CV_16S, 0, 1); // 得出Y轴方向的边界
    convertScaleAbs(grad_y, abs_grad_y);
    
    addWeighted(abs_grad_x, 0.5, abs_grad_y, 0.5, 0, resultImage); // 中和两个方向的边界
    
    self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", (CFAbsoluteTimeGetCurrent() - startTime) * 1000];
    self.resultView.image = MatToUIImage(resultImage);
}



#pragma mark - Gradient

- (IBAction)onTestGradientAndMagnitude:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // start gaussian correlation
        UIImage *sourceImage = [UIImage imageNamed:@"Lenna_512.png"];
        
        GrayImageMat *sourceMat = CreateGrayImageMatWithUIImage(sourceImage);
        GrayImageMat *resultMat = CreateGrayImageMatWithUIImage(self.resultView.image ?: sourceImage);
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        VLSize size = sourceMat->size();
        for (int row = 0; row < size.height; row++) {
            for (int col = 0; col < size.width; col++) {
                GradientInfo *info = [self sobelValueAtLocation:VLPointMake(col, row)
                                                        atImage:sourceMat];
//                resultMat->setValue(((info.direction + M_PI) / (2 * M_PI)) * 255, col, row);
                resultMat->setValue(info.magnitude, col, row);
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
        CFTimeInterval durationMS = (CFAbsoluteTimeGetCurrent() - startTime) * 1000;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultView.image = resultImage;
            self.infoLabel.text = [NSString stringWithFormat:@"%.2f ms", durationMS];
        });
        
        delete sourceMat;
        delete resultMat;
        sourceMat = nullptr;
        resultMat = nullptr;
    });
}

// 普通高斯模糊算法
- (GradientInfo *)sobelValueAtLocation:(VLPoint)location
                            atImage:(GrayImageMat *)imageMat {
    VLSize blockSize = VLSizeMake(3, 3);
    static int sobelMatrixX[3][3] = {-1, 0, 1,
                                     -2, 0, 2,
                                     -1, 0, 1};
    static int sobelMatrixY[3][3] = {-1, -2, -1,
                                     0, 0, 0,
                                     1, 2, 1};
    
    float gradientX = 0, gradientY = 0;
    for (int col = 0; col < blockSize.width; col++) {
        for (int row = 0; row < blockSize.height; row++) {
            int sourceLocationX = col + location.x - (blockSize.width - 1) / 2;
            int sourceLocationY = row + location.y - (blockSize.height - 1) / 2;
            if (sourceLocationX > 0 && sourceLocationX < imageMat->size().width &&
                sourceLocationY > 0 && sourceLocationY < imageMat->size().height) {
                gradientX += sobelMatrixX[col][row] * imageMat->getValue(sourceLocationX, sourceLocationY);
                gradientY += sobelMatrixY[col][row] * imageMat->getValue(sourceLocationX, sourceLocationY);
            }
        }
    }
    
    GradientInfo *info = [GradientInfo new];
    info.magnitude = sqrt(pow(gradientX, 2) + pow(gradientY, 2));
    info.direction = atan2(gradientY, gradientX);
    return info;
}

@end




