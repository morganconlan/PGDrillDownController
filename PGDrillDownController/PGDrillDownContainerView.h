//
//  PGDrillDownContainerView.h
//  PGDrillDownControllerDemo
//
//  Created by Simon Booth on 11/04/2013.
//  Copyright (c) 2013 Simon Booth. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PGDrillDownContainerShadow)
{
    PGDrillDownContainerShadowNone=0,
    PGDrillDownContainerShadowBoth,
    PGDrillDownContainerShadowLeft,
    PGDrillDownContainerShadowRight,
};

@interface PGDrillDownContainerView : UIView

@property (nonatomic, strong) UIColor *borderBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, readonly) UIView *leftBorderView;
@property (nonatomic, strong, readonly) UIView *rightBorderView;
@property (nonatomic, strong, readonly) UIView *contentView;

- (void)addViewToContentView:(UIView *)view;

- (void)addShadowViewAtPosition:(PGDrillDownContainerShadow)position;
- (void)removeShadowView;
- (void)setShadowViewAlpha:(CGFloat)alpha;

- (void)addFadingView;
- (void)removeFadingView;
- (void)setFadingViewAlpha:(CGFloat)alpha;

@end

@interface UIView (PGDrillDownContainerView)

@property (nonatomic, strong, readonly) PGDrillDownContainerView *drillDownContainerView;

@end
