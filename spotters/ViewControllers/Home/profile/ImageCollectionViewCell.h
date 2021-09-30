//
//  ImageCollectionViewCell.h
//  Spotters
//
//  Created by Techsviewer on 8/10/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_thumb;
@property (weak, nonatomic) IBOutlet UIButton *btn_play;

@end
