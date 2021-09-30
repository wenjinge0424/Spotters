//
//  BaseViewController.m
//  spotters
//
//  Created by Techsviewer on 3/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"
#import "ChatViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)onMessages:(PFUser*)owner
{
    ChatViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    PFUser * me = [PFUser currentUser];
    BOOL isMe = NO;
    if([me.objectId isEqualToString:owner.objectId])
        isMe = YES;
    if (!isMe){
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
            return;
        }
        vc.toUser = owner;
        PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query1 whereKey:PARSE_ROOM_SENDER equalTo:[PFUser currentUser]];
        [query1 whereKey:PARSE_ROOM_RECEIVER equalTo:owner];
        
        PFQuery *query2 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query2 whereKey:PARSE_ROOM_RECEIVER equalTo:[PFUser currentUser]];
        [query2 whereKey:PARSE_ROOM_SENDER equalTo:owner];
        
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        [queries addObject:query1];
        [queries addObject:query2];
        PFQuery *query = [PFQuery orQueryWithSubqueries:queries];
        //        [query whereKey:PARSE_ROOM_ENABLED equalTo:@YES];
        [query includeKey:PARSE_ROOM_RECEIVER];
        [query includeKey:PARSE_ROOM_SENDER];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            if (object){
                [SVProgressHUD dismiss];
                if ([object[PARSE_ROOM_ENABLED] boolValue]){
                    
                } else {
                    object[PARSE_ROOM_ENABLED] = @YES;
                    [object saveInBackground];
                }
                vc.room = object;
                vc.toUser = owner;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_CHAT_ROOM];
                obj[PARSE_ROOM_SENDER] = [PFUser currentUser];
                obj[PARSE_ROOM_RECEIVER] = owner;
                obj[PARSE_ROOM_ENABLED] = @YES;
                obj[PARSE_ROOM_LAST_MESSAGE] = @"";
                obj[PARSE_ROOM_IS_READ] = @YES;
                [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *err){
                    [SVProgressHUD dismiss];
                    vc.room = obj;
                    vc.toUser = owner;
                    [self.navigationController pushViewController:vc animated:YES];
                }];
            }
        }];
    } else {
        //        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
