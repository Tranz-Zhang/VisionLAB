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

@interface CameraViewController () <VLCameraProtocol> {
    VLCamera *_camera;
    VLDisplayer *_displayer;
}
@property (weak, nonatomic) IBOutlet UIImageView *displayView;
@property (weak, nonatomic) IBOutlet VLButton *operateButton;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _camera = [VLCamera new];
    _camera.delegate = self;
    [VLCamera checkPermission:^(BOOL granted) {
        NSLog(@"Check camera permission: %@", granted ? @"OK" : @"Failed");
    }];
    _displayer = [VLDisplayer new];
    
}


- (IBAction)onOperateButtonClicked:(UIButton *)button {
    if (!_displayer.view.superview) {
        _displayer.view.frame = self.displayView.frame;
        [self.view addSubview:_displayer.view];
    }
    
    if (_camera.isCapturing) {
        [_camera stopCapture];
        [button setTitle:@"Start" forState:UIControlStateNormal];
        
    } else {
        [_camera startCapture];
        [button setTitle:@"Stop" forState:UIControlStateNormal];
    }
}


#pragma mark - VLCameraProtocol
- (void)camera:(VLCamera *)camera didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (_displayer) {
        [_displayer updateWithPixelBuffer:pixelBuffer];
    }
}


@end

