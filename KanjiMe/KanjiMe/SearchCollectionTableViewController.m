//
//  SearchCollectionTableViewController.m
//  KanjiMe
//
//  Created by Lion User on 8/17/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "SearchCollectionTableViewController.h"
#import "MainAppDelegate.h"
#import "NamesTableViewController.h"
#import "Collection.h"

@interface SearchCollectionTableViewController ()
@property (strong,nonatomic) CoreDataHandler *coreDataRep;
@end

@implementation SearchCollectionTableViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh
{
    self.fetchedResultsController = [self.coreDataRep getCollectionListByFavorite];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSearchResult"]) {
        if([segue.destinationViewController respondsToSelector:@selector(setDetail:)]){
            Collection *object = nil;
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
                object = [self.fetchedResultsController objectAtIndexPath:indexPath];
            }
            if(object){
                [segue.destinationViewController performSelector:@selector(setDetail:) withObject:object withObject:Nil];
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResult"];
    Collection *collection = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = collection.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Kanji: %@",collection.subtitle];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        Collection *collection = [self.fetchedResultsController objectAtIndexPath:indexPath];
        collection.favorite = NO;
    }
}

- (IBAction)editButton:(UIBarButtonItem *)sender {
    if( self.tableView.editing ){
        [self.tableView setEditing:NO animated:YES];
        sender.title = @"Edit";
    }else{
        [self.tableView setEditing:YES animated:YES];
        sender.title = @"Cancel";
    }
}



@end
