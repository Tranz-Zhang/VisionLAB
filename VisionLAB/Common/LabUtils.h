//
//  LabUtils.h
//  VisionLAB
//
//  Created by chance on 14/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LabUtils : NSObject

+ (UIImage *)grayScaleImage:(UIImage *)image;
+ (NSData *)grayScaleDataWithImage:(UIImage *)image;
+ (UIImage *)grayScaleImageWithData:(NSData *)grayScaleData size:(CGSize)imageSize;

@end
