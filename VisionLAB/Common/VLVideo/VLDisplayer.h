//
//  VLDisplayer.h
//  VisionLAB
//
//  Created by chance on 20/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

/**
 Display a cvpixelbuffer to an UIView
 */
@interface VLDisplayer : NSObject

@property (nonatomic, readonly) UIView *view;

- (void)updateWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
