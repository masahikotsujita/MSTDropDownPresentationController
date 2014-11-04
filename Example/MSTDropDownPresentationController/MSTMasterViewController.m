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
    self.detailViewController = (MSTDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (IBAction)didLongPressTitleView:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self performSegueWithIdentifier:@"DropDownSegue" sender:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DropDownSegue"]) {
        
    } else {
        MSTDetailViewController *controller = (MSTDetailViewController *)[segue.destinationViewController topViewController];
        controller.detailItem = [[NSDate date] description];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

@end
