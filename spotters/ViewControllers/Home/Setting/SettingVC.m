//
//  SettingVC.m
//  Spotters
//
//  Created by developer on 6/19/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "SettingVC.h"
#import "SettingTableViewCell.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "PrivacyPolicyVC.h"
#import "PurchaseViewController.h"

@interface SettingVC () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>{
    
    __weak IBOutlet UITableView *tableView;
}

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated
{
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (IBAction)onNotification:(id)sender {
    UIViewController *vc = (UIViewController *)[Util getUIViewControllerFromStoryBoard:@"NotificationsVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingTableViewCell* cell = (SettingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SettingTableViewCell"];
    UIImageView* imgView = (UIImageView*)[cell viewWithTag:1];
    UILabel* lbl = (UILabel*)[cell viewWithTag:2];
    switch (indexPath.row) {
        case si_inappPurchase:
            imgView.image = [UIImage imageNamed:@""];
            lbl.text = @"In-App purchase";
            break;
        case si_rateTheApp:
            imgView.image = [UIImage imageNamed:@"ic_star.png"];
            lbl.text = @"Rate the App";
            break;
        case si_sendFeedBack:
            imgView.image = [UIImage imageNamed:@"ic_send_feedback.png"];
            lbl.text = @"Send FeedBack";
            break;
        case si_aboutTheApp:
            imgView.image = [UIImage imageNamed:@"ic_about_app.png"];
            lbl.text = @"About the App";
            break;
        case si_privcyPoilcy:
            imgView.image = [UIImage imageNamed:@"ic_pwd_c.png"];
            lbl.text = @"Privacy Policy";
            break;
        case si_termsAndContidions:
            imgView.image = [UIImage imageNamed:@"ic_terms_conditions.png"];
            lbl.text = @"Terms & conditions";
            break;
        case si_logOut:
            imgView.image = [UIImage imageNamed:@"ic_log_out.png"];
            lbl.text = @"Log Out";
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case si_inappPurchase:
            [self onPurchase];
            break;
        case si_rateTheApp:
            [self onRateApp];
            break;
        case si_sendFeedBack:
            [self onSendFeedback];
            break;
        case si_aboutTheApp:
            [self aboutTheApp];
            break;
        case si_privcyPoilcy:
            [self privacyPolicy];
            break;
        case si_termsAndContidions:
            [self termsAndConditions];
            break;
        case si_logOut:
            [self logOut];
            break;
            
        default:
            break;
    }
}
- (void) onPurchase {
    PurchaseViewController *vc = (PurchaseViewController *)[Util getUIViewControllerFromStoryBoard:@"PurchaseViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void) onRateApp {
    if (![Util isConnectableInternet]) {
        [Util showAlertTitle:self title:@"Network Error!" message:@"Couldn't connect to the server. Check your network connection."];
        return;
    }
    
    NSString *msg = @"Are you sure rate app now?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = NO;
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [alert addButton:@"Rate Now" actionBlock:^(void) {
        NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", @"1237147"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        appDelegate.needTDBRate = NO;
    }];
    [alert addButton:@"Maybe later" actionBlock:^(void) {
        
        appDelegate.needTDBRate = YES;
        [self performSelector:@selector(showRateDlg) withObject:nil afterDelay:10];
    }];
    [alert addButton:@"No, Thanks" actionBlock:^(void) {
        appDelegate.needTDBRate = NO;
    }];
    [alert showError:@"Rate App" subTitle:msg closeButtonTitle:nil duration:0.0f];
}

- (void) onSendFeedback {
    if (![Util isConnectableInternet]) {
        [Util showAlertTitle:self title:@"Network Error!" message:@"Couldn't connect to the server. Check your network connection."];
        return;
    }
    
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailComposeViewController=[[MFMailComposeViewController alloc] init];
        
        mailComposeViewController.mailComposeDelegate=self;
        [mailComposeViewController setSubject:STR_SENDFEEDBACK];
        [mailComposeViewController setToRecipients:@[STR_APPOWNER_EMAIL]];
        
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    }
    else{
        [[[UIAlertView alloc] initWithTitle:STR_INFORMATION message:STR_CANNOTSENDEMAIL delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (void) aboutTheApp{
    PrivacyPolicyVC *vc = (PrivacyPolicyVC *)[Util getUIViewControllerFromStoryBoard:@"PrivacyPolicyVC"];
    vc.mType = p_p_aboutTheApp;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) privacyPolicy{
    PrivacyPolicyVC *vc = (PrivacyPolicyVC *)[Util getUIViewControllerFromStoryBoard:@"PrivacyPolicyVC"];
    vc.mType = p_p_privacyPolicy;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) termsAndConditions{
    PrivacyPolicyVC *vc = (PrivacyPolicyVC *)[Util getUIViewControllerFromStoryBoard:@"PrivacyPolicyVC"];
    vc.mType = p_p_termsAndConditions;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void) logOut{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    alert.customViewColor = MAIN_COLOR;
    
    [alert addButton:@"Ok" actionBlock:^{
        [Util showWaitingMark];

        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            [Util hideWaitingMark];
            [Util setLoginUserName:@"" password:@""];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"signOut" object:nil];

            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation removeObjectForKey:PARSE_FIELD_USER];
            [currentInstallation saveInBackground];

            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        
    }];
    
    [alert showInfo:STR_CONFIRM subTitle:STR_CONFIRM_LOGOUT closeButtonTitle:STR_CANCEL duration:0.f];
}



#pragma MFMailComposeViewController

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [controller dismissViewControllerAnimated:NO completion:nil];
    
    switch (result) {
        case MFMailComposeResultSent:
            [[[UIAlertView alloc] initWithTitle:STR_INFORMATION message:STR_SENDEMAIL_SUCCESS delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
            
        case MFMailComposeResultFailed:
            [[[UIAlertView alloc] initWithTitle:STR_INFORMATION message:STR_SENDEMAIL_FAIL delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
            
        default:
            break;
    }
    
}

@end
