//
//  RendererViewController.m
//  VisionLAB
//
//  Created by chance on 21/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "RendererViewController.h"
#import "VLImageRenderer.h"


@interface RendererViewController () {
    VLImageRenderer *_renderer;
}

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation RendererViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize renderSize = CGSizeMake(512, 512);
    _renderer = [[VLImageRenderer alloc] initWithSize:renderSize type:VLImageRenderKit::RendererTypeDefault];
}


- (IBAction)onTestRenderer:(UIButton *)sender {
    UIImage *sourceImage = [UIImage imageNamed:@"inhouse_512.jpg"];
    VLPixelLayer *sourceLayer = [VLPixelLayer layerWithImage:sourceImage];
    VLPixelLayer *resultLayer = [VLPixelLayer layerWithSize:CGSizeMake(600, 600)];
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [_renderer renderLayer:sourceLayer toLayer:resultLayer];
    
    CGImageRef cgimage = [resultLayer newCGImageFromCurrentContent];
    self.resultView.image = [UIImage imageWithCGImage:cgimage scale:2.0 orientation:UIImageOrientationUp];
    CGImageRelease(cgimage);
    
    double duration = CFAbsoluteTimeGetCurrent() - startTime;
    self.infoLabel.text = [NSString stringWithFormat:@"%.2fms", duration * 1000];
}


@end
