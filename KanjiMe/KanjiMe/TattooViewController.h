//
//  TattooViewController.h
//  KanjiMe
//
//  Created by Juan Tabares on 10/4/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"

@interface TattooViewController : UIViewController <UITextFieldDelegate, PayPalPaymentDelegate, UIAlertViewDelegate>
- (void)setSelection:(id)selection;
@end
