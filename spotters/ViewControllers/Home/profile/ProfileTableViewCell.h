//
//  ProfileTableViewCell.h
//  Spotters
//
//  Created by developer on 6/19/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ProfileCellDelegate <NSObject>
- (void) tapEditBtn : (UITableViewCell*) cell;
- (void) tapPostDetail : (UITableViewCell*) cell;
@end
@interface ProfileTableViewCell : UITableViewCell
@property (nonatomic, weak) id <ProfileCellDelegate> delegate;
@end
