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

@implementation Collection (Rest)
+ (Collection *)syncCollectionWithCD:(NSDictionary *)collectionDictionary
              inManagedObjectContext:(NSManagedObjectContext *)context{
    Collection *collection = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"collectionId = %@",
                         [collectionDictionary valueForKeyPath:NAME_ID]];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request
                                              error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if (![matches count]) {
        collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection"
                                              inManagedObjectContext:context];
        collection.collectionId = [collectionDictionary valueForKeyPath:NAME_ID];
        collection.title = [collectionDictionary valueForKeyPath:NAME_TITLE];
        collection.subtitle = [collectionDictionary valueForKeyPath:NAME_SUBTITLE];
        collection.extraTitle = [collectionDictionary valueForKeyPath:NAME_DESCRIPTION];
        collection.body = [collectionDictionary valueForKeyPath:NAME_BODY];
        collection.created = [collectionDictionary valueForKeyPath:NAME_CREATED];
        collection.modified = [collectionDictionary valueForKeyPath:NAME_MODIFIED];
        
    } else {
        collection = [matches lastObject];
    }    
    return collection;
}

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
