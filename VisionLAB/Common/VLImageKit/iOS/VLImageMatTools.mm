//
//  VLImageMatTools.m
//  VisionLAB
//
//  Created by chance on 2/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLImageMatTools.h"

using namespace VLImageKit;

GrayImageMat *CreateGrayImageMatWithUIImage(UIImage *image) {
    
    CGSize size = image.size;
    GrayImageMat *mat = new GrayImageMat(VLSizeMake(size.width, size.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(mat->rawData(), size.width, size.height, 8, size.width * sizeof(Byte), colorSpace, kCGImageAlphaNone);
    CGRect drawRect = CGRectMake(0, 0, size.width, size.height);
    CGContextDrawImage(context, drawRect, image.CGImage);
    CFRelease(context);
    CFRelease(colorSpace);
    
    return mat;
}

UIImage *UIImageWithGrayImageMat(VLImageKit::GrayImageMat *mat) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    Byte *rawData = mat->rawData();
    VLSize imageSize = mat->size();
    CGContextRef context = CGBitmapContextCreate(rawData, imageSize.width, imageSize.height, 8, imageSize.width * sizeof(Byte), colorSpace, kCGImageAlphaNone);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:imageRef];
    CFRelease(context);
    CFRelease(colorSpace);
    CFRelease(imageRef);
    return grayImage;
}
