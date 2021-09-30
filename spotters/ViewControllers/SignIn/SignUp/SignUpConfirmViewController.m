//
//  SignUpConfirmViewController.m
//  spotters
//
//  Created by Techsviewer on 3/15/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SignUpConfirmViewController.h"
#import "SignUpInfoViewController.h"

@interface SignUpConfirmViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtRepassword;
@property (weak, nonatomic) IBOutlet UIButton *btnMatch;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@end

@implementation SignUpConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.txtRepassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.txtRepassword.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [_txtRepassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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
    SignUpInfoViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpInfoViewController"];
    controller.user = self.user;
    [self.navigationController pushViewController:controller animated:YES];
}
- (BOOL) isValid {
    BOOL result = _btnMatch.selected /*&& btnLower.selected && btnUpper.selected && btnNumber.selected */;
    return result;
}
-(void)textFieldDidChange :(UITextField *) textField{
    _btnMatch.selected = [self.user[PARSE_USER_PASSWORD] isEqualToString:_txtRepassword.text];
    _btnNext.enabled = _btnMatch.selected;
}
@end
