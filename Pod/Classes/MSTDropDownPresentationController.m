//
//  MSTDropDownPresentationController.m
//  MSTDropDownPresentationController
//
//  Created by Masahiko Tsujita on 14/11/01.
//  Copyright (c) 2014 Masahiko Tsujita. All rights reserved.
//

#import "MSTDropDownPresentationController.h"

static const NSInteger MSTDropDownPresentationControllerTapGestureRecognitionViewTag = 101;
static const NSInteger MSTDropDownPresentationControllerTopEdgeClipViewTag = 102;
static const NSInteger MSTDropDownPresentationControllerRoundedCornerClipViewTag = 103;

@interface MSTRoundedCornerView : UIView

@property (assign, nonatomic) CGFloat cornerRadius;

@end

@implementation MSTRoundedCornerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *maskView = [[UIView alloc] initWithFrame:frame];
        maskView.backgroundColor = [UIColor whiteColor];
        maskView.frame = CGRectMake(0, -frame.size.height, frame.size.width, frame.size.height * 2);
        self.maskView = maskView;
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.cornerRadius = 15;
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.maskView.layer.cornerRadius = _cornerRadius;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.maskView.frame = CGRectMake(0, -frame.size.height, frame.size.width, frame.size.height * 2);
}

@end

@interface MSTDropDownPresentationController ()

@property (nonatomic, readonly) UIViewController *sourceViewController;

@end

@implementation MSTDropDownPresentationController {
    UIView *_backgroundView;
    UIView *_tapGestureRecognitionView;
    UIView *_outerClipView;
    MSTRoundedCornerView *_innerClipView;
}

#pragma mark - Initializing MSTDropDownPresentationController Object

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        self.cornerRadius = 15.0f;
        self.layoutMargins = UIEdgeInsetsMake(8, 8, 8, 8);
        self.dismissesOnBackgroundTap = YES;
        self.backgroundAlpha = 0.5;
        _sourceViewController = presentingViewController;
    }
    return self;
}

#pragma mark - Calculating View Frames

- (CGRect)frameOfViewControllerViewInContainerView:(UIViewController *)viewController {
    CGRect frameInViewControllerView = viewController.view.bounds;
    frameInViewControllerView.origin.y += viewController.topLayoutGuide.length;
    frameInViewControllerView.size.height -= viewController.topLayoutGuide.length;
    CGRect frameInContainerView = [self.containerView convertRect:frameInViewControllerView fromCoordinateSpace:viewController.view];
    return frameInContainerView;
}

