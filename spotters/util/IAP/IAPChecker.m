//
//  IAPChecker.m
//  GRiPiT
//
//  Created by Techsviewer on 7/18/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "IAPChecker.h"
#import "SVProgressHUD.h"



@implementation IAPChecker
- (void) checkIAP:(NSString*)identy
{
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        //If you have more than one in-app purchase, and would like
        //to have the user purchase a different product, simply define
        //another function and replace kRemoveAdsProductIdentifier with
        //the identifier for the other product
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:identy]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
        [self.delegate IAPCheckerDelegate_completeFail:@"User cannot make payments due to parental controls"];
    }
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        [self.delegate IAPCheckerDelegate_completeFail:@"No products available"];
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) restore{
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            
            //if you have more than one in-app purchase product,
            //you restore the correct product for the identifier.
            //For example, you could use
            //if(productID == kRemoveAdsProductIdentifier)
            //to get the product identifier for the
            //restored purchases, you can use
            //
            //NSString *productID = transaction.payment.productIdentifier;
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        //if you have multiple in app purchases in your app,
        //you can get the product identifier of this transaction
        //by using transaction.payment.productIdentifier
        //
        //then, check the identifier against the product IDs
        //that you have defined to check which product the user
        //just purchased
        
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
               [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                if(transaction == [transactions lastObject]){
                    [self.delegate IAPCheckerDelegate_completeSuccess:transaction.transactionIdentifier];
                }
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self.delegate IAPCheckerDelegate_completeSuccess:transaction.transactionIdentifier];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    [self.delegate IAPCheckerDelegate_completeFail:@""];
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}





- (NSString * )getJsonStringFromDictionary:(NSDictionary*)dict
{
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postString = @"";
    if (! postData) {
        NSLog(@"Got an error: %@", error);
        
    } else {
        postString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    }
    return postString;
}
- (NSDictionary *) getStoreReceipt:(BOOL)sandbox {
    
    NSArray *objects;
    NSArray *keys;
    NSDictionary *dictionary;
    
    BOOL gotreceipt = false;
    
    @try {
        
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
        
        NSString *receiptString = [self base64forData:receiptData];
        
        if (receiptString != nil) {
            
            objects = [[NSArray alloc] initWithObjects:receiptString, nil];
            keys = [[NSArray alloc] initWithObjects:@"receipt-data", nil];
            
            
            NSString *password = @"2a235eadfe284971bf93e4bc7da9ff12";
            objects = [[NSArray alloc] initWithObjects:receiptString, password, nil];
            keys = [[NSArray alloc] initWithObjects:@"receipt-data", @"password", nil];
            dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
            
            
            NSString *postData = [self getJsonStringFromDictionary:dictionary];
            
            NSString *urlSting = @"https://buy.itunes.apple.com/verifyReceipt";
            if (sandbox) urlSting = @"https://sandbox.itunes.apple.com/verifyReceipt";
            
            dictionary = [self getJsonDictionaryWithPostFromUrlString:urlSting andDataString:postData];
            
            if ([dictionary objectForKey:@"status"] != nil) {
                
                if ([[dictionary objectForKey:@"status"] intValue] == 0) {
                    
                    gotreceipt = true;
                    
                }
            }
            
            
        }
        
    } @catch (NSException * e) {
        gotreceipt = false;
    }
    
    if (!gotreceipt) {
        objects = [[NSArray alloc] initWithObjects:@"-1", nil];
        keys = [[NSArray alloc] initWithObjects:@"status", nil];
        dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    }
    
    return dictionary;
}



- (NSDictionary *) getJsonDictionaryWithPostFromUrlString:(NSString *)urlString andDataString:(NSString *)dataString {
    NSString *jsonString = [self getStringWithPostFromUrlString:urlString andDataString:dataString];
    NSLog(@"%@", jsonString); // see what the response looks like
    return [self getDictionaryFromJsonString:jsonString];
}


- (NSDictionary *) getDictionaryFromJsonString:(NSString *)jsonstring {
    NSError *jsonError;
    NSDictionary *dictionary = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:[jsonstring dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
    if (jsonError) {
        dictionary = [[NSDictionary alloc] init];
    }
    return dictionary;
}


- (NSString *) getStringWithPostFromUrlString:(NSString *)urlString andDataString:(NSString *)dataString {
    NSString *s = @"";
    @try {
        NSData *postdata = [dataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postlength = [NSString stringWithFormat:@"%d", [postdata length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setTimeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setValue:postlength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postdata];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (data != nil) {
            s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    @catch (NSException *exception) {
        s = @"";
    }
    return s;
}


// from https://stackoverflow.com/questions/2197362/converting-nsdata-to-base64
- (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
