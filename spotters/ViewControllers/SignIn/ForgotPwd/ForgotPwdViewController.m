//
//  ForgotPwdViewController.m
//  spotters
//
//  Created by Techsviewer on 3/15/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "ForgotPwdViewController.h"
#import "Onboard1ViewController.h"

@interface ForgotPwdViewController ()
{
    NSMutableArray *dataArray;
}
@property (weak, nonatomic) IBOutlet UITextField *edt_email;

@end

@implementation ForgotPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.edt_email setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:self.edt_email.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    
    dataArray = [[NSMutableArray alloc] init];
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *user = [array objectAtIndex:i];
                [dataArray addObject:user.username];
            }
        }
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
- (IBAction)onDone:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    self.edt_email.text = [Util trim:self.edt_email.text.lowercaseString];
    NSString *email = self.edt_email.text;
    if (email.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please input email address."];
        return;
    }
    if (![email isEmail]){
        [Util showAlertTitle:self title:@"Error" message:@"Please input valid email address."];
        return;
    }
    if (![self stringArrayContains:email inArray:dataArray]){
        NSString *msg = @"Email entered is not registered. Create an account now?";
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Not now" actionBlock:^(void) {
        }];
        [alert addButton:@"Sign up" actionBlock:^(void) {
            Onboard1ViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Onboard1ViewController"];
            [self.navigationController pushViewController:controller animated:YES];
            
        }];
        [alert showError:@"Sign up" subTitle:msg closeButtonTitle:nil duration:0.0f];
        return;
    }
    [SVProgressHUD showWithStatus:@"please_wait" maskType:SVProgressHUDMaskTypeGradient];
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded,NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [Util showAlertTitle:self
                           title:@"Success"
                         message: @"We've sent a password reset link to your email."
                          finish:^(void) {
                              [self onBack:nil];
                          }];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }
    }];
}
- (BOOL) stringArrayContains:(NSString*)str inArray:(NSMutableArray*)array
{
    for(NSString * subStr in array){
        if([subStr isEqualToString:str])
            return YES;
    }
    return NO;
}
@end
