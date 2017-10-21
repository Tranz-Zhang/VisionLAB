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

@interface CameraViewController () {
    VLCamera *_camera;
}
@property (weak, nonatomic) IBOutlet UIImageView *displayView;
@property (weak, nonatomic) IBOutlet VLButton *operateButton;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _camera = [VLCamera new];
    [VLCamera checkPermission:^(BOOL granted) {
        NSLog(@"Check camera permission: %@", granted ? @"OK" : @"Failed");
    }];
}


- (IBAction)onOperateButtonClicked:(UIButton *)button {
    if (_camera.isCapturing) {
        [_camera stopCapture];
        [button setTitle:@"Start" forState:UIControlStateNormal];
        
    } else {
        [_camera startCapture];
        [button setTitle:@"Stop" forState:UIControlStateNormal];
    }
}


@end

