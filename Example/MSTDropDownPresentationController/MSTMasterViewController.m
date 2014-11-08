//
//  MSTMasterViewController.m
//  MSTDropDownPresentationController
//
//  Created by Masahiko Tsujita on 2014/11/01.
//  Copyright (c) 2014年 Masahiko Tsujita. All rights reserved.
//

#import "MSTMasterViewController.h"
#import "MSTDetailViewController.h"
#import "MSTDropDownMenuViewController.h"

@interface MSTMasterViewController ()

@end

@implementation MSTMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[self.splitViewController.viewControllers lastObject] isKindOfClass:[UINavigationController class]]) {
        self.detailViewController = (MSTDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DropDownSegue"]) {
        
    } else {
        MSTDetailViewController *controller;
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            controller = (MSTDetailViewController *)[segue.destinationViewController topViewController];
        } else {
            controller = segue.destinationViewController;
        }
        controller.detailItem = [[NSDate date] description];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

- (IBAction)didLongPressTitleView:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self performSegueWithIdentifier:@"DropDownSegue" sender:sender];
    }
}

@end
