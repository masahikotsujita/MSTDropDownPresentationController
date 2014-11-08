//
//  MSTDropDownMenuViewController.h
//  MSTDropDownPresentationController
//
//  Created by Masahiko Tsujita on 2014/11/01.
//  Copyright (c) 2014年 Masahiko Tsujita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTDropDownMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
