//
//  VLCamera.h
//  VisionLAB
//
//  Created by chance on 20/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

/**
 VLCamera is responsed for capturing camera data as cvpixelbuffer.
 */
@protocol VLCameraProtocol;
@interface VLCamera : NSObject

@property (nonatomic, weak) id <VLCameraProtocol> delegate;
@property (nonatomic, readonly) BOOL isCapturing;

// check permission for camera access
+ (void)checkPermission:(void(^)(BOOL granted))completion;

- (BOOL)startCapture;
- (void)stopCapture;

@end

@protocol VLCameraProtocol <NSObject>

// call async
- (void)camera:(VLCamera *)camera didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
