//
//  PurchaseViewController.m
//  Spotters
//
//  Created by Techsviewer on 12/16/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "PurchaseViewController.h"
#import "InappPurchaseViewController.h"

@interface PurchaseViewController ()
{
    PFUser * me;
}
@property (weak, nonatomic) IBOutlet UIButton *btn_lightPackage;
@property (weak, nonatomic) IBOutlet UIButton *btn_heavyPackage;

@end

@implementation PurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchStatus];
}
- (void) fetchStatus
{
    me = [PFUser currentUser];
    if (![Util isConnectableInternet]) {
        [Util showAlertTitle:self title:@"Network Error!" message:@"Couldn't connect to the server. Check your network connection."];
        return;
    }
    [Util showWaitingMark];
    [me fetchInBackgroundWithBlock:^(PFObject * obj, NSError* error){
        me = (PFUser*) obj;
        NSDate * purchasedDate = me[FIELD_BUY_DATE];
        int buyType = [me[FIELD_BUY_ID] intValue];
        if(!purchasedDate){
            self.btn_lightPackage.enabled = YES;
            self.btn_heavyPackage.enabled = YES;
        }else if([purchasedDate timeIntervalSinceNow] + 30*24*3600 < 0){
            self.btn_lightPackage.enabled = YES;
            self.btn_heavyPackage.enabled = YES;
        }else if(buyType == 1){
            self.btn_lightPackage.enabled = NO;
            self.btn_heavyPackage.enabled = YES;
        }else if(buyType == 2){
            self.btn_lightPackage.enabled = YES;
            self.btn_heavyPackage.enabled = NO;
        }
        [Util hideWaitingMark];
    }];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onLightPackage:(id)sender {
    InappPurchaseViewController *vc = (InappPurchaseViewController *)[Util getUIViewControllerFromStoryBoard:@"InappPurchaseViewController"];
    vc.runType = PAGE_TYPE_LIGHT;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onHeavyPackage:(id)sender {
    InappPurchaseViewController *vc = (InappPurchaseViewController *)[Util getUIViewControllerFromStoryBoard:@"InappPurchaseViewController"];
    vc.runType = PAGE_TYPE_HEAVY;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onRestore:(id)sender {
    NSDate * purchasedDate = me[FIELD_BUY_DATE];
    int buyType = [me[FIELD_BUY_ID] intValue];
    if(!purchasedDate){
        [Util showAlertTitle:self title:@"In-App purchase" message:@"You have never purchased any items before."];
    }else{
        NSString * message = @"You'd but item for ";
        if(buyType == 1){
            message = [message stringByAppendingString:@" Light Package"];
        }else if(buyType == 2){
            message = [message stringByAppendingString:@" Heavy Package"];
        }
        message = [message stringByAppendingFormat:@" at %@", [Util convertDateToString:purchasedDate]];
        [Util showAlertTitle:self title:@"Information" message:message finish:^{
        }];
    }
}
@end
