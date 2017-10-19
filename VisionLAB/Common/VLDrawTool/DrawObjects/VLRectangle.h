//
//  VLRectangle.h
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLDrawObject.h"

@interface VLRectangle : VLDrawObject

@property (nonatomic, assign) CGRect rect;

+ (instancetype)rectangleWithRect:(CGRect)rect;

@end
