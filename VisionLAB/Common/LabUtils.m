//
//  LabUtils.m
//  VisionLAB
//
//  Created by chance on 14/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "LabUtils.h"

@implementation LabUtils

+ (UIImage *)grayScaleImage:(UIImage *)image {
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, imageRect.size.width, imageRect.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, image.CGImage);
//    UIImage *grayImage = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:imageRef];
    CFRelease(context);
    CFRelease(colorSpace);
    CFRelease(imageRef);
    return grayImage;
}



+ (NSData *)grayScaleDataWithImage:(UIImage *)image {
    CGSize size = image.size;
    unsigned int dataLength = size.width * size.height * 1 * sizeof(Byte);
    Byte *rawData = malloc(dataLength);
    memset(rawData, 0, dataLength);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(rawData, size.width, size.height, 8, size.width * sizeof(Byte), colorSpace, kCGImageAlphaNone);
    CGRect drawRect = CGRectMake(0, 0, size.width, size.height);
    CGContextDrawImage(context, drawRect, image.CGImage);
    CFRelease(context);
    CFRelease(colorSpace);
    NSData *imageData = [NSData dataWithBytesNoCopy:rawData length:dataLength];
    return imageData;
}


+ (UIImage *)grayScaleImageWithData:(NSData *)grayScaleData
                               size:(CGSize)imageSize {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    Byte *rawData = (Byte *)grayScaleData.bytes;
    CGContextRef context = CGBitmapContextCreate(rawData, imageSize.width, imageSize.height, 8, imageSize.width * sizeof(Byte), colorSpace, kCGImageAlphaNone);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:imageRef];
    CFRelease(context);
    CFRelease(colorSpace);
    CFRelease(imageRef);
    return grayImage;
    
}

@end






