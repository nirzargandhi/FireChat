//
//  HVDOverlay.h
//
//  Created by Harshad on 01/08/14.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface HVDOverlayExtended : NSObject

+ (instancetype)overlayWithImage:(UIImage *)image;

+ (instancetype)spinnerOverlay;

- (void)show;
- (void)dismiss;
- (void)showOnView:(UIView *)holderView;

- (void)setOverlayColor:(UIColor *)overlayColor;

- (void)setTintColor:(UIColor *)tintColor;

@end
