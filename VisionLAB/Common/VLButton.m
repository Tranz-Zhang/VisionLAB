//
//  VLButton.m
//  VisionLAB
//
//  Created by chance on 24/9/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "VLButton.h"

@implementation VLButton


- (void)awakeFromNib {
    [super awakeFromNib];
    
    // setup bg
    UIImage *bgImage = [[UIImage imageNamed:@"default_button_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    UIImage *selectedBGImage = [[UIImage imageNamed:@"default_button_selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    [self setBackgroundImage:selectedBGImage forState:UIControlStateHighlighted];
    // setup title
    self.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightLight];
    [self setTitleColor:[UIColor colorWithWhite:0.1 alpha:1] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithWhite:0.9 alpha:1] forState:UIControlStateHighlighted];
    self.backgroundColor = [UIColor clearColor];
    self.adjustsImageWhenHighlighted = NO;
    self.titleLabel.minimumScaleFactor = 0.6;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
