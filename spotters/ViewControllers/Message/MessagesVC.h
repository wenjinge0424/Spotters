//
//  MessagesVC.h
//  Spotters
//
//  Created by developer on 6/20/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MessagesVC : BaseViewController
+ (MessagesVC *)getInstance;
- (void) getAllGroups;
@end
