//
//  UserProfileVC.h
//  Spotters
//
//  Created by developer on 6/20/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface UserProfileVC : BaseViewController
@property (nonatomic, retain) PFUser *user;
@property (atomic) BOOL isFriend;
@end
