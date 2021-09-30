//
//  SwipeAbleView.m
//  spotters
//
//  Created by Techsviewer on 3/18/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SwipeAbleView.h"

@interface SwipeAbleView ()
{
    int cardsLoadedIndex;
}
@end

@implementation SwipeAbleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        self.allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
    }
    return self;
}
-(void)loadCards
{
    for(UIView * subView in self.subviews){
        [subView removeFromSuperview];
    }
    
    for (int i = 0; i<[_allCards count]; i++) {
        if (i>0) {
            [self insertSubview:[_allCards objectAtIndex:i] belowSubview:[_allCards objectAtIndex:i-1]];
        } else {
            [self addSubview:[_allCards objectAtIndex:i]];
        }
        UIView * currentView = [_allCards objectAtIndex:i];
        if([currentView isKindOfClass:[DraggableView class]]){
            [(DraggableView*)currentView initializeForLoad];
            ((DraggableView*)currentView).delegate = self;
        }
    }
}
-(void)cardSwipedLeft:(UIView *)card
{
    [self.delegate selectCardSwipedLeft:card];
    cardsLoadedIndex ++;
}
-(void)cardSwipedRight:(UIView *)card
{
    [self.delegate selectCardSwipedRight:card];
    cardsLoadedIndex ++;
}
- (UIView*) currentLoadingView
{
    if(self.allCards.count > cardsLoadedIndex){
        return [self.allCards objectAtIndex:cardsLoadedIndex];
    }
    return nil;
}
@end
