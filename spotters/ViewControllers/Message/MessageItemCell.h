//
//  MessageItemCell.h
//  smallplayerbigplay
//
//  Created by Techsviewer on 7/20/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "CircleImageView.h"

@interface MessageItemCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet CircleImageView *img_thumb;
@property (weak, nonatomic) IBOutlet UILabel *lbl_username;
@property (weak, nonatomic) IBOutlet UILabel *lbl_lastMsg;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;

@end
