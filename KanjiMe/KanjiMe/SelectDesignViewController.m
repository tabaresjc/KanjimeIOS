//
//  SelectDesignViewController.m
//  KanjiMe
//
//  Created by Juan Tabares on 10/10/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "SelectDesignViewController.h"
#import "TattooSelectionCell.h"

@interface SelectDesignViewController ()

@end

@implementation SelectDesignViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CheckOutView"]) {
        if([segue.destinationViewController respondsToSelector:@selector(setSelection:)]){
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            [segue.destinationViewController performSelector:@selector(setSelection:)
                                                  withObject:indexPath];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0){
        return @"Please select one design for your tattoo";
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TattooSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DesignCell" forIndexPath:indexPath];
    
    cell.TattooPlaceHolder.image = [UIImage tallImageNamed:[NSString stringWithFormat:@"image%d.png", indexPath.row+1]];
    cell.selectionNumberLabel.text = [NSString stringWithFormat:@"%d", indexPath.row+1];
    
    return cell;
}



@end