- (CGRect)frameOfOuterClipViewInContainerView {
    BOOL flag = NO;
    if (self.presentingViewController == self.sourceViewController) {
        flag = YES;
    }
    if ([self.presentingViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.presentingViewController;
        if (splitViewController.isCollapsed) {
            UIViewController *primaryViewController = [splitViewController.viewControllers firstObject];
            if (primaryViewController == self.sourceViewController) {
                flag = YES;
            }
            if ([primaryViewController isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabBarController = (UITabBarController *) primaryViewController;
                UIViewController *selectedViewController = tabBarController.selectedViewController;
                if (selectedViewController == self.sourceViewController) {
                    flag = YES;
                }
                if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
                    UINavigationController *navigationController = (UINavigationController *) selectedViewController;
                    if (navigationController.topViewController == self.sourceViewController || flag) {
                        return [self frameOfViewControllerViewInContainerView:navigationController.topViewController];
                    } else {
                        return CGRectZero;
                    }
                } else {
                    return [self frameOfViewControllerViewInContainerView:selectedViewController];
                }
            } else if ([primaryViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navigationController = (UINavigationController *) primaryViewController;
                UIViewController *topViewController = navigationController.topViewController;
                if (topViewController == self.sourceViewController) {
                    flag = YES;
                }
                if ([topViewController isKindOfClass:[UINavigationController class]]) {
                    UINavigationController *navigationControllerInNavigationController = (UINavigationController *) topViewController;
                    if (navigationControllerInNavigationController.topViewController == self.sourceViewController || flag) {
                        return [self frameOfViewControllerViewInContainerView:navigationControllerInNavigationController.topViewController];
                    } else {
                        return CGRectZero;
                    }
                } else if (flag) {
                    return [self frameOfViewControllerViewInContainerView:topViewController];
                } else {
                    return CGRectZero;
                }
            } else if (flag) {
                return [self frameOfViewControllerViewInContainerView:primaryViewController];
            } else {
                return CGRectZero;
            }
        } else {
            UIViewController *primaryViewController = [splitViewController.viewControllers firstObject];
            if (primaryViewController == self.sourceViewController) {
                flag = YES;
            }
            if ([primaryViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navigationController = (UINavigationController *) primaryViewController;
                if (navigationController.topViewController == self.sourceViewController || flag) {
                    if (splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible || splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryOverlay) {
                        return [self frameOfViewControllerViewInContainerView:navigationController.topViewController];
                    } else {
                        return CGRectZero;
                    }
                }
            } else if ([primaryViewController isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabBarController = (UITabBarController *) primaryViewController;
                UIViewController *selectedViewController = tabBarController.selectedViewController;
                if (selectedViewController == self.sourceViewController) {
                    flag = YES;
                }
                if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
                    UINavigationController *navigationController = (UINavigationController *) selectedViewController;
                    if (navigationController.topViewController == self.sourceViewController || flag) {
                        if (splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible || splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryOverlay) {
                            return [self frameOfViewControllerViewInContainerView:navigationController.topViewController];
                        } else {
                            return CGRectZero;
                        }
                    }
                } else if (flag) {
                    if (splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible || splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryOverlay) {
                        return [self frameOfViewControllerViewInContainerView:selectedViewController];
                    } else {
                        return CGRectZero;
                    }
                }
            }
            if (!flag && splitViewController.viewControllers.count > 1) {
                UIViewController *secondaryViewController = [splitViewController.viewControllers lastObject];
                if (secondaryViewController == self.sourceViewController) {
                    flag = YES;
                }
                if ([secondaryViewController isKindOfClass:[UINavigationController class]]) {
                    UINavigationController *navigationController = (UINavigationController *) secondaryViewController;
                    if (navigationController.topViewController == self.sourceViewController || flag) {
                        if (splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible || splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
                            return [self frameOfViewControllerViewInContainerView:navigationController.topViewController];
                        } else {
                            return CGRectZero;
                        }
                    } else {
                        return CGRectZero;
                    }
                } else if ([secondaryViewController isKindOfClass:[UITabBarController class]]) {
                    UITabBarController *tabBarController = (UITabBarController *) secondaryViewController;
                    UIViewController *selectedViewController = tabBarController.selectedViewController;
                    if (selectedViewController == self.sourceViewController) {
                        flag = YES;
                    }
                    if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
                        UINavigationController *navigationController = (UINavigationController *) selectedViewController;
                        if (navigationController.topViewController == self.sourceViewController || flag) {
                            if (splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible || splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
                                return [self frameOfViewControllerViewInContainerView:navigationController.topViewController];
                            } else {
                                return CGRectZero;
                            }
                        } else {
                            return CGRectZero;
                        }
                    } else if (flag) {
                        if (splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible || splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
                            return [self frameOfViewControllerViewInContainerView:selectedViewController];
                        } else {
                            return CGRectZero;
                        }
                    } else {
                        return CGRectZero;
                    }
                } else if (flag) {
                    return [self frameOfViewControllerViewInContainerView:secondaryViewController];
                } else {
                    return CGRectZero;
                }
            } else {
                return CGRectZero;
            }
        }
    } else if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *) self.presentingViewController;
        if (navigationController.topViewController == self.sourceViewController || flag) {
            return [self frameOfViewControllerViewInContainerView:navigationController.topViewController];
        } else {
            return CGRectZero;
        }
    } else if ([self.presentingViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *) self.presentingViewController;
        UIViewController *selectedViewController = tabBarController.selectedViewController;
        if (selectedViewController == self.sourceViewController) {
            flag = YES;
        }
        if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *) selectedViewController;
            if (navigationController.topViewController == self.sourceViewController || flag) {
                return [self frameOfViewControllerViewInContainerView:navigationController.topViewController];
            } else {
                return CGRectZero;
            }
        } else if (flag) {
            return [self frameOfViewControllerViewInContainerView:selectedViewController];
        } else {
            return CGRectZero;
        }
    } else if (flag) {
        return [self frameOfViewControllerViewInContainerView:self.presentingViewController];
    } else {
        return CGRectZero;
    }
}

