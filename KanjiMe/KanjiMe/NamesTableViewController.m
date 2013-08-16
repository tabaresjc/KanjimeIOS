//
//  NamesTableViewController.m
//  KanjiMe
//
//  Created by Lion User on 8/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "NamesTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RestApiFetcher.h"
#import "StylishCellViewCell.h"
#import "Collection+Rest.h"

@interface NamesTableViewController ()

@end

@implementation NamesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setStyle
{
    [self.view setBackgroundColor:MAIN_BACK_COLOR];
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];    
    RestApiFetcher *apiFetcher = [[RestApiFetcher alloc] init];
    [apiFetcher getNames:10000
                startingPoint:1
                      success:^(id jsonData) {
                          NSArray *collections = [jsonData valueForKeyPath:@"apiresponse.data.collections"];
                          for (NSDictionary *collection in collections) {
                              [Collection syncCollectionWithCD:collection inManagedObjectContext:self.managedObjectContext];
                          }
                          dispatch_async(dispatch_get_main_queue(), ^{                              
                              [self.refreshControl endRefreshing];
                          });
                      }
                      failure:^(NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [self.refreshControl endRefreshing];
                          });
                      }
     ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setStyle];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) {
        [self useDocument];
    }
}

- (void)useDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"MainDocument"];
    
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              self.managedObjectContext = document.managedObjectContext;
              [self refresh];
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            self.managedObjectContext = document.managedObjectContext;
            [self refresh];
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = nil;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"showDetail"]) {
            Collection *collection = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setDetail:withCell:)]) {
                [segue.destinationViewController performSelector:@selector(setDetail:withCell:)
                                                      withObject:collection
                                                      withObject:nil];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StylishCellViewCell *cell = (StylishCellViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PostRow" forIndexPath:indexPath];
    Collection *collection = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = collection.title;
    cell.subTitleLabel.text = [NSString stringWithFormat:@"Kanji: %@",collection.subtitle];
    cell.like = collection.favorite;
    
    return cell;
}

@end
