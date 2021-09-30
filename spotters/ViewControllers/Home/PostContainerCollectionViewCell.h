//
//  PostContainerCollectionViewCell.h
//  spotters
//
//  Created by Techsviewer on 3/20/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PostContainerCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *lbl_noResult;

@end

NS_ASSUME_NONNULL_END
