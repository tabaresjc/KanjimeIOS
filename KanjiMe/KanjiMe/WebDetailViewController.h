//
//  WebDetailViewController.h
//  KanjiMe
//
//  Created by Lion User on 9/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebDetailViewController : UIViewController <UIWebViewDelegate>

- (void)setUrlToWebView:(NSString *)urlString;

@end
