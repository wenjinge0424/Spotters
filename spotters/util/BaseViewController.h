//
//  BaseViewController.h
//  spotters
//
//  Created by Techsviewer on 3/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "Config.h"
#import "SCLAlertView.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+Email.h"
#import "MBProgressHUD.h"
#import "IQDropDownTextField.h"
#import "AFNetworking.h"
#import <MessageUI/MessageUI.h>
#import "CircleImageView.h"
#import "BIZPopupViewController.h"
#import "IQTextView.h"
#import "NSString+Case.h"
#import "IQTextView.h"
#import "UITextView+Placeholder.h"
#import "NSDate+NVTimeAgo.h"
#import "NSDate+TimeDifference.h"
#import "NSDate+Escort.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
- (void)onMessages:(PFUser*)owner;
@end

NS_ASSUME_NONNULL_END
