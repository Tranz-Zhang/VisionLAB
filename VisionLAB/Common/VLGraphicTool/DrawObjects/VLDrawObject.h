//
//  VLDrawObject.h
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface VLDrawObject : NSObject

@property (nonatomic, strong) UIColor *color;

- (void)drawInRect:(CGRect)rect;

@end
