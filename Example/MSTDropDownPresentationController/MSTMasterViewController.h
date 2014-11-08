//
//  MSTMasterViewController.h
//  MSTDropDownPresentationController
//
//  Created by Masahiko Tsujita on 2014/11/01.
//  Copyright (c) 2014年 Masahiko Tsujita. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSTDetailViewController;

@interface MSTMasterViewController : UITableViewController

@property (strong, nonatomic) MSTDetailViewController *detailViewController;

@end
