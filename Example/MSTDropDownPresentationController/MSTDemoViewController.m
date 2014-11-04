//
//  MSTDemoViewController.m
//  MSTDropDownPresentationController
//
//  Created by Masahiko Tsujita on 2014/11/01.
//  Copyright (c) 2014年 Masahiko Tsujita. All rights reserved.
//

#import "MSTDemoViewController.h"
#import "MSTDropDownPresentationController.h"
#import "MSTActionsViewController.h"

@interface MSTDemoViewController ()

@end

@implementation MSTDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)didLongPressTitleView:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        MSTActionsViewController *viewController = [[MSTActionsViewController alloc] initWithNibName:NSStringFromClass([MSTActionsViewController class]) bundle:nil];
        viewController.preferredContentSize = CGSizeMake(300, 400);
        viewController.modalPresentationStyle = UIModalPresentationCustom;
        viewController.transitioningDelegate = self;
        [self presentViewController:viewController animated:YES completion:NULL];
    }
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    MSTDropDownPresentationController *controller = [[MSTDropDownPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    controller.dismissesOnBackgroundTap = YES;
    controller.backgroundAlpha = 0.3;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[MSTDropDownAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[MSTDropDownAnimationController alloc] init];
}

@end
