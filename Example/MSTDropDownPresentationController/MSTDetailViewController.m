//
//  MSTDetailViewController.m
//  MSTDropDownPresentationController
//
//  Created by Masahiko Tsujita on 2014/11/04.
//  Copyright (c) 2014年 Masahiko Tsujita. All rights reserved.
//

#import "MSTDetailViewController.h"

@implementation MSTDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        [self configureView];
    }
}

- (void)configureView {
    if (self.detailItem) {
        self.detailDescriptionLabel.text = (NSString *)self.detailItem;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (IBAction)didLongPressTitleLabel:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self performSegueWithIdentifier:@"DropDownSegue" sender:sender];
    }
}

@end
