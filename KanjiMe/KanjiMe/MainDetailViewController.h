//
//  MainDetailViewController.h
//  KanjiMe
//
//  Created by Lion User on 5/25/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (void)setDetail:(id)newDetailItem withCell:(id)cell;


@end
