//
//  VLDrawView.h
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLDrawObject.h"
#import "VLLine.h"
#import "VLRectangle.h"
#import "VLCircle.h"
#import "VLDot.h"


@interface VLDrawView : UIView

- (void)updateWithObjects:(NSArray <VLDrawObject *> *)objects;

@end
