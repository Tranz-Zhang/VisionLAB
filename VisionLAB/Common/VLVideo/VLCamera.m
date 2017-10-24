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
    AVCaptureDeviceInput *_captureInput;
    AVCaptureVideoDataOutput *_captureOutput;
    dispatch_queue_t _captureQueue;
}

@end

@implementation VLCamera

+ (instancetype)cameraWithType:(VLCameraType)cameraType {
    VLCamera *camera = [VLCamera new];
    [camera setCameraType:cameraType];
    return camera;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _cameraType = VLCameraTypeBack;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"VLCamera dealloc");
    [self clean];
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


- (void)setCameraType:(VLCameraType)cameraType {
    _cameraType = cameraType;
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
    AVCaptureDevice *frontCameraDevice = [self deviceWithCameraType:_cameraType];
    if (!frontCameraDevice) {
        NSLog(@"Fail to get camera(%d)", (int)_cameraType);
        [self clean];
        return NO;
    }
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCameraDevice error:&error];
    if (!input || ![_captureSession canAddInput:input]) {
        NSLog(@"Fail to setup device input. %@", error);
        [self clean];
        return NO;
    }
    [_captureSession addInput:input];
    _captureInput = input;
    
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
    if (_captureSession.isRunning) {
        [_captureSession stopRunning];
    }
    [_captureSession removeInput:_captureInput];
    [_captureSession removeOutput:_captureOutput];
    _captureOutput = nil;
    _captureInput = nil;
    _captureSession = nil;
    _isCapturing = NO;
}


- (BOOL)switchCameraType:(VLCameraType)cameraType {
    if (!_captureSession || _cameraType == cameraType) {
        _cameraType = cameraType;
        return YES;
    }
    
    // prepare input
    AVCaptureDevice *cameraDevice = [self deviceWithCameraType:cameraType];
    if (!cameraDevice) {
        NSLog(@"Fail to get camera(%d)", (int)cameraType);
        [self clean];
        return NO;
    }
    NSError *error;
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
    if (!newInput || error) {
        NSLog(@"Fail to setup device input. %@", error);
        [self clean];
        return NO;
    }
    
    // prepare output
    AVCaptureVideoDataOutput *newOutput = [[AVCaptureVideoDataOutput alloc] init];
    [newOutput setSampleBufferDelegate:self queue:_captureQueue];
    NSDictionary *settings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    newOutput.videoSettings = settings;
    
    [_captureSession beginConfiguration];
    // setup input & output
    [_captureSession removeInput:_captureInput];
    [_captureSession removeOutput:_captureOutput];
    if ([_captureSession canAddInput:newInput] &&
        [_captureSession canAddOutput:newOutput]) {
        [_captureSession addInput:newInput];
        _captureInput = newInput;
        [_captureSession addOutput:newOutput];
        _captureOutput = newOutput;
        _cameraType = cameraType;
        
    } else {
        [_captureSession addInput:_captureInput];
        [_captureSession addOutput:_captureOutput];
    }
    [_captureSession commitConfiguration];
    
    return YES;
}


- (AVCaptureDevice *)deviceWithCameraType:(VLCameraType)cameraType {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionFront &&
            cameraType == VLCameraTypeFront) {
            return device;
            
        } else if (device.position == AVCaptureDevicePositionBack &&
                   cameraType == VLCameraTypeBack) {
            return device;
        }
    }
    return nil;
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





