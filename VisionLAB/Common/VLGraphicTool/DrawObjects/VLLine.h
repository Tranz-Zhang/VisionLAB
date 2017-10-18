//
//  VLLine.h
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLDrawObject.h"

@interface VLLine : VLDrawObject

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;

+ (instancetype)lineWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint;

@end
