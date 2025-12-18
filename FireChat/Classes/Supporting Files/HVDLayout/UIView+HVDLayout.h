//
//  UIView+HVDLayout.h
//  Digirealty
//
//  Created by Jignesh Patel on 21/02/22.
//  Copyright © 2022 Digirealty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HVDLayout)

// MARK: Center
- (NSArray *)HVDCenterInSuperView;
- (NSLayoutConstraint *)HVDCenterXInSuperViewWithMultiplier:(CGFloat)multiplier constant:(CGFloat)constant;
- (NSLayoutConstraint *)HVDCenterYInSuperViewWithMultiplier:(CGFloat)multiplier constant:(CGFloat)constant;

@end
