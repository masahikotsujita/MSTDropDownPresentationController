//
//  MSTDropDownStoryboardSegue.m
//  MSTDropDownPresentationController
//
//  Created by Masahiko Tsujita on 2014/11/04.
//  Copyright (c) 2014年 Masahiko Tsujita. All rights reserved.
//

#import "MSTDropDownStoryboardSegue.h"
#import <MSTDropDownPresentationController/MSTDropDownPresentationController.h>
#import "UIViewController+MSTDropDownPresentationControllerSupport.h"

@implementation MSTDropDownStoryboardSegue

- (void)perform {
    ((UIViewController *)self.destinationViewController).modalPresentationStyle = UIModalPresentationCustom;
    ((UIViewController *)self.destinationViewController).transitioningDelegate = ((UIViewController *)self.sourceViewController).mst_dropDownTransitioningDelegate;
    [self.sourceViewController presentViewController:self.destinationViewController animated:YES completion:NULL];
}

@end
