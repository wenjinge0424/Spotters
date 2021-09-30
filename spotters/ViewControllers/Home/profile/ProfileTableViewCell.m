//
//  ProfileTableViewCell.m
//  Spotters
//
//  Created by developer on 6/19/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "ProfileTableViewCell.h"

@implementation ProfileTableViewCell
@synthesize delegate;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)onTapEditBtn:(id)sender {
    [self.delegate tapEditBtn:self];
}
- (IBAction)onTapPostDetail:(id)sender {
    [self.delegate tapPostDetail:self];
}

@end
