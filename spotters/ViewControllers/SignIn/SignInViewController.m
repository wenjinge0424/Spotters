//
//  SignInViewController.m
//  spotters
//
//  Created by Techsviewer on 3/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SignInViewController.h"
#import "Onboard1ViewController.h"
#import "ForgotPwdViewController.h"
#import "HomeViewController.h"

@interface SignInViewController ()<GIDSignInUIDelegate, GIDSignInDelegate>
@property (weak, nonatomic) IBOutlet UITextField *edt_email;
@property (weak, nonatomic) IBOutlet UITextField *edt_pwd;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.edt_email setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:self.edt_email.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    [self.edt_pwd setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:self.edt_pwd.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([Util getLoginUserName].length > 0 && [Util getLoginUserPassword].length > 0){
        _edt_email.text = [Util getLoginUserName];
        _edt_pwd.text = [Util getLoginUserPassword];
        [self onSignIn:nil];
    }
}
- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _edt_email.text = @"";
    _edt_pwd.text = @"";
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (BOOL) isValid {
    _edt_email.text = [Util trim:_edt_email.text];
    NSString *email = _edt_email.text;
    NSString *password = _edt_pwd.text;
    NSString * errorMsg = @"";
    if (email.length == 0){
        errorMsg = @"Please input your email.";
    }else if(![email isEmail]){
        errorMsg = @"Please input valid email.";
    }else if([email containsString:@".."]){
        errorMsg = @"Please input valid email.";
    }else if (password.length == 0){
        errorMsg = @"Please input your password.";
    }
    if(errorMsg.length > 0){
        [Util showAlertTitle:self title:@"Sign In" message:errorMsg];
        return NO;
    }
    return YES;
}
- (IBAction)onSignIn:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    if (![self isValid]){
        return;
    }
    [_edt_email resignFirstResponder];
    [_edt_pwd resignFirstResponder];
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_EMAIL equalTo:_edt_email.text.lowercaseString];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            PFUser *user = (PFUser *)object;
            NSString *username = user.username;
            [PFUser logInWithUsernameInBackground:username password:_edt_pwd.text block:^(PFUser *user, NSError *error) {
                [SVProgressHUD dismiss];
                if (user) {
                    BOOL isBanned = [user[PARSE_USER_IS_BANNED] boolValue];
                    if (isBanned){
                        [Util showAlertTitle:self title:@"Error" message:@"Banned User"];
                        return;
                    }
                    int userType = [user[PARSE_USER_TYPE] intValue];
                    if(userType == 200){
                        [Util showAlertTitle:self title:@"Error" message:@"This is admin account. Please use web admin panel."];
                        return;
                    }
                    [Util setLoginUserName:user.email password:_edt_pwd.text];
                    [self gotoMainScreen];
                } else {
                    NSString *errorString = @"Password entered is incorrect.";
                    [Util showAlertTitle:self title:@"Login Failed" message:errorString finish:^{
                        [_edt_pwd becomeFirstResponder];
                    }];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            [Util setLoginUserName:@"" password:@""];
            
            NSString *msg = @"Email entered is not registered. Create an account now?";
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:@"Not now" actionBlock:^(void) {
            }];
            [alert addButton:@"Sign Up" actionBlock:^(void) {
                [self onSignUp:nil];
            }];
            [alert showError:@"Sign Up" subTitle:msg closeButtonTitle:nil duration:0.0f];
        }
    }];
}
- (void) gotoMainScreen
{
    HomeViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onFacebookSignIn:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
         if (user != nil) {
             if (user[@"facebookid"] == nil) {
                 PFUser *puser = [PFUser user];
                 puser = user;
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self requestFacebook:puser];
             } else {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self userLoggedIn:user];
             }
         } else {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [Util showAlertTitle:self title:@"" message:@"Failed to login via Facebook."];
         }
     }];
}

- (IBAction)onGoogleISignIn:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    [[GIDSignIn sharedInstance] signIn];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (IBAction)onSignUp:(id)sender {
    Onboard1ViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Onboard1ViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onForgotPassword:(id)sender {
    ForgotPwdViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ForgotPwdViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - facebook delegate
- (void)requestFacebook:(PFUser *)user
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,first_name,last_name,birthday,email" forKey:@"fields"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error == nil)
        {
            NSDictionary *userData = (NSDictionary *)result;
            [self processFacebook:user UserData:userData];
        }
        else
        {
            [Util setLoginUserName:@"" password:@""];
            [PFUser logOut];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile."];
        }
    }];
}

- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData
{
    NSString *link = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject) {
             user.username = userData[@"name"];
             user.password = [Util randomStringWithLength:20];
             user[PARSE_USER_FULLNAME] = [NSString stringWithFormat:@"%@ %@", userData[@"first_name"], userData[@"last_name"]];
             user[PARSE_USER_FIRSTNAME] = userData[@"first_name"];
             user[PARSE_USER_LASTSTNAME] = userData[@"last_name"];
             user[PARSE_USER_FACEBOOKID] = userData[@"id"];
             if (userData[@"email"]) {
                 user.email = userData[@"email"];
                 user.username = user.email;
             } else {
                 NSString *name = [[userData[@"name"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                 user.email = [NSString stringWithFormat:@"%@@facebook.com",name];
                 user.username = user.email;
             }
             
             UIImage *profileImage = [Util getUploadingImageFromImage:responseObject];
             NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
             NSString *filename = [NSString stringWithFormat:@"avatar.png"];
             PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
             user[PARSE_USER_AVATAR] = imageFile;
             user[PARSE_USER_TYPE] = [NSNumber numberWithInt:300];
             user[PARSE_USER_PREVIEWPWD] = user.password;
             
             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 if (!error) {
                     [Util setLoginUserName:user.username password:user.password];
                     [self gotoMainScreen];
                 } else {
                     NSString *message = [error localizedDescription];
                     if ([message containsString:@"already"]){
                         message = @"Account already exists for this email.";
                     }
                     [Util showAlertTitle:self title:@"Error" message:message];
                 }
             }];
             
         } else {
             [Util setLoginUserName:@"" password:@""];
             [PFUser logOut];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [Util setLoginUserName:@"" password:@""];
         [PFUser logOut];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}
- (void)userLoggedIn:(PFUser *)user {
    /* login */
    user.password = [Util randomStringWithLength:20];
    [Util setLoginUserName:user.email password:user.password];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [user saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            _edt_email.text = user.email;
            _edt_pwd.text = user.password;
            [self onSignIn:nil];
        }];
    }];
}

#pragma mark - google sign in delegate
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (error) {
        [Util showAlertTitle:self title:@"Oops!" message:@"Failed to login Google."];
    } else {
        NSString *passwd = [Util randomStringWithLength:20];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              user.profile.email, @"username",
                              user.userID, @"googleid",
                              passwd, @"password",
                              nil];
        
        [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD setForegroundColor:MAIN_COLOR];
        PFQuery *query = [PFUser query];
        [query whereKey:PARSE_USER_EMAIL equalTo:user.profile.email];
        [query whereKeyDoesNotExist:PARSE_USER_GOOGLEID];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *obj, NSError *error){
            if (obj){
                [SVProgressHUD dismiss];
                [[GIDSignIn sharedInstance] signOut];
                [Util showAlertTitle:self title:@"Error" message:@"Account already exists for this email."];
            } else {
                [PFCloud callFunctionInBackground:@"resetGooglePasswd" withParameters:data block:^(id object, NSError *err) {
                    if (err) { // this user is not registered on parse server
                        PFUser *puser = [PFUser user];
                        puser.password = passwd;
                        puser[PARSE_USER_FULLNAME] = [NSString stringWithFormat:@"%@ %@", user.profile.givenName, user.profile.familyName];
                        puser[PARSE_USER_FIRSTNAME] = user.profile.givenName;
                        puser[PARSE_USER_LASTSTNAME] = user.profile.familyName;
                        puser[PARSE_USER_GOOGLEID] = user.userID;
                        puser[PARSE_USER_TYPE] = [NSNumber numberWithInt:300];
                        puser[PARSE_USER_PREVIEWPWD] = puser.password;
                        puser.email = user.profile.email;
                        puser.username = puser.email;
                        
                        if (user.profile.hasImage) {
                            NSURL *imageURL = [user.profile imageURLWithDimension:50*50];
                            UIImage *im = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
                            UIImage *profileImage = [Util getUploadingImageFromImage:im];
                            NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                            NSString *filename = [NSString stringWithFormat:@"avatar.png"];
                            PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
                            puser[PARSE_USER_AVATAR] = imageFile;
                        }
                        [puser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [SVProgressHUD dismiss];
                            if (!error) {
                                [Util setLoginUserName:puser.username password:puser.password];
                                [self gotoMainScreen];
                            } else {
                                NSString *message = [error localizedDescription];
                                if ([message containsString:@"already"]){
                                    message = @"Account already exists for this email.";
                                }
                                [Util showAlertTitle:self title:@"Error" message:message];
                            }
                        }];
                    } else { // this server is registerd on parse server
                        double delayInSeconds = 1.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            _edt_email.text = user.profile.email;
                            _edt_pwd.text = passwd;
                            [self onSignIn:nil];
                        });
                    }
                }];
            }
        }];
    }
}
@end
