//
//  NamesTableViewController.m
//  KanjiMe
//
//  Created by Lion User on 8/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "NamesTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import "MainAppDelegate.h"
#import "RestApiFetcher.h"
#import "RestApiConstant.h"
#import "StylishCellViewCell.h"
#import "Collection+Rest.h"
#import "SearchCollectionTableViewController.h"
#import "MBProgressHUD.h"


static NSString *cellIdentifier = @"NameRow";
static NSString *searchCellIdentifier = @"SearchNameRow";

@interface NamesTableViewController ()
@property (strong, nonatomic) NSFetchedResultsController *filteredNames;
@property BOOL setView;

@end

@implementation NamesTableViewController
@synthesize filteredNames, setView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    [self setStyle];
    
    /*
     UIViewController *shareViewController = [[UIViewController alloc] init];
     shareViewController.tabBarItem.title = @"Share";
     shareViewController.tabBarItem.image = [UIImage imageNamed:@"search.png"];
     
     NSMutableArray * vcs = [NSMutableArray
     arrayWithArray:[self.tabBarController viewControllers]];
     [vcs addObject:shareViewController];
     [self.tabBarController setViewControllers:vcs];
     */
    
    [super viewDidLoad];
    if (!self.managedObjectContext) {
        [self useDocument];
    } else {
        [self refresh];
    }
    
    
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    bannerView_ = [AdMobLoader getNewBannerView:self];
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    
    [self.view addSubview:bannerView_];
    
    CGRect banFrame = bannerView_.frame;
    banFrame.origin.y = -50;
    [bannerView_ setFrame:banFrame];
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[AdMobLoader getNewRequest:NO]];
    
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    UIEdgeInsets inset = UIEdgeInsetsMake(50, 0, 0, 0);
    self.tableView.contentInset = inset;
    self.tableView.contentOffset = CGPointMake(0.0f, -50.0f);
}

- (void)refresh
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading...";
    
    [self.tableView reloadData];    
    RestApiFetcher *apiFetcher = [[RestApiFetcher alloc] init];
    [apiFetcher getNames:10000
                startingPoint:1
                      success:^(id jsonData) {
                          hud.labelText = @"Updating...";
                          NSArray *collections = [jsonData valueForKeyPath:@"apiresponse.data.collections"];
                          for (NSDictionary *collection in collections) {
                              [Collection syncCollectionWithCD:collection inManagedObjectContext:self.managedObjectContext];
                          }
                          dispatch_async(dispatch_get_main_queue(), ^{                              
                              [hud hide:YES];
                              [self.refreshControl endRefreshing];
                          });
                      }
                      failure:^(NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [hud hide:YES];
                              [self.refreshControl endRefreshing];
                          });
                      }
     ];
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
    MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.managedObjectContext = _managedObjectContext;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        if([segue.destinationViewController respondsToSelector:@selector(setDetail:withCell:)]){
            Collection *object = nil;
            if([self.searchDisplayController isActive]){
                NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                object = [self.filteredNames objectAtIndexPath:indexPath];
                
            } else {
                if ([sender isKindOfClass:[UITableViewCell class]]) {
                    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
                    object = [self.fetchedResultsController objectAtIndexPath:indexPath];
                }
            }
            if(object){
                [segue.destinationViewController performSelector:@selector(setDetail:withCell:) withObject:object withObject:Nil];
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *uview = nil;
    
//    if(section==0 && tableView != self.searchDisplayController.searchResultsTableView){
//        // Create a view of the standard size at the top of the screen.
//        // Available AdSize constants are explained in GADAdSize.h.
//        if(!bannerView_) {
//            bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
//            
//            // Specify the ad's "unit identifier". This is your AdMob Publisher ID.
//            bannerView_.adUnitID = ADMOB_ID;
//            
//            // Let the runtime know which UIViewController to restore after taking
//            // the user wherever the ad goes and add it to the view hierarchy.
//            bannerView_.rootViewController = self;
//            
//            GADRequest *request = [GADRequest request];
//            //request.testDevices = [NSArray arrayWithObjects:@"2be07610ffc77e998855454a203a7b3a", nil];
//            // Initiate a generic request to load it with an ad.
//            [bannerView_ loadRequest:request];
//        }
//        return bannerView_;
//    }
    return uview;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section==0 && tableView != self.searchDisplayController.searchResultsTableView ? 0.0f : 0.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [[[self.filteredNames sections] objectAtIndex:section] name];
    } else {
        return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [self.filteredNames sectionForSectionIndexTitle:title atIndex:index];
    } else {
        return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    }
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [self.filteredNames sectionIndexTitles];
    } else {
        return [self.fetchedResultsController sectionIndexTitles];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [[self.filteredNames sections] count];
    } else {
        return [[self.fetchedResultsController sections] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [[[self.filteredNames sections] objectAtIndex:section] numberOfObjects];
    } else {
        return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier: @"showDetail" sender: self];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:searchCellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        Collection *collection = [self.filteredNames objectAtIndexPath:indexPath];
        
        cell.textLabel.text = collection.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Kanji: %@",collection.subtitle];
        
        return cell;
        
    } else {
        StylishCellViewCell *cell = (StylishCellViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        Collection *collection = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        cell.titleLabel.text = collection.title;
        cell.subTitleLabel.text = [NSString stringWithFormat:@"Kanji: %@",collection.subtitle];
        cell.like = collection.favorite;
        
        return cell;
    }
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@",searchText];
    [request setPredicate:predicate];
    
    self.filteredNames = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                             managedObjectContext:self.managedObjectContext
                                                               sectionNameKeyPath:nil
                                                                        cacheName:nil];
    NSError *error;
    [self.filteredNames performFetch:&error];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (IBAction)callShareActionSheet:(id)sender {
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Email", nil];
    [shareActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [shareActionSheet showInView:self.tabBarController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [self shareToFacebook];
        }
            break;
        case 1:
        {
            [self shareToTwitter];
        }
            break;
        case 2:
        {
            [self shareByEmail];
        }
            break;
        default:
            break;
    }
}

