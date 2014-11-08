//
//  MSTDropDownMenuViewController.m
//  MSTDropDownPresentationController
//
//  Created by Masahiko Tsujita on 2014/11/01.
//  Copyright (c) 2014年 Masahiko Tsujita. All rights reserved.
//

#import "MSTDropDownMenuViewController.h"

@interface MSTDropDownMenuViewController ()

@end

@implementation MSTDropDownMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(320, 400);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = [[UIView alloc] init];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.000 green:0.482 blue:1.000 alpha:0.5];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    cell.textLabel.text = [NSString stringWithFormat:@"Action %02d", indexPath.row + 1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
