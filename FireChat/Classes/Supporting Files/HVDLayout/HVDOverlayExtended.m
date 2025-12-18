//
//  HVDOverlay.m
//
//  Created by Harshad on 01/08/14.
//

#import "HVDOverlayExtended.h"
#import "DGActivityIndicatorView.h"
#import "UIView+HVDLayout.h"

typedef NS_ENUM(NSInteger, OverlayType) {
    OverlayTypeIcon,
    OverlayTypeSpinner
};

@interface OverlayView : UIView

@property (strong, nonatomic) UIImage *iconImage;
@property (nonatomic, readonly) OverlayType type;


- (void)show;
- (void)dismiss;

@property (strong, nonatomic) UIColor *overlayColor;
@property (strong, nonatomic) UIColor *tintColor;

@end

@implementation OverlayView {
    __weak UIImageView *_iconImageView;
    __weak UIActivityIndicatorView *_spinner;
     DGActivityIndicatorView *activityIndicatorView;
}

- (instancetype)initWithType:(OverlayType)type {
    self = [super init];
    if (self != nil) {
        
        activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeThreeDots tintColor:[UIColor whiteColor] size:50.0f];
        activityIndicatorView.frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);

        _overlayColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        _type = type;
        [self setBackgroundColor:[UIColor clearColor]];

        switch (_type) {
            case OverlayTypeIcon: {
                UIImageView *iconImageView = [UIImageView new];
                [iconImageView setContentMode:UIViewContentModeCenter];
                [iconImageView setBackgroundColor:[UIColor clearColor]];
                [self addSubview:iconImageView];
                _iconImageView = iconImageView;

                NSDictionary *views = NSDictionaryOfVariableBindings(_iconImageView);
                [_iconImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_iconImageView]-|" options:0 metrics:nil views:views]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_iconImageView]-|" options:0 metrics:nil views:views]];
            }
                break;

            case OverlayTypeSpinner: {
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                [spinner setHidesWhenStopped:YES];
                [spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
                [self addSubview:spinner];
                _spinner = spinner;

                [self addConstraint:[NSLayoutConstraint constraintWithItem:_spinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:_spinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
            }
                break;

            default:
                break;
        }
    }
    return self;
}

- (UIActivityIndicatorView *)spinner {
    return _spinner;
}

- (void)setOverlayColor:(UIColor *)overlayColor {
    _overlayColor = overlayColor;
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [_spinner setColor:tintColor];
}

- (void)show {
    if (self.superview == nil) {
        [_spinner setColor:_tintColor];
        [_spinner startAnimating];

        UIView *backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [backgroundView setBackgroundColor:_overlayColor];
        [backgroundView addSubview:self];
        [self setFrame:backgroundView.bounds];

        [self setTransform:CGAffineTransformMakeScale(0.1f, 0.1f)];

        [[[UIApplication sharedApplication] keyWindow] addSubview:backgroundView];

        [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.4f initialSpringVelocity:0.0f options:(UIViewAnimationOptionCurveEaseOut) animations:^{
            [self setTransform:CGAffineTransformIdentity];
        } completion:^(BOOL finished) {

        }];
    }
}

- (void)showOnView:(UIView *)holderView {
    if (self.superview == nil)
    {
        UIView *backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [backgroundView setBackgroundColor:_overlayColor];
        [backgroundView addSubview:self];
        [self setFrame:backgroundView.bounds];
        
        [self setTransform:CGAffineTransformMakeScale(0.1f, 0.1f)];
        
        [holderView addSubview:backgroundView];
        
        [activityIndicatorView startAnimating];
        [holderView addSubview:activityIndicatorView];
        [activityIndicatorView HVDCenterInSuperView];

        [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.4f initialSpringVelocity:0.0f options:(UIViewAnimationOptionCurveEaseOut) animations:^{
            [self setTransform:CGAffineTransformIdentity];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)dismiss {
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.superview setAlpha:0.0f];
        });
    } completion:^(BOOL finished) {
        [self->activityIndicatorView stopAnimating];
        [self.superview removeFromSuperview];
    }];
}

- (void)setIconImage:(UIImage *)iconImage {
    _iconImage = iconImage;
    [_iconImageView setImage:iconImage];
}

@end

@implementation HVDOverlayExtended {
    OverlayView *_overlayView;
}

+ (instancetype)overlayWithImage:(UIImage *)image {
    HVDOverlayExtended *overlay = [[[self class] alloc] init];
    overlay->_overlayView = [[OverlayView alloc] initWithType:OverlayTypeIcon];
    [overlay->_overlayView setIconImage:image];
    return overlay;
}

+ (instancetype)spinnerOverlay {
    HVDOverlayExtended *overlay = [[[self class] alloc] init];
    OverlayView *overlayView = [[OverlayView alloc] initWithType:OverlayTypeSpinner];
    overlay->_overlayView = overlayView;
    return overlay;
}

- (void)show {
    [_overlayView show];
}

- (void)showOnView:(UIView *)holderView {
    [_overlayView showOnView:holderView];
}

- (void)dismiss {
    [_overlayView dismiss];
}

- (void)setOverlayColor:(UIColor *)overlayColor {
    [_overlayView setOverlayColor:overlayColor];
}

- (void)setTintColor:(UIColor *)tintColor {
    [_overlayView setTintColor:tintColor];
}

@end
