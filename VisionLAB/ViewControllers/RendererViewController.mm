//
//  RendererViewController.m
//  VisionLAB
//
//  Created by chance on 21/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "RendererViewController.h"
#import "VLImageRenderer.h"
#import "VLDisplayer.h"

@interface RendererViewController () {
    VLImageRenderer *_renderer;
    VLDisplayer *_displayer;
}

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation RendererViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize renderSize = CGSizeMake(512, 512);
    _renderer = [[VLImageRenderer alloc] initWithSize:renderSize type:VLImageRenderKit::RendererTypeDefault];
    _displayer = [VLDisplayer new];
}


- (IBAction)onTestVLDisplayer:(UIButton *)sender {
    if (!_displayer.view.superview) {
        _displayer.view.frame = self.resultView.frame;
        [self.view addSubview:_displayer.view];
    }
    
    // get image
    UIImage *sourceImage = [UIImage imageNamed:@"inhouse_512.jpg"];
    CVPixelBufferRef sourcePixelBuffer = [self pixelBufferWithUIImage:sourceImage];
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [_displayer updateWithPixelBuffer:sourcePixelBuffer];
    CFRelease(sourcePixelBuffer);
    sourcePixelBuffer = NULL;
    
    double duration = CFAbsoluteTimeGetCurrent() - startTime;
    self.infoLabel.text = [NSString stringWithFormat:@"%.2fms", duration * 1000];
}


- (IBAction)onTestRenderer:(UIButton *)sender {
#if 0
    UIImage *sourceImage = [UIImage imageNamed:@"inhouse_512.jpg"];
    VLPixelLayer *sourceLayer = [VLPixelLayer sourceLayerWithImage:sourceImage];
#else
    UIImage *sourceImage = [UIImage imageNamed:@"hough_line_test.png"];
    CVPixelBufferRef sourcePixelBuffer = [self pixelBufferWithUIImage:sourceImage];
    VLPixelLayer *sourceLayer = [VLPixelLayer layerWithPixelBuffer:sourcePixelBuffer];
#endif
    VLPixelLayer *resultLayer = [VLPixelLayer destinationLayerWithSize:CGSizeMake(600, 600)];
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [_renderer renderLayer:sourceLayer toLayer:resultLayer];
    
    CGImageRef cgimage = [resultLayer newCGImageFromCurrentContent];
    self.resultView.image = [UIImage imageWithCGImage:cgimage scale:2.0 orientation:UIImageOrientationUp];
    CGImageRelease(cgimage);
    
    double duration = CFAbsoluteTimeGetCurrent() - startTime;
    self.infoLabel.text = [NSString stringWithFormat:@"%.2fms", duration * 1000];
}


#pragma mark - Others
- (CVPixelBufferRef)pixelBufferWithUIImage:(UIImage *)image  {
    if (!image) {
        return nil;
    }
    
    CVPixelBufferRef outputPixelBuffer;
    size_t width = image.size.width * image.scale;
    size_t height = image.size.height * image.scale;
    NSDictionary *options = @{(id)kCVPixelFormatOpenGLESCompatibility   : @(YES),
                              (id)kCVPixelFormatCGBitmapContextCompatibility : @(YES),
                              (id)kCVPixelFormatCGImageCompatibility    : @(YES),
                              (id)kCVPixelBufferIOSurfacePropertiesKey  : @{}
                              };
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &outputPixelBuffer);
    if (!outputPixelBuffer) {
        return nil;
    }
    
    CIImage *ciimage = [CIImage imageWithCGImage:image.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    [context render:ciimage toCVPixelBuffer:outputPixelBuffer];
    return outputPixelBuffer;
}

@end
