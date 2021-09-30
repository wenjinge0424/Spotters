//
//  SelectGymCell.h
//  Spotters
//
//  Created by Techsviewer on 12/16/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectGymCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btn_makeAvailable;

@end

NS_ASSUME_NONNULL_END
