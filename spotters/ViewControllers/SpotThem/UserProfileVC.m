//
//  UserProfileVC.m
//  Spotters
//
//  Created by developer on 6/20/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "UserProfileVC.h"

@interface UserProfileVC (){
    
    __weak IBOutlet UIImageView *imgAvatar;
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UILabel *lblAge;
    __weak IBOutlet UILabel *lblGym;
    PFUser* me;
}
@property (weak, nonatomic) IBOutlet UIButton *btn_request;

@end

@implementation UserProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];

//    lblAge.text = @"35 YEARS";

    self.btn_request.enabled = NO;
    if(self.user) {
        [self.user fetchIfNeeded];
        [Util setAvatar:imgAvatar withUser:self.user];
        lblName.text = [NSString stringWithFormat:@"%@ %@", self.user[PARSE_USER_FIRSTNAME], self.user[PARSE_USER_LASTSTNAME]];
        NSString * mainGymsId = self.user[PARSE_USER_MAINGYM];
        [Util getGymNameWithId:mainGymsId completionBlock:^(NSString * gymName){
            lblGym.text = gymName;
        }];
        [self fetchData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) fetchData
{
    PFUser * me = [PFUser currentUser];
    self.btn_request.enabled = NO;
    [Util showWaitingMark];
    PFQuery * friendQuery1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [friendQuery1 whereKey:PARSE_FRIEND_SENDER equalTo:me];
    [friendQuery1 whereKey:PARSE_FRIEND_RECEIVER equalTo:self.user];
    PFQuery * friendQuery2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [friendQuery2 whereKey:PARSE_FRIEND_RECEIVER equalTo:me];
    [friendQuery2 whereKey:PARSE_FRIEND_SENDER equalTo:self.user];
    PFQuery * friendsQuery = [PFQuery orQueryWithSubqueries:@[friendQuery1, friendQuery2]];
    [Util findObjectsInBackground:friendsQuery vc:self handler:^(NSArray *resultObj) {
        if(resultObj && resultObj.count > 0){
            PFObject * request = [resultObj firstObject];
            PFUser * receiver = request[PARSE_FRIEND_RECEIVER];
            if([receiver.objectId isEqualToString:me.objectId]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Util hideWaitingMark];
                    self.btn_request.enabled = YES;
                    self.btn_request.tag = 200;
                    [self.btn_request setTitle:@"ACCEPT FRIEND" forState:UIControlStateNormal];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Util hideWaitingMark];
                    self.btn_request.enabled = NO;
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [Util hideWaitingMark];
                self.btn_request.enabled = YES;
                self.btn_request.tag = 100;
                [self.btn_request setTitle:@"SPOT THEM" forState:UIControlStateNormal];
            });
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
- (IBAction)onSpot:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    if(self.btn_request.tag == 100){// send request
        [Util showWaitingMark];
        PFObject * friendObj = [PFObject objectWithClassName:PARSE_TABLE_FRIEND];
        friendObj[PARSE_FRIEND_SENDER] = me;
        friendObj[PARSE_FRIEND_RECEIVER] = self.user;
        friendObj[PARSE_FRIEND_SENDER_ACCEPT] = [NSNumber numberWithBool:YES];
        friendObj[PARSE_FRIEND_RECEIVER_ACCEPT] = [NSNumber numberWithBool:NO];
        [friendObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [Util hideWaitingMark];
            [Util showAlertTitle:self title:STRING_SUCCESS message:@"Success" finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }else{// Accept requst
        [Util showWaitingMark];
        PFQuery * friendQuery1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
        [friendQuery1 whereKey:PARSE_FRIEND_SENDER equalTo:me];
        [friendQuery1 whereKey:PARSE_FRIEND_RECEIVER equalTo:self.user];
        PFQuery * friendQuery2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
        [friendQuery2 whereKey:PARSE_FRIEND_RECEIVER equalTo:me];
        [friendQuery2 whereKey:PARSE_FRIEND_SENDER equalTo:self.user];
        PFQuery * friendsQuery = [PFQuery orQueryWithSubqueries:@[friendQuery1, friendQuery2]];
        [Util findObjectsInBackground:friendsQuery vc:self handler:^(NSArray *resultObj) {
            if(resultObj && resultObj.count > 0){
                PFObject * request = [resultObj firstObject];
                PFUser * receiver = request[PARSE_FRIEND_RECEIVER];
                if([receiver.objectId isEqualToString:me.objectId]){
                    request[PARSE_FRIEND_RECEIVER_ACCEPT] = [NSNumber numberWithBool:YES];
                    [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        [Util hideWaitingMark];
                        [Util showAlertTitle:self title:STRING_SUCCESS message:@"Success" finish:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    }];
                }
            }else{
                [Util hideWaitingMark];
            }
        }];
    }
}
- (IBAction)onReport:(id)sender {
    PFObject* reportObj = [PFObject objectWithClassName:PARSE_TABLE_REPORT];
    [reportObj setObject:me forKey:FIELD_REPORTER];
    [reportObj setObject:self.user forKey:FIELD_OWNER];
    [reportObj setObject:@"report reaseon" forKey:PARSE_REPORT_DESCRIPTION];
    [Util showWaitingMark];
    [reportObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [Util hideWaitingMark];
        if (succeeded){
            [Util showAlertTitle:self title:STRING_SUCCESS message:@"Success" finish:^{
            }];
        }
        else {
            [Util showAlertTitle:self title:STRING_ERROR message:error.localizedDescription finish:^{
            }];
        }
    }];
}

@end
