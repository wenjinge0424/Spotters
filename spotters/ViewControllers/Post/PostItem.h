//
//  PostItem.h
//  spotters
//
//  Created by Techsviewer on 3/20/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableView.h"
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface PostItem : DraggableView
@property (nonatomic, retain) PFObject * currentPost;
@property (weak, nonatomic) IBOutlet UIButton *btn_action;
- (void) refreshView;
@end

NS_ASSUME_NONNULL_END
