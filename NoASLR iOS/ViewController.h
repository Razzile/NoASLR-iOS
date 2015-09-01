//
//  ViewController.h
//  NoASLR iOS
//
//  Created by Callum Taylor on 25/10/2014.
//  Copyright (c) 2014 iOSCheaters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>
#import "ASLRTableViewCell.h"
#import "AppList.h"
#import "ASLRTasks.h"
#import "JFMinimalNotification.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *data;
}
@property (nonatomic, retain) IBOutlet FUIButton *button;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (strong) IBOutlet UINavigationBar *bar;

- (IBAction)removeASLRForAll:(id)sender;
- (IBAction)showAbout:(id)sender;
@end
