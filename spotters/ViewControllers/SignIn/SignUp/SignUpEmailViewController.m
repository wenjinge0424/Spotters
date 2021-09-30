//
//  SignUpEmailViewController.m
//  spotters
//
//  Created by Techsviewer on 3/15/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SignUpEmailViewController.h"
#import "SignUpPwdViewController.h"

@interface SignUpEmailViewController ()
{
    PFUser *user;
    NSMutableArray *dataArray;
}
@property (weak, nonatomic) IBOutlet UITextField *edt_email;
@property (weak, nonatomic) IBOutlet UIButton *btn_valid;
@property (weak, nonatomic) IBOutlet UIButton *btn_noUse;
@property (weak, nonatomic) IBOutlet UIButton *btn_next;
@end

@implementation SignUpEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    user = [PFUser user];
    self.edt_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_email.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [_edt_email addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    dataArray = [[NSMutableArray alloc] init];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *owner = [array objectAtIndex:i];
                [dataArray addObject:owner.username];
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
- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    user[PARSE_USER_EMAIL] = _edt_email.text;
    user[PARSE_USER_TYPE] = [NSNumber numberWithInt:300];
    user[PARSE_USER_IS_BANNED] = [NSNumber numberWithBool:NO];
    user.username = _edt_email.text;
    SignUpPwdViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpPwdViewController"];
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}
- (BOOL) isValid {
    _edt_email.text = [Util trim:_edt_email.text];
    NSString *email = _edt_email.text;
    if (email.length == 0){
        return NO;
    }
    if (![email isEmail]){
        return NO;
    }
    return YES;
}
-(void)textFieldDidChange :(UITextField *) textField{
    _edt_email.text = [Util trim:_edt_email.text.lowercaseString];
    NSString *email = _edt_email.text;
    _btn_valid.selected = [email isEmail];
    if (![email isEmail]){
        _btn_noUse.selected = NO;
        _btn_next.enabled = NO;
        return;
    }
    if ([email containsString:@".."]){
        _btn_valid.selected = NO;
        _btn_noUse.selected = NO;
        _btn_next.enabled = NO;
        return;
    }
    if ([dataArray containsObject:email]){
        _btn_noUse.selected = NO;
        _btn_next.enabled = NO;
    } else if ([email isEmail]){
        _btn_noUse.selected = YES;
        _btn_next.enabled = YES;
    }
}
@end
