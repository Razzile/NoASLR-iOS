//
//  ViewController.m
//  NoASLR iOS
//
//  Created by Callum Taylor on 25/10/2014.
//  Copyright (c) 2014 iOSCheaters. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize button, tableView, bar;

#pragma mark Applications

- (NSArray *)applicationList {
    static dispatch_once_t once;
    static NSArray *local;
     dispatch_once(&once, ^{
        local = [NSArray array];
         
         local = [[[[ALApplicationList sharedApplicationList] applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemApplication = FALSE", nil]] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
             return [[[ALApplicationList sharedApplicationList].applications objectForKey:obj1] caseInsensitiveCompare:[[ALApplicationList sharedApplicationList].applications objectForKey:obj2]];}];
         
     });
    return [NSArray arrayWithArray:local];
}

- (IBAction)removeASLRForAll:(id)sender {
    BOOL problems = NO;
    JFMinimalNotification *notification;
    
    for (int i = 0; i < [[self applicationList] count]; i++) {
        NSString *path = [[ALApplicationList sharedApplicationList]
                          valueForKeyPath:@"bundle.executablePath"
                          forDisplayIdentifier:[[self applicationList]
                                                objectAtIndex:i]];
        enum ASLRStatus status = [ASLRTasks removeASLRFor:path];
        NSLog(@"status is %d", status);
        if (status != kSuccess && status != kNoASLR)
        {
            problems = YES;
            break;
        }

    }
    if (problems)
    {
        notification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError
                                                              title:@"Error"
                                                           subTitle:@"An error has occured" dismissalDelay:3.0];
    }
    else
    {
        notification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleSuccess
                                                              title:@"Success"
                                                           subTitle:@"ASLR Removed for all applications" dismissalDelay:3.0];

    }
    
    [self.view addSubview:notification];
    [notification show];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor peterRiverColor]
                                  highlightedColor:[UIColor belizeHoleColor]
                                      cornerRadius:3];
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    self.view.backgroundColor = [UIColor midnightBlueColor];
    
    //[button setFrame:CGRectMake(button.frame.size.width, button.frame.size.height, button.frame.origin.x, (self.view.frame.origin.y+self.view.frame.size.width) - 80)];
    button.buttonColor = [UIColor peterRiverColor];
    button.shadowColor = [UIColor belizeHoleColor];
    button.shadowHeight = 3.0f;
    button.cornerRadius = 6.0f;
    button.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    [self.tableView setBackgroundColor:[UIColor midnightBlueColor]];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self applicationList] count];
}


- (ASLRTableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASLRTableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"ID!" forIndexPath:indexPath];
    NSString *path = [[ALApplicationList sharedApplicationList]
                                             valueForKeyPath:@"bundle.executablePath"
                                             forDisplayIdentifier:[[self applicationList]
                                            objectAtIndex:indexPath.row]];
    NSLog(@"%@",path);
    BOOL hasASLR = [ASLRTasks hasASLR:path];
    NSLog(@"%i", hasASLR);
    cell.backgroundColor = hasASLR ? [UIColor pomegranateColor] : [UIColor emerlandColor];
    ALApplicationIconSize size = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? ALApplicationIconSizeLarge : ALApplicationIconSizeSmall;
    cell.appName.text = [[ALApplicationList sharedApplicationList].applications objectForKey:[[self applicationList] objectAtIndex:indexPath.row]];
    cell.iconView.image = [[ALApplicationList sharedApplicationList] iconOfSize:size forDisplayIdentifier:[[self applicationList] objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [[ALApplicationList sharedApplicationList]
                      valueForKeyPath:@"bundle.executablePath"
                      forDisplayIdentifier:[[self applicationList]
                                            objectAtIndex:indexPath.row]];
    enum ASLRStatus status = [ASLRTasks removeASLRFor:path];
    
    JFMinimalNotification *notification;
    switch (status) {
        case kSuccess:
        {
            notification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleSuccess
                                                                     title:@"Success"
                                                                  subTitle:[NSString stringWithFormat:@"ASLR removed for %@",
                                                                            [[ALApplicationList sharedApplicationList].applications
                                                                             objectForKey:[[self applicationList] objectAtIndex:indexPath.row]]] dismissalDelay:3.0];
            break;

        }
        case kNoASLR:
        {
            notification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleInfo
                                                                  title:@"Info"
                                                               subTitle:[NSString stringWithFormat:@"%@ does not have ASLR",
                                                                         [[ALApplicationList sharedApplicationList].applications
                                                                          objectForKey:[[self applicationList] objectAtIndex:indexPath.row]]] dismissalDelay:3.0];
            break;

        }
        default:
        {
            notification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError
                                                                  title:@"Error"
                                                               subTitle:@"An error has occured" dismissalDelay:3.0];
            break;

        }
    }
    [self.view addSubview:notification];
    [notification show];
    [self.tableView reloadData];
}

- (IBAction)showAbout:(id)sender {
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"About" message:@"NoASLR - Created by Razzile" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.0];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    [alertView show];
}

@end
