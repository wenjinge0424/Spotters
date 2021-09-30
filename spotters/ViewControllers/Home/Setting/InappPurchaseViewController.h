//
//  InappPurchaseViewController.h
//  spotters
//
//  Created by Techsviewer on 3/25/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

#define PAGE_TYPE_LIGHT         0
#define PAGE_TYPE_HEAVY         1

@interface InappPurchaseViewController : BaseViewController
@property (atomic) int runType;
@end

NS_ASSUME_NONNULL_END
