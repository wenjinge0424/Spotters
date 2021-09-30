//
//  ChatViewController.h
//  smallplayerbigplay
//
//  Created by Techsviewer on 7/25/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

@interface ChatViewController : BaseViewController
@property (strong, nonatomic) PFUser *toUser;
@property (strong, nonatomic) PFObject *room;
@end
