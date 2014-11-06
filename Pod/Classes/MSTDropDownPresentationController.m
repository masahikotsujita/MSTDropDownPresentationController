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

@implementation MSTDropDownPresentationController {
    UIView *_backgroundView;
    UIView *_tapGestureRecognitionView;
    UIView *_outerClipView;
    MSTRoundedCornerView *_innerClipView;
    UIViewController *_contextualViewController;
}

#pragma mark - Initializing MSTDropDownPresentationController Object

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        self.cornerRadius = 15.0f;
        self.layoutMargins = UIEdgeInsetsMake(8, 8, 8, 8);
        self.dismissesOnBackgroundTap = YES;
        self.backgroundAlpha = 0.5;
        _contextualViewController = presentingViewController;
    }
    return self;
}

#pragma mark - Calculating View Frames

- (CGRect)frameOfOuterClipViewInContainerView {
    if ([self.presentingViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.presentingViewController;
        UIViewController *viewController;
        if (!splitViewController.isCollapsed) {
            UIViewController *primaryViewController = [splitViewController.viewControllers firstObject];
            if ([primaryViewController isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabBarController = (UITabBarController *) primaryViewController;
                UIViewController *selectedViewController = tabBarController.selectedViewController;
                if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
                    UINavigationController *navigationController = (UINavigationController *) selectedViewController;
                    viewController = navigationController.topViewController;
                } else {
                    viewController = selectedViewController;
                }
            } else if ([primaryViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navigationController = (UINavigationController *) primaryViewController;
                viewController = navigationController.topViewController;
            } else {
                viewController = primaryViewController;
            }
            if (viewController == _contextualViewController) {
                // Primary
                if (splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible || splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryOverlay) {
                    CGRect frame = viewController.view.frame;
                    return [viewController.view convertRect:frame toView:self.containerView];
                } else {
                    return CGRectZero;
                }
            } else {
                // Detail
                if (splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible || splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
                    CGRect frame = viewController.view.frame;
                    return [viewController.view convertRect:frame toView:self.containerView];
                } else {
                    return CGRectZero;
                }
            }
        } else {
            viewController = _contextualViewController;
            CGRect frame = viewController.view.frame;
            return [viewController.view convertRect:frame toView:self.containerView];
        }
    } else if ([self.presentingViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *) self.presentingViewController;
        UIViewController *selectedViewController = tabBarController.selectedViewController;
        UIViewController *viewController;
        if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *) selectedViewController;
            viewController = navigationController.topViewController;
        } else {
            viewController = selectedViewController;
        }
        CGRect frame = viewController.view.frame;
        return [viewController.view convertRect:frame toView:self.containerView];
    } else if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *) self.presentingViewController;
        UIViewController *viewController = navigationController.topViewController;
        CGRect frame = viewController.view.frame;
        return [viewController.view convertRect:frame toView:self.containerView];
    } else {
        UIViewController *viewController = self.presentingViewController;
        CGRect frame = viewController.view.frame;
        return [viewController.view convertRect:frame toView:self.containerView];
    }
}

- (CGRect)frameOfInnerClipViewInOuterClipView:(BOOL)visible {
    CGRect containerFrame = [self frameOfOuterClipViewInContainerView];
    CGRect frame = CGRectZero;
    CGSize preferredSize = self.presentedViewController.preferredContentSize;
    UIEdgeInsets margins = self.layoutMargins;
    frame.size = CGSizeMake(MIN(containerFrame.size.width - (margins.left + margins.right), preferredSize.width), MIN(containerFrame.size.height - margins.bottom, preferredSize.height));
    frame.origin.x = containerFrame.origin.x + (containerFrame.size.width - frame.size.width) / 2;
    frame.origin.y = visible ? 0 : -frame.size.height;
    return frame;
}

#pragma mark - Tracking the Transition’s Start and End

- (void)presentationTransitionWillBegin {
    // Background View
    UIView *backgroundView = [[UIView alloc] init];
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
    CGRect outerClipViewFrame = [self frameOfOuterClipViewInContainerView];
    UIView *outerClipView = [[UIView alloc] initWithFrame:outerClipViewFrame];
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

    NSDictionary *views = NSDictionaryOfVariableBindings(backgroundView, tapGestureRecognitionView, outerClipView, innerClipView);
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundView]|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|" options:0 metrics:nil views:views]];
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
    _outerClipView.frame = [self frameOfOuterClipViewInContainerView];
    _innerClipView.frame = [self frameOfInnerClipViewInOuterClipView:YES];
    CGRect presentedViewFrame = [self frameOfInnerClipViewInOuterClipView:YES];
    presentedViewFrame.origin = CGPointZero;
    self.presentedView.frame = presentedViewFrame;
}

- (void)containerViewDidLayoutSubviews {
    // Do something when subviews layout ended...
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    //_outerClipView.alpha = 0;
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        _outerClipView.frame = [self frameOfOuterClipViewInContainerView];
        _innerClipView.frame = [self frameOfInnerClipViewInOuterClipView:YES];
        CGRect presentedViewFrame = [self frameOfInnerClipViewInOuterClipView:YES];
        presentedViewFrame.origin = CGPointZero;
        self.presentedView.frame = presentedViewFrame;
    } completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        //_outerClipView.alpha = 1;
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
