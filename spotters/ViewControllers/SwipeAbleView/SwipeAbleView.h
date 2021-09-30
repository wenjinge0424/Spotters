//
//  SwipeAbleView.h
//  spotters
//
//  Created by Techsviewer on 3/18/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableView.h"

@protocol SwipeAbleViewDelegate <NSObject>

-(void)selectCardSwipedLeft:(UIView *)card;
-(void)selectCardSwipedRight:(UIView *)card;

@end


NS_ASSUME_NONNULL_BEGIN

@interface SwipeAbleView : UIView<DraggableViewDelegate>
@property (retain,nonatomic)id<SwipeAbleViewDelegate>delegate;
@property (retain,nonatomic)NSMutableArray* allCards;
-(void)loadCards;
- (UIView*) currentLoadingView;
@end

NS_ASSUME_NONNULL_END
