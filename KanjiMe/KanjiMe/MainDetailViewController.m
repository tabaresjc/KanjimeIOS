//
//  MainDetailViewController.m
//  KanjiMe
//
//  Created by Lion User on 5/25/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "MainDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "StylishCellViewCell.h"
#import "Collection.h"
#import "RestApiFetcher.h"


@interface MainDetailViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *likeButton;
@property (strong,nonatomic) StylishCellViewCell *cellOrigin;
@property (strong, nonatomic) Collection *collection;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
- (void)configureView;

@end

@implementation MainDetailViewController
@synthesize cellOrigin, likeButton, spinner;

- (void)setStyle
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self.view setBackgroundColor:MAIN_BACK_COLOR];
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self.webView setOpaque:NO];
}

#pragma mark - Managing the detail item

- (void)setDetail:(id)newDetailItem withCell:(id)cell
{
    if([cell isKindOfClass:[StylishCellViewCell class]]){
        self.cellOrigin = (StylishCellViewCell *)cell;
    }else{
        self.cellOrigin = nil;
    }
    self.collection = (Collection *)newDetailItem;
}

- (void)configureView
{
    //Update the user interface for the detail item.
    if (self.collection) {
        [self.spinner startAnimating];
        NSString *postId = [NSString stringWithString:self.collection.collectionId];
        
        dispatch_queue_t dataFormatter = dispatch_queue_create("Data Formatter", NULL);
        dispatch_async(dataFormatter, ^{
            //[NSThread sleepForTimeInterval:2.0];
            NSString *htmlBody = [RestApiHelpers getHtmlArticle:self.collection.body withTitle:self.collection.title withSubtitle:self.collection.subtitle withDescription:self.collection.extraTitle];
            NSString *htmlstring = [RestApiHelpers getStandardHtmlPage:htmlBody];
            if([self.collection.collectionId isEqualToString:postId]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setLikeArticle:self.collection.favorite];
                    [self.webView loadHTMLString:htmlstring baseURL:[RestApiHelpers getUrlToWebServerFolder]];
                    [self.spinner stopAnimating];
                });
            }
        });
    }    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

- (IBAction)likeArticle:(UIButton *)sender {
    self.collection.favorite = !self.collection.favorite;
    [self setLikeArticle:self.collection.favorite];
}

-(void)setLikeArticle:(BOOL)value {
    if(value){
        [self.likeButton setTintColor:[UIColor orangeColor]];
    }else{
        [self.likeButton setTintColor:[UIColor blackColor]];
    }
}

@end
