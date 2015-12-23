//
//  MasterViewController.h
//  PinPad
//
//  Created by Melissa on 12/18/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end

