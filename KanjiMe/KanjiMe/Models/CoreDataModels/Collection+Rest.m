//
//  Collection+Rest.m
//  KanjiMe
//
//  Created by Lion User on 8/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "Collection+Rest.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "RestApiHelpers.h"

#define NAME_TITLE @"Collection.title"
#define NAME_SUBTITLE @"Collection.subtitle"
#define NAME_DESCRIPTION @"Collection.description"
#define NAME_BODY @"Collection.body"
#define NAME_CREATED @"Collection.created"
#define NAME_MODIFIED @"Collection.modified"
#define NAME_ID @"Collection.id"

@implementation Collection (Rest)


+ (NSDate *)getDateTimeFromString:(NSString *)rawDateString
{
    return [self dateStringFromString:rawDateString
                         sourceFormat:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSDate *)dateStringFromString:(NSString *)sourceString
                      sourceFormat:(NSString *)sourceFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:sourceFormat];
    return [dateFormatter dateFromString:sourceString];
}

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
