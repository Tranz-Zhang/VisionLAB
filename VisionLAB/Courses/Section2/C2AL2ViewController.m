//
//  C2AL2ViewController.m
//  VisionLAB
//
//  Created by chance on 2/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "C2AL2ViewController.h"
#import "LabUtils.h"

@interface C2AL2ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation C2AL2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)onTestAverageFilter:(UIButton *)sender {
    UIImage *sourceImage = [UIImage imageNamed:@"avatar_100.png"];
    NSData *imageData = [LabUtils grayScaleDataWithImage:sourceImage];
    
    CGSize size = sourceImage.size;
    Byte *rawData = (Byte *)imageData.bytes;
    for (int row = 0; row < size.height; row++) {
        for (int col = 0; col < size.width; col++) {
//            int value = rawData[(int)(col + row * size.width)];
//
//            rawData[(int)(col + row * size.width)] = [self averageColorValueAtLocation:CGPointMake(col, row) withRawData:rawData];
//            printf("%d ", value);
        }
//        printf("\n");
    }
    
    // show image
    UIImage *grayImage = [LabUtils grayScaleImageWithData:imageData size:sourceImage.size];;
    self.resultView.contentMode = UIViewContentModeCenter;
    self.resultView.image = grayImage;
}


//- (Byte)averageColorValueAtLocation:(CGPoint)location
//                        withRawData:(Byte *)rawData {
//
//
//    return 0;
//}


@end


