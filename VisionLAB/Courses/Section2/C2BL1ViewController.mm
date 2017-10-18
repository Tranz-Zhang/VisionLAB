//
//  C2BL1ViewController.m
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "C2BL1ViewController.h"
#import "VLDrawView.h"

@interface C2BL1ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet VLDrawView *assistView;


@end

@implementation C2BL1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (IBAction)onTestHoughTransform:(id)sender {
    
}


- (void)testDraw {
    VLLine *line1 = [VLLine lineWithStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(arc4random() % 300, 100)];
    VLRectangle *rect1 = [VLRectangle rectangleWithRect:CGRectInset(self.assistView.bounds, 20, 50)];
    VLCircle *circle = [VLCircle circleWithCenter:CGPointMake(120, 200) radius:50];
    [self.assistView updateWithObjects:@[line1, rect1, circle]];
}


@end
