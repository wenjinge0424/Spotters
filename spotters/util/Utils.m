//
//  Utils.m
//  DailyMessageTruthRevealed
//
//  Created by Techsviewer on 5/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "Utils.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "SCLAlertView.h"
#import "Config.h"
#import "Reachability.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+AFNetworking_UIActivityIndicatorView.h"
#import "NSDate+Escort.h"
#import "SVProgressHUD.h"

#define PARSE_SERVER_BASE                  @"parse.brainyapps.com"
#define PARSE_CDN_BASE                     @"d2zvprcpdficqw.cloudfront.net"
#define PARSE_CDN_DECNUM                   10000

@implementation Util

+ (void) sendPushNotification:(NSString *)email message:(NSString *)message type:(int)type{
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          email, @"email",
                          message, @"alert",
                          @"Increment", @"badge",
                          @"cheering.caf", @"sound",
                          @"", @"data",
                          [NSNumber numberWithInt:type], @"type",
                          nil];
    
    [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
        if (err) {
            NSLog(@"Fail APNS: %@", message);
        } else {
            NSLog(@"Success APNS: %@", message);
        }
    }];
}

+ (NSString *) trim:(NSString *) string {
    NSString *newString = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    return newString;
}
+ (NSString *) checkSpace:(NSString *) string
{
    NSString *newString = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    NSString * newnewString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return newnewString;
}
+ (NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!@#$%^&*()_+=|\{}[]:',./?><;";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", (unichar) [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}
+ (AppDelegate*) appDelegate{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (BOOL) isConnectableInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        return NO;
    } else {
        NSLog(@"There IS internet connection");
        return YES;
    }
}
+ (NSMutableArray *) removeItem:(PFUser*)item in:(NSMutableArray*)array
{
    NSMutableArray * newArray = [NSMutableArray new];
    for(PFUser * obj in array){
        if(![obj.objectId isEqualToString:item.objectId]){
            [newArray addObject:obj];
        }
    }
    return newArray;
}

+ (BOOL) stringContainsInArray:(NSString*)string :(NSArray*)stringArray
{
    for (NSString * substring in stringArray) {
        if([string isEqualToString:substring])
            return YES;
    }
    return NO;
}
+ (BOOL) stringContainNumber:(NSString *) string
{
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    
    if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
        return YES;
    }
    return NO;
}
+ (BOOL) isContainsNumber:(NSString *)password {
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    if ([password rangeOfCharacterFromSet:set].location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (BOOL) isContainsLowerCase:(NSString *)password {
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"^.*(?=.*[a-z])" options:0 error:nil];
    return [regex numberOfMatchesInString:password options:0 range:NSMakeRange(0, [password length])] > 0;
}

+ (BOOL) isContainsUpperCase:(NSString *)password {
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"^.*(?=.*[A-Z])" options:0 error:nil];
    return [regex numberOfMatchesInString:password options:0 range:NSMakeRange(0, [password length])] > 0;
}
+ (BOOL) stringContainLetter:(NSString *) string
{
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ"] invertedSet];
    
    if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (BOOL) stringIsNumber:(NSString*) str
{
    NSScanner * sc = [NSScanner scannerWithString:str];
    if([sc scanFloat:NULL]){
        return [sc isAtEnd];
    }
    return NO;
}

+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    [alert alertIsDismissed:^{
    }];
    alert.customViewColor = [UIColor colorWithRed:2/255.f green:114/255.f blue:202/255.f alpha:1.f];
    
    [alert showInfo:vc title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}
+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message finish:(void (^)(void))finish
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    [alert alertIsDismissed:^{
        if (finish) {
            finish ();
        }
    }];
    [alert setForceHideBlock:^{
        if (finish) {
            finish ();
        }
    }];
    alert.customViewColor = MAIN_COLOR;
    
    [alert showInfo:vc title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}

+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message info:(BOOL)info
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    [alert alertIsDismissed:^{
    }];
    alert.customViewColor = MAIN_COLOR;
    
    if (info)
        [alert showInfo:vc title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
    else
        [alert showQuestion:vc title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}
+ (void) setLoginUserName:(NSString*) userName password:(NSString*) password {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userName forKey:@"userName"];
    [defaults setObject:password forKey:@"password"];
    [defaults synchronize];
    
    // Installation
    if (userName.length > 0 && password.length > 0) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setObject:[PFUser currentUser] forKey:@"owner"];
        [currentInstallation saveInBackground];
    } else {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation removeObjectForKey:@"owner"];
        [currentInstallation saveInBackground];
    }
}
+ (void) setAdminNameAndPassword:(NSString*)adminName :(NSString*)password
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:adminName forKey:@"adminName"];
    [defaults setObject:password forKey:@"adminpassword"];
    [defaults synchronize];
}
+ (NSString *) getAdminName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"adminName"];
    return userName;
}
+ (NSString *) getAdminPassword
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"adminpassword"];
    return userName;
}

