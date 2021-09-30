//
//  SpotUserView.h
//  spotters
//
//  Created by Techsviewer on 3/18/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableView.h"
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpotUserView : DraggableView
@property (nonatomic, retain) PFUser * currentUser;
@property (weak, nonatomic) IBOutlet UIButton *btn_action;
@property (nonatomic, retain) UINavigationController * navController;
@end

NS_ASSUME_NONNULL_END
