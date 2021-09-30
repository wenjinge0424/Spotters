//
//  NotificationsVC.h
//  Spotters
//
//  Created by developer on 6/20/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface NotificationsVC : BaseViewController
+ (NotificationsVC *)getInstance;
- (void) reloadNotification;
@end
