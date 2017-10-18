//
//  VLDrawObject.m
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLDrawObject.h"

@implementation VLDrawObject

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)drawInRect:(CGRect)rect {
    // must be overwrited by subclass
}

@end