+ (NSString*) getLoginUserName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"userName"];
    return userName;
}

+ (NSString*) getLoginUserPassword {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [defaults objectForKey:@"password"];
    return password;
}

+ (void) setImage:(UIImageView *)imgView imgFile:(PFFile *)imgFile withDefault:(UIImage*)image
{
    NSString *imageURL;
    [imgView setImage:image];
    imageURL = [Util downloadedURL:imgFile.url name:nil];
    if (!imageURL) {
        imageURL = [Util urlparseCDN:imgFile.url];
        [Util downloadFile:imageURL name:nil completionBlock:nil];
    }
    
    [imgView setImageWithURL:[NSURL URLWithString:imageURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}
+ (void) setImage:(UIImageView *)imgView imgFile:(PFFile *)imgFile {
    NSString *imageURL;
    [imgView setImage:[UIImage new]];
    imageURL = [Util downloadedURL:imgFile.url name:nil];
    if (!imageURL) {
        imageURL = [Util urlparseCDN:imgFile.url];
        [Util downloadFile:imageURL name:nil completionBlock:nil];
    }
    
    [imgView setImageWithURL:[NSURL URLWithString:imageURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
}

+ (NSString *) downloadedURL:(NSString *)url name:(NSString *) name {
    NSString *fileName = name;
    if (name == nil) {
        fileName = [url lastPathComponent];
    }
    NSString *filePath = [[self getDocumentDirectory] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *localurl = [NSURL fileURLWithPath:filePath];
        return localurl.absoluteString;
    }
    
    return nil;
}
+ (NSString *) getDocumentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/", [paths objectAtIndex:0]]; //create NSString object, that holds our exact path to the documents directory
    return  documentsDirectory;
}
+ (void) downloadFile:(NSString *)url name:(NSString *) name completionBlock:(void (^)(NSURL *downloadurl, NSData *data, NSError *err))completionBlock {
    NSURL *remoteurl = [NSURL URLWithString:url];
    NSString *fileName = name;
    if (name == nil) {
        fileName = [url lastPathComponent];
    }
    NSString *filePath = [[self getDocumentDirectory] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        NSURL *localurl = [NSURL fileURLWithPath:filePath];
        if (completionBlock)
            completionBlock(localurl, data, nil);
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:remoteurl];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Download Error:%@",error.description);
            if (completionBlock)
                completionBlock(nil, data, error);
        } else if (data) {
            [data writeToFile:filePath atomically:YES];
            NSLog(@"File is saved to %@",filePath);
            
            NSURL *localurl = [NSURL fileURLWithPath:filePath];
            if (completionBlock)
                completionBlock(localurl, data, error);
        }
    }];
}
+ (NSString *)urlparseCDN:(NSString *)url
{
    NSArray *paths = [url pathComponents];
    
    if (paths && paths[1]) {
        NSArray *items = [paths[1] componentsSeparatedByString:@":"];
        if (items && [items[0] isEqualToString:PARSE_SERVER_BASE]) {
            NSInteger port = [items[1] integerValue] - PARSE_CDN_DECNUM;
            NSString *cdnURL = [NSString stringWithFormat:@"https://%@/process/%ld", PARSE_CDN_BASE, (long)port];
            
            for (int i=2; i<paths.count; i++) {
                cdnURL = [[cdnURL stringByAppendingString:@"/"] stringByAppendingString:paths[i]];
            }
            
            return cdnURL;
        }
    }
    
    return url;
}
+ (UIImage *)getUploadingImageFromImage:(UIImage *)image {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    
    // dont' resize, use the original image. we can adjust this value of maxResolution like 1024, 768, 640  and more less than current value.
    CGFloat maxResolution = 320.f;
    if (image.size.width < maxResolution) {
        CGSize newSize = CGSizeMake(image.size.width, image.size.height);
        UIGraphicsBeginImageContext(newSize);
        // CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
        // CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, newSize.width, newSize.height));
        [image drawInRect:CGRectMake(0,
                                     0,
                                     image.size.width,
                                     image.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        CGFloat rate = image.size.width / maxResolution;
        CGSize newSize = CGSizeMake(maxResolution, image.size.height / rate);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}
+ (NSString*) convertDateToString:(NSDate*)date
{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    return [formatter stringFromDate:date];
}
+ (NSString*) convertDateTimeToString:(NSDate*)date
{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyyMMddhhmmss"];
    return [formatter stringFromDate:date];
}
+ (BOOL) isPhotoAvaileble {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied || [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted){
        return NO;
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        }];
        return YES;
    } else {
        return YES;
    }
}

+ (BOOL) isCameraAvailable {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
            return NO;
        }
        else if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
            return YES;
        }
        return YES;
    }
    else
        return YES;
}
+ (NSString *) getParseCommentDate:(NSDate *)date
{
    NSDate *updated = date;
    NSDate *now = [NSDate date];
    NSInteger tifn = [updated timeIntervalSinceNow];
    if(tifn < 0) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"d MMM yyyy"];
        NSString *result = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:updated]];
        return result;
    }
    if (tifn < 60) {  // second
        return [NSString stringWithFormat:@"%ld SECONDS AGO", (long)tifn];
    }
    else if (tifn < 60 * 60) { //minute
        if(tifn/ 60 == 1) {
            return [NSString stringWithFormat:@"%ld MINUTE AGO", tifn / 60];
        }
        return [NSString stringWithFormat:@"%ld MINUTES AGO", tifn / 60];
    }
    else if (tifn < 24 * 60 * 60) {
        if(tifn / 60 / 60 == 1) {
            return [NSString stringWithFormat:@"%ld HOUR AGO", tifn / 60 /60];
        }
        return [NSString stringWithFormat:@"%ld HOURS AGO", tifn / 60 /60];
    }
    else if (updated.year == now.year && updated.month == now.month && updated.day == now.day) {
        return @"TODAY";
    }
    else if (updated.year == now.year && updated.month == now.month && updated.day + 1 == now.day) {
        return @"YESTERDAY";
    }
    else if (updated.year == now.year && updated.month == now.month) {
        return [NSString stringWithFormat: @"%ld DAYS AGO",now.day - updated.day];
    }
    else if (updated.year == now.year) {
        if(now.month - updated.month == 1) {
            return [NSString stringWithFormat: @"%ld MONTH AGO",now.month - updated.month];
        }
        return [NSString stringWithFormat: @"%ld MONTHS AGO",now.month - updated.month];
    }
    else {
        if(now.year - updated.year == 1) {
            return [NSString stringWithFormat: @"%ld YEAR AGO",now.year - updated.year];
        }
        return [NSString stringWithFormat: @"%ld YEARS AGO",now.year - updated.year];
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d MMM yyyy"];
    NSString *result = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:updated]];
    return result;
}
+ (void) getGymNameWithId:(NSString *)gymId completionBlock: (void (^)(NSString* gymname))completionBlock
{
    PFUser * me = [PFUser currentUser];
    NSDate * availableDate = me[FIELD_BUY_DATE];
    availableDate = [availableDate dateByAddingDays:30];
    int buyType = [me[FIELD_BUY_ID] intValue];
    if([availableDate timeIntervalSinceNow] < 0){
        buyType = 0;
    }
    NSMutableCharacterSet *carSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"0123456789."];
    BOOL isNumber = [[gymId stringByTrimmingCharactersInSet:carSet] isEqualToString:@""];
    if (isNumber) {
        int index = [gymId intValue];
        if(index <MAINGYM_ARRAY.count){
            completionBlock([MAINGYM_ARRAY objectAtIndex:index]);
        }
    }else{
        if(buyType == 0){
            completionBlock(@"Unknown GYM");
        }else{
            PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_SPECIALGYM];
            [query whereKey:PARSE_FIELD_OBJECT_ID equalTo:gymId];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (error == nil){
                    if(objects.count > 0){
                        PFObject * item = [objects firstObject];
                        completionBlock(item[FIELD_SPECIALGYM_NAME]);
                    }else{
                        completionBlock(@"Unknown GYM");
                    }
                }else{
                    completionBlock(@"Unknown GYM");
                }
            }];
        }
    }
}
+ (void) getGymNamesWithIds:(NSMutableArray *)gymIds completionBlock: (void (^)(NSMutableArray * gymObjects))completionBlock
{
    NSMutableArray * prepareGymObjects = [NSMutableArray new];
    NSMutableArray * unKnownGyms = [NSMutableArray new];
    for(NSString * gymId in gymIds){
        NSMutableCharacterSet *carSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"0123456789."];
        BOOL isNumber = [[gymId stringByTrimmingCharactersInSet:carSet] isEqualToString:@""];
        if(!isNumber){
            [unKnownGyms addObject:gymId];
        }else{
            PFObject * gymItem = [PFObject objectWithClassName:PARSE_TABLE_SPECIALGYM];
            gymItem.objectId = gymId;
            gymItem[FIELD_SPECIALGYM_NAME] = [MAINGYM_ARRAY objectAtIndex:[gymId intValue]];
            [prepareGymObjects addObject:gymItem];
        }
    }
    PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_SPECIALGYM];
    [query whereKey:PARSE_FIELD_OBJECT_ID containedIn:unKnownGyms];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil){
            if(objects.count > 0){
                for(PFObject * item in objects){
                    [prepareGymObjects addObject:item];
                }
            }
            completionBlock(prepareGymObjects);
        }else{
            completionBlock(prepareGymObjects);
        }
    }];
    
}
+ (void) showWaitingMark{
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Please Wait...", nil) maskType:SVProgressHUDMaskTypeGradient];
}

