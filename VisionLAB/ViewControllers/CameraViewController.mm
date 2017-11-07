//
//  CameraViewController.m
//  VisionLAB
//
//  Created by chance on 20/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "CameraViewController.h"
#import "VLButton.h"
#import "VLCamera.h"
#import "VLDisplayer.h"

@interface CameraViewController () <VLCameraDelegate, VLDisplayerDelegate> {
    VLCamera *_camera;
    VLDisplayer *_displayer;
}
@property (weak, nonatomic) IBOutlet UIImageView *displayView;
@property (weak, nonatomic) IBOutlet VLButton *operateButton;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _camera = [VLCamera cameraWithType:VLCameraTypeBack];
    _camera.delegate = self;
    [VLCamera checkPermission:^(BOOL granted) {
        NSLog(@"Check camera permission: %@", granted ? @"OK" : @"Failed");
    }];
    _displayer = [VLDisplayer new];
    _displayer.delegete = self;
}


- (IBAction)onOperateButtonClicked:(UIButton *)button {
    if (!_displayer.view.superview) {
        _displayer.view.frame = self.displayView.frame;
        [self.view addSubview:_displayer.view];
        self.displayView.hidden = YES;
    }
    
    if (_camera.isCapturing) {
        [_camera stopCapture];
        [button setTitle:@"Start" forState:UIControlStateNormal];
        
    } else {
        [_camera startCapture];
        [button setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (IBAction)onSwitchCamera {
    if (_camera.cameraType == VLCameraTypeBack) {
        [_camera switchCameraType:VLCameraTypeFront];
        
    } else {
        [_camera switchCameraType:VLCameraTypeBack];
    }
}


#pragma mark - VLCameraDelegate
- (void)camera:(VLCamera *)camera didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (_displayer) {
        [_displayer updateWithPixelBuffer:pixelBuffer];
    }
}


#pragma mark - VLDisplayerDelegate
- (VLImageRenderer *)customImageRendererWithSize:(CGSize)renderSize {
    return [[VLImageRenderer alloc] initWithSize:renderSize type:VLImageKit::RendererTypeRed];
}



@end