- (NSString *)getCommonDescriptor
{
    return [NSString stringWithFormat:@"KanjiMe: Find your Japanese name at %@", WEB_ENDPOINT_URL];
    
}

- (void)shareToFacebook
{
    [FBDialogs presentShareDialogWithLink:[NSURL URLWithString:WEB_ENDPOINT_URL]
                                     name:@"KanjiMe! iOS"
                                  caption:@"KanjiMe!"
                              description:[self getCommonDescriptor]
                                  picture:[NSURL URLWithString:@"http://kanjime.learnjapanese123.com/img/iTunesArtwork.png"]
                              clientState:nil
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                      if(error) {
                                          NSLog(@"Error: %@", error.description);
                                      } else {
                                          NSLog(@"Success!");
                                      }
                                  }];
    
}

- (void)shareToTwitter
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[self getCommonDescriptor]];
        [tweetSheet addImage:[UIImage imageNamed:@"iTunesArtwork.png"]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure"
                                  "your device has an internet connection and you have"
                                  "at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)shareByEmail
{
    
    // Email Subject
    NSString *emailTitle = @"KanjiMe! iOS";
    // Email Content
    NSString *messageBody = [self getCommonDescriptor];
    // To address
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    MBProgressHUD *emailMessageWindow = [MBProgressHUD showHUDAddedTo:self.view
                                                             animated:YES];
    emailMessageWindow.mode = MBProgressHUDModeIndeterminate;
    emailMessageWindow.labelText = @"Sending message...";
    switch (result)
    {
        case MFMailComposeResultCancelled:
            emailMessageWindow.labelText = @"Cancelled";
            break;
        case MFMailComposeResultSaved:
            emailMessageWindow.labelText = @"Saved";
            break;
        case MFMailComposeResultSent:
            emailMessageWindow.labelText = @"Sent";
            break;
        case MFMailComposeResultFailed:
            emailMessageWindow.labelText = @"Fail";
            break;
        default:
            break;
    }
    // Close the Mail Interface
    
    [self dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSThread sleepForTimeInterval:0.5];
            [emailMessageWindow hide:YES];
        });
    }];
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    switch (viewController.tabBarItem.tag) {
        case 3:
        {
            if(appDelegate.collection){
                [appDelegate.collection shareToFacebook];
            } else {
                [self shareToFacebook];
            }
            return NO;
        }
        case 4:
        {
            if(appDelegate.collection){
                [appDelegate.collection shareToTwitter:self];
            } else {
                [self shareToTwitter];
            }
            return NO;
        }
        default:
            return YES;
    }
}



@end
