//
//  OrdersTableViewController.m
//  KanjiMe
//
//  Created by Juan Tabares on 10/9/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "OrdersTableViewController.h"
#import "MainAppDelegate.h"
#import "Order+Rest.h"

@interface OrdersTableViewController ()
@property (strong,nonatomic) CoreDataHandler *coreDataRep;
@end

@implementation OrdersTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CoreDataHandler *)coreDataRep
{
    if(!_coreDataRep){
        MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _coreDataRep = appDelegate.coreDataHandler;
    }
    return _coreDataRep;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh
{
    self.fetchedResultsController = [self.coreDataRep getListOfOrder];
    NSLog(@"Count: %lu",(unsigned long)[[self.fetchedResultsController sections] count]);
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE, MMMM d, yyyy h:mm a"];
    
    Order *order = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@%1.2f",order.payment_description,order.payment_currency, [order.payment_amount doubleValue]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:order.created_at]];
    return cell;
}

@end
