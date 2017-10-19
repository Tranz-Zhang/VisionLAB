//
//  VLCircle.h
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLDrawObject.h"

@interface VLCircle : VLDrawObject

@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGFloat radius;

+ (instancetype)circleWithCenter:(CGPoint)center
                          radius:(CGFloat)raduis;

@end
