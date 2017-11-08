//
//  C2AL3ViewController.m
//  VisionLAB
//
//  Created by chance on 7/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "C2AL3ViewController.h"
#import "VLImageMatTools.h"

using namespace VLImageKit;

@interface C2AL3ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation C2AL3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.resultView.image = [UIImage imageNamed:@"inhouse_512.jpg"];
}


#pragma mark - correlation vs convolution
- (IBAction)onTestCorrelation:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // prepare mask image
        UIImage *maskImage = [UIImage imageNamed:@"convolution_mask.png"];
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
                Byte avarage = [self correlationValueAtLocation:VLPointMake(col, row)
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



- (IBAction)onTestConvolution:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // prepare mask image
        UIImage *maskImage = [UIImage imageNamed:@"convolution_mask.png"];
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
                Byte avarage = [self convolutionValueAtLocation:VLPointMake(col, row)
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


#pragma mark - convolution property 2*W*N*N << W*W*N*N
- (IBAction)onNormalConvolution:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // prepare mask image
        UIImage *maskImage = [UIImage imageNamed:@"guassian_mask1.png"];
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
        GrayImageMat *resultMat = CreateGrayImageMatWithUIImage(self.resultView.image ?: sourceImage);
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        VLSize size = sourceMat->size();
        for (int row = 0; row < size.height; row++) {
            for (int col = 0; col < size.width; col++) {
                Byte avarage = [self convolutionValueAtLocation:VLPointMake(col, row)
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

/**
 对于一些对称的Mask，例如
          r
    1  *  1 2 3     1 2 1
 c  2            =  2 4 2  H
    1               1 2 1
 
 有 G = H * F = (C * R) * F = C * (R * F)
 */
- (IBAction)onFastConvolution:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // prepare mask image
        UIImage *columnMaskImage = [UIImage imageNamed:@"guassian_mask_col.png"];
        UIImage *rowMaskImage = [UIImage imageNamed:@"guassian_mask_row.png"];
        unsigned long totalMaskValue = 0; // for normalizing mask values
        GrayImageMat *mask_col = CreateGrayImageMatWithUIImage(columnMaskImage);
        GrayImageMat *mask_row = CreateGrayImageMatWithUIImage(rowMaskImage);
        for (int row = 0; row < mask_col->size().width; row++) {
            for (int col = 0; col < mask_col->size().height; col++) {
                totalMaskValue += mask_col->getValue(col, row);
            }
        }
        NSLog(@"total mask value: %lu", totalMaskValue);
        
        // start gaussian correlation
        UIImage *sourceImage = [UIImage imageNamed:@"inhouse_512.jpg"];
        
        GrayImageMat *sourceMat = CreateGrayImageMatWithUIImage(sourceImage);
        GrayImageMat *resultMat = CreateGrayImageMatWithUIImage(self.resultView.image ?: sourceImage);
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        VLSize size = sourceMat->size();
        // (R * F)
        for (int row = 0; row < size.height; row++) {
            for (int col = 0; col < size.width; col++) {
                Byte value = [self convolutionValueAtLocation:VLPointMake(col, row)
                                                      atImage:sourceMat
                                                    usingMask:mask_row
                                            normalizingParam:totalMaskValue];
                resultMat->setValue(value, col, row);
            }
            
            if (row != 0 && row % 20 == 0) {
                UIImage *tempImage = UIImageWithGrayImageMat(resultMat);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultView.image = tempImage;
                });
            }
        }
        
        // C * (R * F)
        for (int row = 0; row < size.height; row++) {
            for (int col = 0; col < size.width; col++) {
                Byte value = [self convolutionValueAtLocation:VLPointMake(col, row)
                                                      atImage:resultMat
                                                    usingMask:mask_col
                                             normalizingParam:totalMaskValue];
                resultMat->setValue(value, col, row);
            }
            
            if (row != 0 && row % 20 == 0) {
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


#pragma mark - Unsharp Mask
- (IBAction)onTestUnsharpMask:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // start gaussian correlation
        UIImage *sourceImage = [UIImage imageNamed:@"music_256.png"];
        GrayImageMat *sourceMat = CreateGrayImageMatWithUIImage(sourceImage);
        GrayImageMat *resultMat = CreateGrayImageMatWithUIImage(sourceImage);
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        VLSize size = sourceMat->size();
        for (int row = 0; row < size.height; row++) {
            for (int col = 0; col < size.width; col++) {
                Byte avarage = [self shapenValueAtLocation:VLPointMake(col, row)
                                                 fromImage:sourceMat];
                resultMat->setValue(avarage, col, row);
            }
            
            if (row != 0 && row % 10 == 0) {
                UIImage *tempImage = UIImageWithGrayImageMat(resultMat);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultView.image = tempImage;
                });
                usleep(200000); // 0.2s
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

- (Byte)shapenValueAtLocation:(VLPoint)location fromImage:(GrayImageMat *)imageMat {
    static float mask[3][3] = {-1, -1, -1,
                               -1, 10, -1,
                               -1, -1, -1};
    VLSize blockSize = VLSizeMake(3, 3);
    static double normalizingParam = 0;
    if (normalizingParam == 0) {
        float *ptr = mask[0];
        for (int i = 0; i < blockSize.width * blockSize.height; i++) {
            normalizingParam = normalizingParam + *(ptr + i);
        }
    }
    
    double totalValue = 0;
    for (int col = 0; col < blockSize.width; col++) {
        for (int row = 0; row < blockSize.height; row++) {
            // 遍历的时候坐标反一下
            int sourceLocationX = location.x + (blockSize.width - 1 - col) - (blockSize.width - 1) / 2;
            int sourceLocatinoY = location.y + (blockSize.height - 1 - row) - (blockSize.height - 1) / 2;
            if (sourceLocationX < 0 || sourceLocationX >= imageMat->size().width ||
                sourceLocatinoY < 0 || sourceLocatinoY >= imageMat->size().height) {
                totalValue += 0;
                
            } else {
                float maskValue = mask[col][row];
                float weight = (maskValue / normalizingParam);
                totalValue += imageMat->getValue(sourceLocationX, sourceLocatinoY) * weight;
            }
        }
    }
    return MAX(MIN(totalValue, 255), 0);
}


#pragma mark - Medain Filter
//sunset_noise_256.png
- (IBAction)onTestMedianFilter:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // start gaussian correlation
        UIImage *sourceImage = [UIImage imageNamed:@"sunset_noise_256.png"];
        GrayImageMat *sourceMat = CreateGrayImageMatWithUIImage(sourceImage);
        GrayImageMat *resultMat = CreateGrayImageMatWithUIImage(sourceImage);
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        VLSize size = sourceMat->size();
        for (int row = 0; row < size.height; row++) {
            for (int col = 0; col < size.width; col++) {
                Byte avarage = [self medianValueAtLocation:VLPointMake(col, row)
                                                 fromImage:sourceMat];
                resultMat->setValue(avarage, col, row);
            }
            
            if (row != 0 && row % 10 == 0) {
                UIImage *tempImage = UIImageWithGrayImageMat(resultMat);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultView.image = tempImage;
                });
                usleep(200000); // 0.2s
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


- (Byte)medianValueAtLocation:(VLPoint)location fromImage:(GrayImageMat *)imageMat {
    VLSize blockSize = VLSizeMake(3, 3);
    const int listSize = blockSize.width * blockSize.height;
    Byte valueList[listSize];
    int idx = 0;
    for (int col = 0; col < blockSize.width; col++) {
        for (int row = 0; row < blockSize.height; row++) {
            // 遍历的时候坐标反一下
            int sourceLocationX = location.x + (blockSize.width - 1 - col) - (blockSize.width - 1) / 2;
            int sourceLocatinoY = location.y + (blockSize.height - 1 - row) - (blockSize.height - 1) / 2;
            if (sourceLocationX < 0 || sourceLocationX >= imageMat->size().width ||
                sourceLocatinoY < 0 || sourceLocatinoY >= imageMat->size().height) {
                valueList[idx++] = 0;
                
            } else {
                valueList[idx++] = imageMat->getValue(sourceLocationX, sourceLocatinoY);
            }
        }
    }
    
    // sort list
    quick_sort(valueList, 0, listSize - 1);
    return valueList[(int)floor(listSize / 2)];
}


#pragma mark -

- (Byte)convolutionValueAtLocation:(VLPoint)location
                           atImage:(GrayImageMat *)imageMat
                         usingMask:(GrayImageMat *)mask
                  normalizingParam:(unsigned long)normalizingParam {
    VLSize blockSize = mask->size();
    double totalValue = 0;
    for (int col = 0; col < blockSize.width; col++) {
        for (int row = 0; row < blockSize.height; row++) {
            // 遍历的时候坐标反一下
            int sourceLocationX = location.x + (blockSize.width - 1 - col) - (blockSize.width - 1) / 2;
            int sourceLocatinoY = location.y + (blockSize.height - 1 - row) - (blockSize.height - 1) / 2;
            if (sourceLocationX < 0 || sourceLocationX >= imageMat->size().width ||
                sourceLocatinoY < 0 || sourceLocatinoY >= imageMat->size().height) {
                totalValue += 0;
                
            } else {
                int maskValue = mask->getValue(col, row);
                if (normalizingParam) {
                    float weight = (maskValue / (float)normalizingParam);
                    totalValue += imageMat->getValue(sourceLocationX, sourceLocatinoY) * weight;
                    
                } else {
                    totalValue += imageMat->getValue(sourceLocationX, sourceLocatinoY) * (maskValue / 256.0);
                }
                
            }
        }
    }
    
    return MAX(MIN(totalValue, 255), 0);
}


- (Byte)correlationValueAtLocation:(VLPoint)location
                           atImage:(GrayImageMat *)imageMat
                         usingMask:(GrayImageMat *)mask
                  normalizingParam:(unsigned long)normalizingParam {
    VLSize blockSize = mask->size();
    double totalValue = 0;
    for (int col = 0; col < blockSize.width; col++) {
        for (int row = 0; row < blockSize.height; row++) {
            int sourceLocationX = col + location.x - (blockSize.width - 1) / 2;
            int sourceLocatinoY = row + location.y - (blockSize.height - 1) / 2;
            if (sourceLocationX < 0 || sourceLocationX >= imageMat->size().width ||
                sourceLocatinoY < 0 || sourceLocatinoY >= imageMat->size().height) {
                totalValue += 0;
                
            } else {
                int maskValue = mask->getValue(col, row);
                if (normalizingParam) {
                    float weight = (maskValue / (float)normalizingParam);
                    totalValue += imageMat->getValue(sourceLocationX, sourceLocatinoY) * weight;
                    
                } else {
                    totalValue += imageMat->getValue(sourceLocationX, sourceLocatinoY) * (maskValue / 256.0);
                }
                
            }
        }
    }
    
    return MAX(MIN(totalValue, 255), 0);
}


#pragma mark - Quick Sort

void swap_value(Byte &p, Byte &q) {
    int tmp = p;
    p = q;
    q = tmp;
}


int quick_sort_partition(Byte *list, int low, int high) {
    int pivotValue = list[high];
    int i = low - 1;
    for (int j = low; j < high; j++) {
        if (list[j] <= pivotValue) {
            i++;
            if (i != j) {
                swap_value(list[i], list[j]);
            }
        }
    }
    swap_value(list[i + 1], list[high]);
    return i + 1;
}

void quick_sort(Byte *list, int low, int high) {
    if (low < high) {
        int idx = quick_sort_partition(list, low, high);
        quick_sort(list, low, idx - 1);
        quick_sort(list, idx + 1, high);
    }
}


@end




