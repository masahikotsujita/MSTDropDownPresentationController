//
//  MSTDropDownPresentationController.m
//  MSTDropDownPresentationController
//
//  Created by Masahiko Tsujita on 14/11/01.
//  Copyright (c) 2014 Masahiko Tsujita. All rights reserved.
//

#import "MSTDropDownPresentationController.h"
#import <objc/runtime.h>

static const NSInteger MSTDropDownPresentationControllerTapGestureRecognitionViewTag = 101;
static const NSInteger MSTDropDownPresentationControllerTopEdgeClipViewTag = 102;
static const NSInteger MSTDropDownPresentationControllerRoundedCornerClipViewTag = 103;

@interface UIViewController ()

@property (strong, nonatomic, readwrite) MSTDropDownPresentationController *mst_dropDownPresentationController;

@end

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

#pragma mark - Customizing Presentation Controller Appearances

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    _innerClipView.cornerRadius = cornerRadius;
}

- (void)setLayoutMargins:(UIEdgeInsets)layoutMargins {
    _layoutMargins = layoutMargins;
    CGRect frame = [self frameOfInnerClipViewInOuterClipView:YES];
    _innerClipView.frame = frame;
    self.presentedView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setBackgroundAlpha:(CGFloat)backgroundAlpha {
    _backgroundAlpha = backgroundAlpha;
    _backgroundView.alpha = backgroundAlpha;
}

#pragma mark - Calculating View Frames

- (CGRect)frameOfOuterClipViewInContainerView {
    CGRect (^func)(UIViewController *, BOOL);
    CGRect __weak __block (^weak_func)(UIViewController *, BOOL) = func = ^CGRect (UIViewController *viewController, BOOL flag) {
        if (viewController == self.sourceViewController) {
            flag = YES;
        }
        if ([viewController isKindOfClass:[UISplitViewController class]]) {
            UISplitViewController *splitViewController = (UISplitViewController *) viewController;
            if (splitViewController.isCollapsed) {
                UIViewController *primaryViewController = [splitViewController.viewControllers firstObject];
                return weak_func(primaryViewController, flag);
            } else {
                UIViewController *primaryViewController = [splitViewController.viewControllers firstObject];
                CGRect primaryViewFrame = weak_func(primaryViewController, flag);
                if (!CGRectEqualToRect(primaryViewFrame, CGRectZero)) {
                    if (splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible || splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryOverlay) {
                        return primaryViewFrame;
                    } else {
                        return CGRectZero;
                    }
                } else {
                    UIViewController *secondaryViewController = [splitViewController.viewControllers lastObject];
                    CGRect secondaryViewFrame = weak_func(secondaryViewController, flag);
                    if (splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible || splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
                        return secondaryViewFrame;
                    } else {
                        return CGRectZero;
                    }
                }
            }
        } else if ([viewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarController = (UITabBarController *) viewController;
            UIViewController *selectedViewController = tabBarController.selectedViewController;
            return weak_func(selectedViewController, flag);
        } else if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *) viewController;
            UIViewController *topViewController = navigationController.topViewController;
            return weak_func(topViewController, flag);
        } else {
            if (flag) {
                CGRect viewControllerViewFrame = viewController.view.bounds;
                viewControllerViewFrame.origin.y += viewController.topLayoutGuide.length;
                viewControllerViewFrame.size.height -= viewController.topLayoutGuide.length;
                CGRect frameInContainerView = [self.containerView convertRect:viewControllerViewFrame fromCoordinateSpace:viewController.view];
                return frameInContainerView;
            } else {
                return CGRectZero;
            }
        }
    };
    return func(self.presentingViewController, NO);
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
    innerClipView.cornerRadius = self.cornerRadius;
    innerClipView.tag = MSTDropDownPresentationControllerRoundedCornerClipViewTag;
    [outerClipView addSubview:innerClipView];
    _innerClipView = innerClipView;

    // Add Constraints
    NSDictionary *views = NSDictionaryOfVariableBindings(tapGestureRecognitionView);
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tapGestureRecognitionView]|" options:0 metrics:nil views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tapGestureRecognitionView]|" options:0 metrics:nil views:views]];

    //
    self.presentedViewController.mst_dropDownPresentationController = self;

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
        self.presentedViewController.mst_dropDownPresentationController = nil;
    }
}

#pragma mark - Adjusting the Size and Layout of the Presentation

- (CGSize)sizeForChildContentContainer:(id <UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    return [self frameOfInnerClipViewInOuterClipView:YES].size;
}

- (CGRect)frameOfPresentedViewInContainerView {
    return [self.containerView convertRect:[self frameOfInnerClipViewInOuterClipView:YES] fromView:_innerClipView];
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
    presentedController.view.frame = CGRectMake(0, 0, containerView.bounds.size.width, containerView.bounds.size.height);
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

static void *MSTDropDownTransitioningDelegateAssociationKey = &MSTDropDownTransitioningDelegateAssociationKey;
static void *UIViewControllerMSTDropDownPresentationControllerAssociationKey = &UIViewControllerMSTDropDownPresentationControllerAssociationKey;

@interface MSTDropDownTransitioningDelegateObject : NSObject <UIViewControllerTransitioningDelegate>

@end

@implementation MSTDropDownTransitioningDelegateObject

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    if (!presenting) {
        presenting = source;
    }
    return [[MSTDropDownPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[MSTDropDownAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[MSTDropDownAnimationController alloc] init];
}

@end

@implementation UIViewController (MSTDropDownPresentationControllerSupport)

- (id <UIViewControllerTransitioningDelegate>)mst_dropDownTransitioningDelegate {
    id object = objc_getAssociatedObject(self, MSTDropDownTransitioningDelegateAssociationKey);
    if (!object) {
        object = [[MSTDropDownTransitioningDelegateObject alloc] init];
        objc_setAssociatedObject(self, MSTDropDownTransitioningDelegateAssociationKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return object;
}

- (MSTDropDownPresentationController *)mst_dropDownPresentationController {
    return objc_getAssociatedObject(self, UIViewControllerMSTDropDownPresentationControllerAssociationKey);
}

- (void)setMst_dropDownPresentationController:(MSTDropDownPresentationController *)mst_dropDownPresentationController {
    objc_setAssociatedObject(self, UIViewControllerMSTDropDownPresentationControllerAssociationKey, mst_dropDownPresentationController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end

@implementation MSTDropDownStoryboardSegue

- (void)perform {
    if (self.unwinding) {
        [self.destinationViewController dismissViewControllerAnimated:YES completion:NULL];
    } else {
        ((UIViewController *)self.destinationViewController).modalPresentationStyle = UIModalPresentationCustom;
        ((UIViewController *)self.destinationViewController).transitioningDelegate = ((UIViewController *)self.sourceViewController).mst_dropDownTransitioningDelegate;
        [self.sourceViewController presentViewController:self.destinationViewController animated:YES completion:NULL];
    }
}

@end