+ (void)hideWaitingMark{
    [SVProgressHUD dismiss];
}

+ (void)findObjectsInBackground:(PFQuery *)query vc:(UIViewController *)vc handler:(CallbackHandler)handler {
    if (![Util isConnectableInternet]) {
        [Util showAlertTitle:vc title:@"Network Error!" message:@"Couldn't connect to the server. Check your network connection."];
        return;
    }
    
    [self showWaitingMark];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self hideWaitingMark];
        
        if (error == nil){
            handler(objects);
        }else{
            [Util showAlertTitle:vc title:@"Error" message:error.localizedDescription];
        }
    }];
}
+ (UIViewController*) getUIViewControllerFromStoryBoard:(NSString*) storyboardIdentifier {
    UIStoryboard *mainSB =  nil;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        mainSB =  [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    } else {
        mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    UIViewController *vc = [mainSB instantiateViewControllerWithIdentifier:storyboardIdentifier];
    return vc;
}
+ (void)setAvatar:(UIImageView *)imgView withUser:(PFUser *)user {
    imgView.image = nil;
    imgView.image = [UIImage imageNamed:@"default_profile.png"];
    [Util setImage:imgView imgFile:[user objectForKey:PARSE_USER_AVATAR]];

}
+ (UIImage *)generateThumbImage:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    float duration = CMTimeGetSeconds([asset duration]);
    
    CGImageRef imgRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0.f, duration) actualTime:NULL error:nil];
    UIImage* thumbnail = [[UIImage alloc] initWithCGImage:imgRef scale:UIViewContentModeScaleAspectFit orientation:UIImageOrientationUp];
    
    return thumbnail;
}
+ (BOOL) stringIsMatched:(NSString*)original searchKey:(NSString*)key
{
    NSString * target = [original lowercaseString];
    NSString * lowKey = [key lowercaseString];
    NSRange rage = [target rangeOfString:lowKey];
    BOOL found = (rage.location != NSNotFound);
    return found;
}
@end
