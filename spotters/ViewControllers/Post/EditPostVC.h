//
//  EditPostVC.h
//  Spotters
//
//  Created by developer on 6/19/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface EditPostVC : BaseViewController
@property (atomic) NSInteger mType;
@property (nonatomic, retain) NSMutableArray *chosenImages;
@property (nonatomic, retain) NSMutableArray *chosenVideos;
@property (nonatomic, retain) NSMutableArray *chosenImgThumbs;
@property (nonatomic, retain) PFObject *postObj;
@end
