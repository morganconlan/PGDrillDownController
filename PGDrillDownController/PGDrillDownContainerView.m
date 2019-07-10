//
//  PGDrillDownContainerView.m
//  PGDrillDownControllerDemo
//
//  Created by Simon Booth on 11/04/2013.
//  Copyright (c) 2013 Simon Booth. All rights reserved.
//

#import "PGDrillDownContainerView.h"

#define ON_LEGACY_UI ([[[UIDevice currentDevice] systemVersion] integerValue] < 7)

static const CGFloat kPGDrillDownContainerTransitionShadowRadius = 5.0;

@interface PGDrillDownContainerView ()

@property (weak, nonatomic) UIImageView *shadowView;
@property (weak, nonatomic) UIView *fadingView;
@property (assign, nonatomic) PGDrillDownContainerShadow shadowPosition;

@end

@implementation PGDrillDownContainerView

@synthesize borderBackgroundColor=_borderBackgroundColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIColor *borderColor = self.borderBackgroundColor;

        _leftBorderView = [[UIView alloc] init];
        _leftBorderView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _leftBorderView.opaque = YES;
        _leftBorderView.backgroundColor = borderColor;
        [self addSubview:_leftBorderView];
        
        _rightBorderView = [[UIView alloc] init];
        _rightBorderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        _rightBorderView.opaque = YES;
        _rightBorderView.backgroundColor = borderColor;
        [self addSubview:_rightBorderView];
        
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
    }
    return self;
}

- (void)addViewToContentView:(UIView *)view
{
    view.autoresizingMask = UIViewAutoresizingNone;
    [self.contentView addSubview:view];
}

- (void)layoutSubviews
{
    CGRect frame = self.bounds;
    
    self.contentView.frame = frame;
    self.leftBorderView.frame = CGRectMake(-1, 0, 1, frame.size.height);
    self.rightBorderView.frame = CGRectMake(frame.size.width, 0, 1, frame.size.height);
}

// on iOS 7, the center and bounds keep getting messed up by _applyISEngineLayoutValues
// but since we only ever set the frame, we can stop it by killing setCenter and setBounds.
- (void)setCenter:(CGPoint)center { return; }
- (void)setBounds:(CGRect)bounds { return; }

- (UIColor *)borderBackgroundColor
{
    if (_borderBackgroundColor)
    {
        return _borderBackgroundColor;
    }
    else
    {
        return ON_LEGACY_UI ? [UIColor blackColor] : [UIColor lightGrayColor];
    }
}

- (void)setBorderBackgroundColor:(UIColor *)borderBackgroundColor
{
     _borderBackgroundColor = borderBackgroundColor;
    self.leftBorderView.backgroundColor = borderBackgroundColor;
    self.rightBorderView.backgroundColor = borderBackgroundColor;
}

- (UIImage *)shadowImageForPosition:(PGDrillDownContainerShadow)position
{
    static UIImage *shadowImageBoth;
    static UIImage *shadowImageLeft;
    static UIImage *shadowImageRight;

    UIImage * __strong *shadowImageRef = nil;
    switch (position)
    {
        case PGDrillDownContainerShadowNone:
            return nil;
        case PGDrillDownContainerShadowBoth:
            shadowImageRef = &shadowImageBoth;
            break;
        case PGDrillDownContainerShadowLeft:
            shadowImageRef = &shadowImageLeft;
            break;
        case PGDrillDownContainerShadowRight:
            shadowImageRef = &shadowImageRight;
            break;
    }

    if (!(*shadowImageRef))
    {
        UIGraphicsBeginImageContext(CGSizeMake(1.0 + (kPGDrillDownContainerTransitionShadowRadius * 2.0), 1.0));
        CGContextRef c = UIGraphicsGetCurrentContext();

        CGFloat locations[2] = {0.0, 1.0};
        NSArray *colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                            (id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor,];
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (CFArrayRef)colors, locations);

        switch (position)
        {
            case PGDrillDownContainerShadowNone:
                break;
            case PGDrillDownContainerShadowBoth:
                CGContextDrawLinearGradient(c, gradient, CGPointMake(0.0, 0.0), CGPointMake(kPGDrillDownContainerTransitionShadowRadius, 0.0), 0);
                CGContextDrawLinearGradient(c, gradient, CGPointMake(1.0 + 2.0 * kPGDrillDownContainerTransitionShadowRadius, 0.0), CGPointMake(kPGDrillDownContainerTransitionShadowRadius + 1.0, 0.0), 0);
                break;
            case PGDrillDownContainerShadowLeft:
                CGContextDrawLinearGradient(c, gradient, CGPointMake(0.0, 0.0), CGPointMake(kPGDrillDownContainerTransitionShadowRadius, 0.0), 0);
                break;
            case PGDrillDownContainerShadowRight:
                CGContextDrawLinearGradient(c, gradient, CGPointMake(1.0 + 2.0 * kPGDrillDownContainerTransitionShadowRadius, 0.0), CGPointMake(kPGDrillDownContainerTransitionShadowRadius + 1.0, 0.0), 0);
                break;
        }

        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorspace);

        *shadowImageRef = [image resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, kPGDrillDownContainerTransitionShadowRadius, 1.0, kPGDrillDownContainerTransitionShadowRadius)];
    }
    return *shadowImageRef;
}

- (void)addShadowViewAtPosition:(PGDrillDownContainerShadow)position;
{

    if (!self.shadowView)
    {
        UIImageView *shadowView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, -kPGDrillDownContainerTransitionShadowRadius, 0.0)];
        shadowView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.shadowView = shadowView;
        [self addSubview:shadowView];
    }
    if (self.shadowPosition != position)
    {
        self.shadowView.image = [self shadowImageForPosition:position];
        self.shadowPosition = position;
    }
}

- (void)removeShadowView
{
    [self.shadowView removeFromSuperview];
    self.shadowView = nil;
    self.shadowPosition = PGDrillDownContainerShadowNone;
}

- (void)setShadowViewAlpha:(CGFloat)alpha
{
    self.shadowView.alpha = alpha;
}

- (void)addFadingView
{
    if (!self.fadingView)
    {
        UIView *fadingView = [[UIView alloc] initWithFrame:self.bounds];
        fadingView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        fadingView.backgroundColor = [UIColor blackColor];
        self.fadingView = fadingView;
        [self addSubview:fadingView];
    }
}

- (void)removeFadingView
{
    [self.fadingView removeFromSuperview];
    self.fadingView = nil;
}

- (void)setFadingViewAlpha:(CGFloat)alpha
{
    self.fadingView.alpha = alpha;
}

@end

@implementation UIView (PGDrillDownContainerView)

- (PGDrillDownContainerView *)drillDownContainerView
{
    for (UIView *view = self.superview; view; view = view.superview)
    {
        if ([view isKindOfClass:[PGDrillDownContainerView class]]) return (PGDrillDownContainerView *)view;
    }
    
    return nil;
}

@end

