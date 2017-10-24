//
//  VLCamera.h
//  VisionLAB
//
//  Created by chance on 20/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>


typedef NS_ENUM(NSInteger, VLCameraType) {
    VLCameraTypeFront = 0,
    VLCameraTypeBack,
};

/**
 VLCamera is responsed for capturing camera data as cvpixelbuffer.
 */
@protocol VLCameraDelegate;
@interface VLCamera : NSObject

@property (nonatomic, weak) id <VLCameraDelegate> delegate;
@property (nonatomic, readonly) BOOL isCapturing;
@property (nonatomic, readonly) VLCameraType cameraType;

// check permission for camera access
+ (void)checkPermission:(void(^)(BOOL granted))completion;

+ (instancetype)cameraWithType:(VLCameraType)cameraType;

- (BOOL)startCapture;
- (void)stopCapture;

- (BOOL)switchCameraType:(VLCameraType)cameraType;

@end

@protocol VLCameraDelegate <NSObject>

// call async
- (void)camera:(VLCamera *)camera didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