- (CGRect)frameOfInnerClipViewInOuterClipView:(BOOL)visible {
    CGRect containerFrame = [self frameOfOuterClipViewInContainerView];
    CGRect frame = CGRectZero;
    CGSize preferredSize = self.presentedViewController.preferredContentSize;
    UIEdgeInsets margins = self.layoutMargins;
    frame.size = CGSizeMake(MIN(containerFrame.size.width - (margins.left + margins.right), preferredSize.width), MIN(containerFrame.size.height - margins.bottom, preferredSize.height));
    frame.origin.x = (containerFrame.size.width - frame.size.width) / 2;
    frame.origin.y = visible ? 0 : -frame.size.height;
    return frame;
}

#pragma mark - Tracking the Transition’s Start and End

- (void)presentationTransitionWillBegin {
    // Background View
    UIView *backgroundView = [[UIView alloc] initWithFrame:[self frameOfOuterClipViewInContainerView]];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.0;
    [self.containerView addSubview:backgroundView];
    _backgroundView = backgroundView;

    // Tap Gesture Recognition View
    UIView *tapGestureRecognitionView = [[UIView alloc] init];
    tapGestureRecognitionView.translatesAutoresizingMaskIntoConstraints = NO;
    tapGestureRecognitionView.backgroundColor = [UIColor clearColor];
    tapGestureRecognitionView.tag = MSTDropDownPresentationControllerTapGestureRecognitionViewTag;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchOverlayView:)];
    gestureRecognizer.delegate = self;
    [tapGestureRecognitionView addGestureRecognizer:gestureRecognizer];
    [self.containerView insertSubview:tapGestureRecognitionView aboveSubview:backgroundView];
    _tapGestureRecognitionView = tapGestureRecognitionView;

    // Top Edge Clip View
    UIView *outerClipView = [[UIView alloc] initWithFrame:[self frameOfOuterClipViewInContainerView]];
    outerClipView.userInteractionEnabled = YES;
    outerClipView.backgroundColor = [UIColor clearColor];
    outerClipView.clipsToBounds = YES;
    outerClipView.tag = MSTDropDownPresentationControllerTopEdgeClipViewTag;
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchOverlayView:)];
    gestureRecognizer.delegate = self;
    [outerClipView addGestureRecognizer:gestureRecognizer];
    [self.containerView insertSubview:outerClipView aboveSubview:tapGestureRecognitionView];
    _outerClipView = outerClipView;

    // Rounded Corner Clip View
    MSTRoundedCornerView *innerClipView = [[MSTRoundedCornerView alloc] initWithFrame:[self frameOfInnerClipViewInOuterClipView:NO]];
    innerClipView.tag = MSTDropDownPresentationControllerRoundedCornerClipViewTag;
    [outerClipView addSubview:innerClipView];
    _innerClipView = innerClipView;

    // Add Constraints
    NSDictionary *views = NSDictionaryOfVariableBindings(tapGestureRecognitionView);
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tapGestureRecognitionView]|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tapGestureRecognitionView]|" options:0 metrics:nil views:views]];

    // Animate in view transition
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        _backgroundView.alpha = self.backgroundAlpha;
        _innerClipView.frame = [self frameOfInnerClipViewInOuterClipView:YES];
    } completion:NULL];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    // Do something when transition ended...
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        _backgroundView.alpha = 0.0;
        _innerClipView.frame = [self frameOfInnerClipViewInOuterClipView:NO];
    } completion:NULL];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [_backgroundView removeFromSuperview];
        [_tapGestureRecognitionView removeFromSuperview];
    }
}

