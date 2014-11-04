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
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = (NSString *)self.detailItem;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
