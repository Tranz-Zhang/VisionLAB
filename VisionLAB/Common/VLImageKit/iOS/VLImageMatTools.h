//
//  VLImageMatTools.h
//  VisionLAB
//
//  Created by chance on 2/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "gray_image_mat.hpp"

@interface VLImageMatTools : NSObject

//+ (VL)grayScaleDataWithImage:(UIImage *)image;
//+ (UIImage *)grayScaleImageWithData:(NSData *)grayScaleData size:(CGSize)imageSize;

@end

VLImageKit::GrayImageMat *CreateGrayImageMatWithUIImage(UIImage *image);
UIImage *UIImageWithGrayImageMat(VLImageKit::GrayImageMat *mat);

