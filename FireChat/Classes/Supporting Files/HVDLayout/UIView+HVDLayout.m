//
//  UIView+HVDLayout.h
//  Digirealty
//
//  Created by Jignesh Patel on 21/02/22.
//  Copyright © 2022 Digirealty. All rights reserved.
//

#import "UIView+HVDLayout.h"

@implementation UIView (HVDLayout)

// MARK: Center

- (NSArray *)HVDCenterInSuperView {
    NSMutableArray *addedConstraints = [NSMutableArray arrayWithCapacity:2];
    [addedConstraints addObject:[self HVDCenterXInSuperViewWithMultiplier:1.0f constant:0.0f]];
    [addedConstraints addObject:[self HVDCenterYInSuperViewWithMultiplier:1.0f constant:0.0f]];
    return addedConstraints;
}

- (NSLayoutConstraint *)HVDCenterXInSuperViewWithMultiplier:(CGFloat)multiplier constant:(CGFloat)constant {
    UIView *superview = self.superview;
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:multiplier constant:constant];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HVDCenterYInSuperViewWithMultiplier:(CGFloat)multiplier constant:(CGFloat)constant {
    UIView *superview = self.superview;
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:multiplier constant:constant];
    [superview addConstraint:constraint];
    return constraint;
}

@end
