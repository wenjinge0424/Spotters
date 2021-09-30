//
//  NotificationsBuddyRequestTableViewCell.h
//  Spotters
//
//  Created by developer on 6/20/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BuddyRequestDelegate <NSObject>
- (void) tapAccept : (UITableViewCell*) cell;
- (void) tapDecline : (UITableViewCell*) cell;
@end

@interface NotificationsBuddyRequestTableViewCell : UITableViewCell
@property (nonatomic, weak) id <BuddyRequestDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lbl_noData;
@end
