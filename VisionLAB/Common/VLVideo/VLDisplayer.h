//
//  VLDisplayer.h
//  VisionLAB
//
//  Created by chance on 20/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>
#import "VLImageRenderer.h"

/**
 Display a cvpixelbuffer to an UIView
 */
@protocol VLDisplayerDelegate;
@interface VLDisplayer : NSObject

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) EAGLContext *context;
@property (nonatomic, weak) id<VLDisplayerDelegate> delegete;

- (void)updateWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end


@protocol VLDisplayerDelegate <NSObject>
@optional
// provides custom image render
- (VLImageRenderer *)customImageRendererWithSize:(CGSize)renderSize;

@end
