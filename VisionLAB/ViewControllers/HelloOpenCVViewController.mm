//
//  HelloOpenCVViewController.m
//  VisionLAB
//
//  Created by chance on 24/9/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "HelloOpenCVViewController.h"

using namespace cv;

@interface HelloOpenCVViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *resultView;

@end

@implementation HelloOpenCVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Hello OpenCV";
    Mat kernal;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


- (IBAction)onButtonClicked:(UIButton *)sender {
    // UIImage to Mat (0.5ms)
    Mat matImage;
    UIImage *sourceImage = [UIImage imageNamed:@"avatar"];
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    UIImageToMat(sourceImage, matImage);
    printf("UIImage to Mat: %.4f ms\n", (CFAbsoluteTimeGetCurrent() - startTime) * 1000);
    
    // Mat to UIImage (0.1ms)
    startTime = CFAbsoluteTimeGetCurrent();
    UIImage *processedImage = MatToUIImage(matImage);
    printf("Mat to UIImage: %.4f ms\n", (CFAbsoluteTimeGetCurrent() - startTime) * 1000);
    
    self.resultView.image = processedImage;
}


@end
