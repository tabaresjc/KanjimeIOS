//
//  FeedDetailViewController.m
//  KanjiMe
//
//  Created by Lion User on 8/29/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "FeedDetailViewController.h"
#import "RestApiHelpers.h"
#import "Collection.h"
#import "FeedCell4.h"

@interface FeedDetailViewController ()
@property (strong, nonatomic) NSArray *listOfNames;
@property (strong, nonatomic) Collection *collection;
@property (strong, nonatomic) UIFont *fontForTitle;
@property (strong, nonatomic) UIFont *fontForText;
@property (strong, nonatomic) UIFont *fontForRemark;
@end

@implementation FeedDetailViewController

#pragma mark - Managing the detail item

- (UIFont *)fontForTitle
{
    if(!_fontForTitle){
        _fontForTitle = [UIFont fontWithName:@"MyriadPro-BoldCond" size:17.0f];
    }
    return _fontForTitle;
}
- (UIFont *)fontForText
{
    if(!_fontForText){
        _fontForText = [UIFont fontWithName:@"MyriadPro-Cond" size:14.0f];
    }
    return _fontForText;
}
- (UIFont *)fontForRemark
{
    if(!_fontForRemark){
        _fontForRemark = [UIFont fontWithName:@"MyriadPro-BoldIt" size:12.0f];
    }
    return _fontForRemark;
}
- (void)setDetail:(id)newDetailItem withCell:(id)cell
{
    self.collection = (Collection *)newDetailItem;
    NSError *e = [[NSError alloc] init];
    id data = [NSJSONSerialization JSONObjectWithData:[self.collection.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&e];
    
    self.listOfNames = [data valueForKeyPath:@"kanjiList"];
    //NSLog(@"%@",self.listOfNames);
}

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
    
    self.feedTableView.dataSource = self;
    self.feedTableView.backgroundColor = [UIColor colorWithRed:242.0/255 green:235.0/255 blue:241.0/255 alpha:1.0];
    self.feedTableView.separatorColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.listOfNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell4* cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell4"];
    NSDictionary *dataObject = [self.listOfNames objectAtIndex:indexPath.row];
    
    NSDictionary *attributes = [(NSAttributedString *)cell.kanjiLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
    
    // Set new text with extracted attributes
    cell.kanjiLabel.attributedText = [[NSAttributedString alloc] initWithString:[dataObject objectForKey:@"kanji"] attributes:attributes];
    NSString *meaning = [self returnString:[dataObject valueForKey:@"meaning"]];
    NSString *kunyomi = [self returnString:[dataObject valueForKey:@"kunyomi"]];
    NSString *onyomi = [self returnString:[dataObject valueForKey:@"onyomi"]];
    
    NSMutableAttributedString *lineOne = [self getString:@"Meaning:\r" withText:meaning];
    cell.lineOne.attributedText = lineOne;
    NSMutableAttributedString *lineTwo_One = [self getString:@"Kun-Yomi:\r" withText:kunyomi];
    NSMutableAttributedString *lineTwo_Two = [self getString:@"On-Yomi:\r" withText:onyomi];
    
    int count = [kunyomi length] + [onyomi length] + 10 + 9;
    NSString *spacing;
    if(count > 200)
        spacing = @"\r";
    else if(count > 150)
        spacing = @"\r\r";
    else if(count > 100)
        spacing = @"\r\r\r";
    else if(count > 80)
        spacing = @"\r\r\r\r";
    else
        spacing = @"\r\r\r\r\r\r";
    
    NSMutableAttributedString *lineTwo = [[NSMutableAttributedString alloc] initWithString:spacing];
    [lineTwo insertAttributedString:lineTwo_Two atIndex:0];
    [lineTwo insertAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\r\r"] atIndex:0];
    [lineTwo insertAttributedString:lineTwo_One atIndex:0];
    
    cell.lineTwo.attributedText = lineTwo;
    cell.lineTwo.numberOfLines = 0;
    
    
    return cell;
}

- (NSMutableAttributedString *)getString:(NSString *)title withText:(NSString *)text
{
    NSArray *rangeOfFormat = [self getRange:text];
    
    NSString *newText = [text stringByReplacingOccurrencesOfString:@"*" withString:@""];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:newText];
    
    [content addAttribute:NSFontAttributeName value:self.fontForText range:NSMakeRange(0, [newText length])];
    for (id object in rangeOfFormat) {
        NSRange r = [object rangeValue];
        [content addAttribute:NSFontAttributeName value:self.fontForRemark range:r];
    }
    NSMutableAttributedString *mainTitle = [[NSMutableAttributedString alloc] initWithString:title];
    [mainTitle addAttribute:NSFontAttributeName value:self.fontForTitle range:NSMakeRange(0, [title length])];
       
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:content];
    [result insertAttributedString:mainTitle atIndex:0];
    
    return  result;
}

- (NSMutableArray *)getRange:(NSString *)text
{
    
    int pos, len;
    NSRange range;
    NSMutableArray *listData = [[NSMutableArray alloc] init];
    
    NSString *newText = [NSString stringWithString:text];
    
    while (1) {
        range = [newText rangeOfString:@"*"];
        if(range.location == NSNotFound) break;
        pos = range.location;
        newText = [newText stringByReplacingCharactersInRange:range withString:@""];
        range = [newText rangeOfString:@"*"];
        newText = [newText stringByReplacingCharactersInRange:range withString:@""];
        
        len = range.location - pos;
        [listData addObject:[NSValue valueWithRange:NSMakeRange(pos, len)]];
    }
    
    return listData;
}

- (NSString *)returnString:(id)object
{
    NSString *string = [object description];
    int value = [string length];
    return [string substringWithRange:NSMakeRange(0, value)];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
