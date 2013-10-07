//
//  Collection.m
//  KanjiMe
//
//  Created by Lion User on 8/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "Collection.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "RestApiHelpers.h"

@implementation Collection

@dynamic body;
@dynamic created;
@dynamic extraTitle;
@dynamic favorite;
@dynamic modified;
@dynamic subtitle;
@dynamic title;
@dynamic collectionId;


- (NSString *)getCommonDescriptor
{
    return [NSString stringWithFormat:@"Check it out! The kanji for %@ is %@, Find yours at %@", self.title, self.subtitle, WEB_ENDPOINT_URL];
    
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


- (void)shareToTwitter:(UIViewController *)mainView
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[self getCommonDescriptor]];
        
        [tweetSheet addImage:[UIImage imageNamed:@"iTunesArtwork.png"]];
        [mainView presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        [RestApiHelpers setAlertMessage:@"You can't send a tweet right now, make sure"
         "your device has an internet connection and you have"
         "at least one Twitter account setup"
                              withTitle:@"Sorry"];
    }
}



@end
