//
//  InappPurchaseViewController.m
//  spotters
//
//  Created by Techsviewer on 3/25/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "InappPurchaseViewController.h"
#import "IAPChecker.h"

@interface InappPurchaseViewController ()<IAPCheckerDelegate>
{
    PFUser * me;
    
    IAPChecker * cheker;
    NSString * purchaseItemId;
}
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_mainTitle;
@property (weak, nonatomic) IBOutlet UITextView *txt_note;

@end

@implementation InappPurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    if(self.runType == PAGE_TYPE_LIGHT){
        self.lbl_title.text = @"Light Weight Package($3.99/Month)";
        self.lbl_mainTitle.text = @"Light Weight";
        self.txt_note.text = @"• Able to select up to 4 gyms to use as primary gym for the search engine, also with the package.\n\n• You are able to choose up to 5 specific addressese to the primary gyms you have selected.";
    }else{
        self.lbl_title.text = @"Heavy Weight Package($11.99/Month)";
        self.lbl_mainTitle.text = @"Heavy Weight";
        self.txt_note.text = @"• Unlimited amount of primary gyms can be selected.\n\n• Up to 10 specific gyms can be selected.\n\n• Top priority in engine searches in the area.";
    }
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
- (IBAction)onSubscribe:(id)sender {
    cheker = [IAPChecker new];
    cheker.delegate = self;
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    if(self.runType == PAGE_TYPE_LIGHT){
        purchaseItemId = kRemoveAdsProductIdentifier_1month;
        [cheker checkIAP:kRemoveAdsProductIdentifier_1month];
    }else{
        purchaseItemId = kRemoveAdsProductIdentifier_1year;
        [cheker checkIAP:kRemoveAdsProductIdentifier_1year];
    }
}
- (void) IAPCheckerDelegate_completeSuccess:(NSString *) idntify
{
    if([purchaseItemId isEqualToString:@""]){
        [SVProgressHUD dismiss];
        return;
    }
    me[FIELD_BUY_DATE] = [NSDate date];
    if([purchaseItemId isEqualToString:kRemoveAdsProductIdentifier_1month]){
        me[FIELD_BUY_ID] = [NSNumber numberWithInt:1];
    }else{
        me[FIELD_BUY_ID] = [NSNumber numberWithInt:2];
    }
    [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    
}
- (void) IAPCheckerDelegate_completeFail:(NSString *)errorMsg
{
    [SVProgressHUD dismiss];
    if(errorMsg.length > 0){
        [Util showAlertTitle:self title:@"Error" message:errorMsg finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}
@end