#pragma mark - Adjusting the Size and Layout of the Presentation

- (CGSize)sizeForChildContentContainer:(id <UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    return [self frameOfInnerClipViewInOuterClipView:YES].size;
}

- (CGRect)frameOfPresentedViewInContainerView {
    return [self.containerView convertRect:[self frameOfInnerClipViewInOuterClipView:YES] fromView:_innerClipView];
}

- (void)containerViewWillLayoutSubviews {

}

- (void)containerViewDidLayoutSubviews {

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    UISplitViewController *splitViewController = [self.presentingViewController isKindOfClass:[UISplitViewController class]] ? (UISplitViewController *)self.presentingViewController : nil;
    BOOL hidesWhileTransition = splitViewController != nil && !((UISplitViewController *)self.presentingViewController).isCollapsed;
    _backgroundView.hidden = _outerClipView.hidden = hidesWhileTransition;
    BOOL __block dismissesAfterTransition = NO;
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        CGRect outerClipViewFrame = [self frameOfOuterClipViewInContainerView];
        CGRect innerClipViewFrame = [self frameOfInnerClipViewInOuterClipView:YES];
        if (CGRectEqualToRect(outerClipViewFrame, CGRectZero)) {
            dismissesAfterTransition = YES;
        }
        _backgroundView.frame = outerClipViewFrame;
        _outerClipView.frame = outerClipViewFrame;
        _innerClipView.frame = innerClipViewFrame;
        self.presentedView.frame = CGRectMake(0, 0, innerClipViewFrame.size.width, innerClipViewFrame.size.height);
    } completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        _backgroundView.hidden = _outerClipView.hidden = NO;
        if (dismissesAfterTransition) {
            [self.presentingViewController dismissViewControllerAnimated:NO completion:NULL];
        }
    }];
}

#pragma mark - Responding to Dismissing Tap Gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Ignore content-view-through touch
    return touch.view == _tapGestureRecognitionView || touch.view == _outerClipView;
}

- (void)didTouchOverlayView:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.dismissesOnBackgroundTap) {
        [self.presentedViewController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end

static const NSTimeInterval MSTDropDownAnimationControllerDefaultAnimationDuration = 0.33;

@implementation MSTDropDownAnimationController

#pragma mark - Reporting Transition Duration

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return MSTDropDownAnimationControllerDefaultAnimationDuration;
}

#pragma mark - Performing a Transition

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (fromViewController.presentedViewController == toViewController) {
        [self animatePresentTransition:transitionContext];
    } else {
        [self animateDismissalTransition:transitionContext];
    }
}

- (void)animatePresentTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *presentedController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;
    UIView *topEdgeClipView = [transitionContext.containerView viewWithTag:MSTDropDownPresentationControllerTopEdgeClipViewTag];
    if (topEdgeClipView) {
        UIView *roundedCornerClipView = [topEdgeClipView viewWithTag:MSTDropDownPresentationControllerRoundedCornerClipViewTag];
        if (roundedCornerClipView) {
            containerView = roundedCornerClipView;
        }
    }
    [containerView addSubview:presentedController.view];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:0 animations:^{
        // Perform Presentation Animation...
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateDismissalTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *presentedController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:0 animations:^{
        // Perform Dismissal Animation...
    } completion:^(BOOL finished) {
        [presentedController.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end
