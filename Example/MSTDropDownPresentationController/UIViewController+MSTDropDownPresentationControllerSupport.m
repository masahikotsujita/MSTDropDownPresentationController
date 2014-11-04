//
//  UIViewController+MSTDropDownPresentationControllerSupport.m
//  MSTDropDownPresentationController
//
//  Created by Masahiko Tsujita on 2014/11/04.
//  Copyright (c) 2014年 Masahiko Tsujita. All rights reserved.
//

#import "UIViewController+MSTDropDownPresentationControllerSupport.h"
#import <objc/runtime.h>
#import <MSTDropDownPresentationController/MSTDropDownPresentationController.h>

static void *MSTDropDownTransitioningDelgateAssociationKey = &MSTDropDownTransitioningDelgateAssociationKey;

@interface MSTDropDownTransitioningDelegateImpl : NSObject <UIViewControllerTransitioningDelegate>

@end

@implementation MSTDropDownTransitioningDelegateImpl

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
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
    id object = objc_getAssociatedObject(self, MSTDropDownTransitioningDelgateAssociationKey);
    if (!object) {
        object = [[MSTDropDownTransitioningDelegateImpl alloc] init];
        objc_setAssociatedObject(self, MSTDropDownTransitioningDelgateAssociationKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return object;
}

@end
