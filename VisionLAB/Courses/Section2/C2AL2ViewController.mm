//
//  C2AL2ViewController.m
//  VisionLAB
//
//  Created by chance on 2/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "C2AL2ViewController.h"
#import "LabUtils.h"
#import "VLImageMatTools.h"

using namespace VLImageKit;

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
    
    GrayImageMat *grayMat = CreateGrayImageMatWithUIImage(sourceImage);
    
    VLSize size = grayMat->size();
    for (int row = 0; row < size.height; row++) {
        for (int col = 0; col < size.width; col++) {
            if (row == 50) {
                grayMat->setValue(0, VLPointMake(col, row)); // draw a black line
            }
        }
    }
    
    // show image
    UIImage *grayImage = UIImageWithGrayImageMat(grayMat);
    self.resultView.contentMode = UIViewContentModeCenter;
    self.resultView.image = grayImage;
}


@end


