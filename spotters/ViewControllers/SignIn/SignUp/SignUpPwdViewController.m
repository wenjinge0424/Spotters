//
//  SignUpPwdViewController.m
//  spotters
//
//  Created by Techsviewer on 3/15/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SignUpPwdViewController.h"
#import "SignUpConfirmViewController.h"

@interface SignUpPwdViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@property (weak, nonatomic) IBOutlet UIButton *btnLength;
@property (weak, nonatomic) IBOutlet UIButton *btnNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnUpper;
@property (weak, nonatomic) IBOutlet UIButton *btnLower;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@end

@implementation SignUpPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.txtPassword.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [_txtPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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
    self.user[PARSE_USER_PASSWORD] = _txtPassword.text;
    self.user[PARSE_USER_PREVIEWPWD] = _txtPassword.text;
    SignUpConfirmViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpConfirmViewController"];
    controller.user = self.user;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL) isValid {
    BOOL result = _btnLength.selected && _btnLower.selected && _btnNumber.selected && _btnUpper.selected;
    return result;
}
-(void)textFieldDidChange :(UITextField *) textField{
    NSString *password = _txtPassword.text;
    _btnLength.selected = (password.length >= 6);
    _btnLower.selected = [Util isContainsLowerCase:password];
    _btnUpper.selected = [Util isContainsUpperCase:password];
    _btnNumber.selected = [Util isContainsNumber:password];
    _btnNext.enabled = [self isValid];
}
@end
