//
//  VLDot.h
//  VisionLAB
//
//  Created by chance on 9/11/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLDrawObject.h"

@interface VLDot : VLDrawObject

@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) CGFloat dotSize; // default is 1

+ (instancetype)dotWithLocation:(CGPoint)location;

@end
