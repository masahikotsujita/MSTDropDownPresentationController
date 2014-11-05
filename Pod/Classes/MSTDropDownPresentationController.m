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
    UIView *_presentedViewContainerView;
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

#pragma mark - Tracking the Transition’s Start and End

- (void)presentationTransitionWillBegin {
    _backgroundView = [[UIView alloc] initWithFrame:[self frameOfBackgroundViewInContainerView]];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.0;
    [self.containerView addSubview:_backgroundView];

    _overlayView = [[UIView alloc] initWithFrame:[self frameOfOverlayViewInContainerView]];
    _overlayView.maskView = [[UIView alloc] initWithFrame:[self frameOfOverlayViewMaskViewInOverlayView]];
    _overlayView.maskView.backgroundColor = [UIColor blackColor];
    _overlayView.backgroundColor = [UIColor clearColor];
    _overlayView.tag = MSTDropDownPresentationControllerOverlayViewTag;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchOverlayView:)];
    gestureRecognizer.delegate = self;
    [_overlayView addGestureRecognizer:gestureRecognizer];
    [self.containerView insertSubview:_overlayView aboveSubview:_backgroundView];

    CGSize contentViewSize = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:self.containerView.bounds.size];
    _presentedViewContainerView = [[UIView alloc] initWithFrame:[self frameOfPresentedViewContainerViewInOverlayView]];
    _presentedViewContainerView.backgroundColor = [UIColor clearColor];
    _presentedViewContainerView.maskView = [[UIView alloc] initWithFrame:[self frameOfPresentedViewContainerViewInOverlayView]];
    _presentedViewContainerView.maskView.backgroundColor = [UIColor blackColor];
    _presentedViewContainerView.maskView.layer.cornerRadius = self.cornerRadius;
    _presentedViewContainerView.tag = MSTDropDownPresentationControllerPresentedViewMaskViewTag;
    [_overlayView addSubview:_presentedViewContainerView];

    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        _backgroundView.alpha = self.backgroundAlpha;
        CGRect frame = _presentedViewContainerView.frame;
        frame.origin.y += _presentedViewContainerView.bounds.size.height;
        _presentedViewContainerView.frame = frame;
    } completion:NULL];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    // Do something when transition ended...
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        _backgroundView.alpha = 0.0;
        CGRect frame = _presentedViewContainerView.frame;
        frame.origin.y -= _presentedViewContainerView.bounds.size.height;
        _presentedViewContainerView.frame = frame;
    } completion:NULL];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [_backgroundView removeFromSuperview];
        [_overlayView removeFromSuperview];
    }
}

#pragma mark - Adjusting the Size and Layout of the Presentation

- (UINavigationController *)presentingNavigationController {
    UIViewController *viewController = _contextualViewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *) viewController;
    } else {
        return viewController.navigationController;
    }
}

- (CGRect)frameOfBackgroundViewInContainerView {
    UIViewController *viewController = [[self presentingNavigationController] topViewController];
    UIView *view = viewController.view;
    CGRect frame = view.bounds;
    CGFloat barHeight = viewController.topLayoutGuide.length;
    frame.origin.y += barHeight;
    frame.size.height -= barHeight;
    CGRect target = [self.containerView convertRect:frame fromView:view];
    return target;
}

- (CGRect)frameOfOverlayViewInContainerView {
    return self.containerView.bounds;
}

- (CGRect)frameOfOverlayViewMaskViewInOverlayView {
    return [self frameOfBackgroundViewInContainerView];
}

- (CGRect)frameOfPresentedViewContainerViewInOverlayView {
    CGRect containerFrame = [self frameOfOverlayViewMaskViewInOverlayView];
    CGRect frame = CGRectZero;
    CGSize preferredSize = self.presentedViewController.preferredContentSize;
    UIEdgeInsets margins = self.layoutMargins;
    frame.size = CGSizeMake(MIN(containerFrame.size.width - (margins.left + margins.right), preferredSize.width), MIN(containerFrame.size.height - margins.bottom, preferredSize.height));
    frame.origin.y = containerFrame.origin.y;
    frame.origin.x = containerFrame.origin.x + (containerFrame.size.width - frame.size.width) / 2;
    return frame;
}

- (CGRect)frameOfPresentedViewContainerViewMaskViewInPresentedViewContainerView {
    CGRect presentedViewFrame = [self frameOfPresentedViewContainerViewInOverlayView];
    CGRect frame = CGRectMake(0, -presentedViewFrame.size.height, presentedViewFrame.size.width, presentedViewFrame.size.height * 2);
    return frame;
}

- (CGRect)frameOfPresentedViewInPresentedViewContainerView {
    CGRect frame = [self frameOfPresentedViewContainerViewInOverlayView];
    frame.origin = CGPointZero;
    return frame;
}

- (CGSize)sizeForChildContentContainer:(id <UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    return [self frameOfPresentedViewContainerViewInOverlayView].size;
}

- (CGRect)frameOfPresentedViewInContainerView {
    return [self frameOfPresentedViewContainerViewInOverlayView];
}

- (void)containerViewWillLayoutSubviews {
    _backgroundView.frame = [self frameOfBackgroundViewInContainerView];
    _overlayView.frame = [self frameOfOverlayViewInContainerView];
    _overlayView.maskView.frame = [self frameOfOverlayViewMaskViewInOverlayView];
    _presentedViewContainerView.frame = [self frameOfPresentedViewContainerViewInOverlayView];
    _presentedViewContainerView.maskView.frame = [self frameOfPresentedViewContainerViewMaskViewInPresentedViewContainerView];
    self.presentedView.frame = [self frameOfPresentedViewInPresentedViewContainerView];
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
