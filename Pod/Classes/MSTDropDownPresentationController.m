//
//  MSTDropDownPresentationController.m
//  MSTDropDownPresentationController
//
//  Created by Masahiko Tsujita on 14/11/01.
//  Copyright (c) 2014 Masahiko Tsujita. All rights reserved.
//

#import "MSTDropDownPresentationController.h"

static const NSInteger MSTDropDownPresentationControllerOverlayViewTag = 101;
static const NSInteger MSTDropDownPresentationControllerPresentedViewMaskViewTag = 102;

@implementation MSTDropDownPresentationController {
    UIView *_backgroundView;
    UIView *_overlayView;
    UIView *_presentedViewMaskView;
}

#pragma mark - Initializing MSTDropDownPresentationController Object

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        self.cornerRadius = 15.0f;
        self.layoutMargins = UIEdgeInsetsMake(8, 8, 8, 8);
        self.dismissesOnBackgroundTap = YES;
        self.backgroundAlpha = 0.5;
    }
    return self;
}

#pragma mark - Getting Total Height of Status Bar and Navigation Bar

- (CGFloat)contentViewPresentationOffsetY {
    if ([self.presentingViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *viewController = ((UITabBarController *)self.presentingViewController).selectedViewController;
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            return ((UINavigationController *) viewController).topViewController.topLayoutGuide.length;
        } else {
            return 0;
        }
    } else if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController *) self.presentingViewController).topViewController.topLayoutGuide.length;
    } else {
        return 0;
    }
}

#pragma mark - Tracking the Transition’s Start and End

- (void)presentationTransitionWillBegin {
    CGFloat barHeight = [self contentViewPresentationOffsetY];
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, barHeight, self.containerView.bounds.size.width, self.containerView.bounds.size.height - barHeight)];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.0;
    [self.containerView addSubview:_backgroundView];

    _overlayView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    _overlayView.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, barHeight, self.containerView.bounds.size.width, self.containerView.bounds.size.height - barHeight)];
    _overlayView.maskView.backgroundColor = [UIColor blackColor];
    _overlayView.backgroundColor = [UIColor clearColor];
    _overlayView.tag = MSTDropDownPresentationControllerOverlayViewTag;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchOverlayView:)];
    gestureRecognizer.delegate = self;
    [_overlayView addGestureRecognizer:gestureRecognizer];
    [self.containerView insertSubview:_overlayView aboveSubview:_backgroundView];

    CGSize contentViewSize = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:self.containerView.bounds.size];
    _presentedViewMaskView = [[UIView alloc] initWithFrame:CGRectMake((self.containerView.bounds.size.width - contentViewSize.width) / 2, barHeight - contentViewSize.height, contentViewSize.width, contentViewSize.height)];
    _presentedViewMaskView.backgroundColor = [UIColor clearColor];
    _presentedViewMaskView.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, -contentViewSize.height, contentViewSize.width, contentViewSize.height * 2)];
    _presentedViewMaskView.maskView.backgroundColor = [UIColor blackColor];
    _presentedViewMaskView.maskView.layer.cornerRadius = self.cornerRadius;
    _presentedViewMaskView.tag = MSTDropDownPresentationControllerPresentedViewMaskViewTag;
    [_overlayView addSubview:_presentedViewMaskView];

    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        _backgroundView.alpha = self.backgroundAlpha;
        CGRect frame = _presentedViewMaskView.frame;
        frame.origin.y += _presentedViewMaskView.bounds.size.height;
        _presentedViewMaskView.frame = frame;
    } completion:NULL];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    // Do something when transition ended...
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        _backgroundView.alpha = 0.0;
        CGRect frame = _presentedViewMaskView.frame;
        frame.origin.y -= _presentedViewMaskView.bounds.size.height;
        _presentedViewMaskView.frame = frame;
    } completion:NULL];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [_backgroundView removeFromSuperview];
        [_overlayView removeFromSuperview];
    }
}

#pragma mark - Responding to Changes in Child View Controllers

- (CGSize)sizeForChildContentContainer:(id <UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    CGFloat barHeight = [self contentViewPresentationOffsetY];
    UIEdgeInsets margins = self.layoutMargins;
    CGSize size = CGSizeMake(MIN(parentSize.width - (margins.left + margins.right), container.preferredContentSize.width), MIN(parentSize.height - (barHeight + margins.bottom), container.preferredContentSize.height));
    return size;
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGFloat barHeight = [self contentViewPresentationOffsetY];
    CGSize size = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:self.presentingViewController.view.bounds.size];
    CGRect frame = CGRectMake((self.containerView.bounds.size.width - size.width) / 2, barHeight, size.width, size.height);
    return frame;
}

- (void)containerViewWillLayoutSubviews {
    CGFloat barHeight = [self contentViewPresentationOffsetY];
    _backgroundView.frame = CGRectMake(0, barHeight, self.containerView.bounds.size.width, self.containerView.bounds.size.height - barHeight);
    _overlayView.frame = self.containerView.bounds;
    _overlayView.maskView.frame = CGRectMake(0, barHeight, self.containerView.bounds.size.width, self.containerView.bounds.size.height - barHeight);
    CGRect presentedViewFrame = self.frameOfPresentedViewInContainerView;
    _presentedViewMaskView.frame = presentedViewFrame;
    _presentedViewMaskView.maskView.frame = CGRectMake(0, -presentedViewFrame.size.height, presentedViewFrame.size.width, presentedViewFrame.size.height * 2);
    self.presentedView.frame = CGRectMake(0, 0, presentedViewFrame.size.width, presentedViewFrame.size.height);
}

- (void)containerViewDidLayoutSubviews {
    // Do something when subviews layout ended...
}

#pragma mark - Responding to Dismissing Tap Gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Ignore content-view-through touch
    return touch.view == _overlayView;
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
    UIView *overlayView = [transitionContext.containerView viewWithTag:MSTDropDownPresentationControllerOverlayViewTag];
    if (overlayView) {
        UIView *maskView = [overlayView viewWithTag:MSTDropDownPresentationControllerPresentedViewMaskViewTag];
        if (maskView) {
            containerView = maskView;
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
