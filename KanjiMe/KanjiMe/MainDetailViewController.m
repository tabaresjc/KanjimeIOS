//
//  MainDetailViewController.m
//  KanjiMe
//
//  Created by Lion User on 5/25/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "MainDetailViewController.h"
#import "StylishCellViewCell.h"
#import "MainAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface MainDetailViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *likeButton;
@property (strong,nonatomic) StylishCellViewCell *cellOrigin;
@property (strong, nonatomic) Name * detailItem;

@property (strong, nonatomic) NSObject * objectDetailItem;
@property (weak,nonatomic) RestApiFetcher* postFetcher;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
- (void)configureView;

@end

@implementation MainDetailViewController
@synthesize cellOrigin, likeButton, detailItem, spinner, postFetcher = _postFetcher, objectDetailItem;

- (void)setStyle
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self.view setBackgroundColor:MAIN_BACK_COLOR];
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self.webView setOpaque:NO];
}

- (RestApiFetcher *)postFetcher
{
    if(!_postFetcher) {
        MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _postFetcher = appDelegate.apiFetcher;
    }
    return _postFetcher;
}

#pragma mark - Managing the detail item

- (void)setDetail:(id)newDetailItem withCell:(id)cell
{
    if([cell isKindOfClass:[StylishCellViewCell class]]){
        self.cellOrigin = (StylishCellViewCell *)cell;
    }else{
        self.cellOrigin = nil;
    }
    self.detailItem = [[Name alloc] initWithBasicObject:newDetailItem];
    self.objectDetailItem = newDetailItem;
}

- (void)configureView
{
    //Update the user interface for the detail item.
    if (self.detailItem) {
        [self.spinner startAnimating];
        NSInteger postId = [self.detailItem postId];
        dispatch_queue_t dataFormatter = dispatch_queue_create("Data Formatter", NULL);
        dispatch_async(dataFormatter, ^{
            //[NSThread sleepForTimeInterval:2.0];
            NSString *htmlBody = [RestApiHelpers getHtmlArticle:self.detailItem.content withTitle:self.detailItem.title withSubtitle:self.detailItem.subTitle];
            NSString *htmlstring = [RestApiHelpers getStandardHtmlPage:htmlBody];
            if(postId == [self.detailItem postId]){
                //[htmlstring writeToURL:[WpUtilities getUrlToWebServerFolder] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setLikeArticle:self.detailItem.markFavorite];                    
                    //[self.webView loadRequest:[NSURLRequest requestWithURL:[WpUtilities getUrlToWebServerFolder]]];
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
    
	// Do any additional setup after loading the view, typically from a nib.
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
    self.detailItem.markFavorite = !self.detailItem.markFavorite;
    if(self.cellOrigin){
        [self.cellOrigin setLike:self.detailItem.markFavorite];        
    }else{
        self.postFetcher.refreshMain = YES;
    }
    
    [self setLikeArticle:self.detailItem.markFavorite];
    
    if( self.detailItem.markFavorite ){
        if([self.postFetcher.favoritePosts indexOfObject:self.objectDetailItem]==NSNotFound){
            [self.postFetcher.favoritePosts addObject:self.objectDetailItem];
        }
    }else {
        if([self.postFetcher.favoritePosts indexOfObject:self.objectDetailItem]!=NSNotFound){
            [self.postFetcher.favoritePosts removeObject:self.objectDetailItem];
        }
    }
}

-(void)setLikeArticle:(BOOL)value {
    if(value){
        [self.likeButton setTintColor:[UIColor orangeColor]];
    }else{
        [self.likeButton setTintColor:[UIColor blackColor]];
    }
}

@end
