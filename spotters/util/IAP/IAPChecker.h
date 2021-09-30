//
//  IAPChecker.h
//  GRiPiT
//
//  Created by Techsviewer on 7/18/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

///anton.yezhov2017@yandex.com
///Wufslwtys1
#define kRemoveAdsProductIdentifier_1month      @"com.brainyapps.spotters.1month"
#define kRemoveAdsProductIdentifier_1year       @"com.brainyapps.spotters.1year"

@protocol IAPCheckerDelegate
- (void)IAPCheckerDelegate_completeFail:(NSString*)errorMsg;
- (void)IAPCheckerDelegate_completeSuccess:(NSString *) idntify;
@end

@interface IAPChecker : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, retain) id<IAPCheckerDelegate>delegate;
- (void) checkIAP:(NSString*)identy;
- (void) restore;
- (NSDictionary *) getStoreReceipt:(BOOL)sandbox;
@end
