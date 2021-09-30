//
//  SelectMainGymController.h
//  Spotters
//
//  Created by Techsviewer on 12/16/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SelectMainGymControllerDelegate
- (void)SelectMainGymControllerDelegate_didSelected:(NSMutableArray*)selectedGym :(int)ctrTag;
- (void)SelectMainGymControllerDelegate_didSelectedWithName:(NSString*)gymName :(int)ctrTag;
@end

@interface SelectMainGymController : BaseViewController
@property (atomic) int ctrTag;
@property (atomic) BOOL isAdditionalMode;
@property (nonatomic, retain) id<SelectMainGymControllerDelegate>delegate;
@property (atomic) int ableCount;
@property (nonatomic, retain) NSMutableArray * selectedGYMIds;
@end

NS_ASSUME_NONNULL_END
