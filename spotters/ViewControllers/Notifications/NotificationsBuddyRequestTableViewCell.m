//
//  NotificationsBuddyRequestTableViewCell.m
//  Spotters
//
//  Created by developer on 6/20/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "NotificationsBuddyRequestTableViewCell.h"

@implementation NotificationsBuddyRequestTableViewCell
@synthesize delegate;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)onTapAccept:(id)sender {
    [self.delegate tapAccept:self];
}
- (IBAction)onTapDecline:(id)sender {
    [self.delegate tapDecline:self];
}

@end
