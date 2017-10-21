//
//  VLCamera.m
//  VisionLAB
//
//  Created by chance on 20/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "VLCamera.h"

@interface VLCamera () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *_captureSession;
    AVCaptureVideoDataOutput *_captureOutput;
    dispatch_queue_t _captureQueue;
}

@end

@implementation VLCamera

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void)checkPermission:(void(^)(BOOL granted))completion {
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) {
        if (completion) {
            completion(YES);
        }
        return;
    }
    
    // For iOS7+
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            if (completion) {
                completion(YES);
            }
            break;
            
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            if (completion) {
                completion(NO);
            }
            break;
            
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (completion) {
                    completion(granted);
                }
            }];
            break;
        }
            
        default:
            break;
    }
}


- (BOOL)startCapture {
    if (AVAuthorizationStatusAuthorized != [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        NSLog(@"Error: No camera permission");
        return NO;
    }
    if (_isCapturing) {
        return YES;
    }
    
    if (![self setupCamera]) {
        NSLog(@"Error: Fail to setup camera");
        return NO;
    }
    
    [_captureSession startRunning];
    _isCapturing = YES;
    return YES;
}


- (BOOL)setupCamera {
    if (_captureSession) {
        return YES;
    }
    
    // setup input
    _captureSession = [[AVCaptureSession alloc] init];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *frontCameraDevice = nil;
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionFront) {
            frontCameraDevice = device;
            break;
        }
    }
    if (!frontCameraDevice) {
        NSLog(@"Fail to get front camera.");
        [self clean];
        return NO;
    }
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCameraDevice error:&error];
    if (!input) {
        NSLog(@"Fail to setup device input. %@", error);
        [self clean];
        return NO;
    }
    [_captureSession addInput:input];
    
    // setup output
    _captureQueue = dispatch_queue_create("com.bychance.visionlab.camera", DISPATCH_QUEUE_SERIAL);
    _captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_captureOutput setSampleBufferDelegate:self queue:_captureQueue];
    NSDictionary *settings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    _captureOutput.videoSettings = settings;
    [_captureSession addOutput:_captureOutput];
    
    return YES;
}


- (void)stopCapture {
    [_captureSession stopRunning];
    [self clean];
    _isCapturing = NO;
}


- (void)clean {
    [_captureSession removeOutput:_captureOutput];
    _captureOutput = nil;
    _captureSession = nil;
    _isCapturing = NO;
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    printf("capture\n");
    if ([self.delegate respondsToSelector:@selector(camera:didOutputPixelBuffer:)]) {
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        [self.delegate camera:self didOutputPixelBuffer:imageBuffer];
    }
}


@end





