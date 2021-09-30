//
//  ChatViewController.m
//  smallplayerbigplay
//
//  Created by Techsviewer on 7/25/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatDetailsViewController.h"
#import "IQDropDownTextField.h"

@interface ChatViewController ()<IQDropDownTextFieldDelegate>
{
    IBOutlet IQDropDownTextField *txtUsername;
    __weak IBOutlet UILabel *lbl_title;
    IBOutlet UIView *viewUsername;
    
    NSMutableArray *usersArray;
    PFUser *me;
    NSMutableArray *dataArray;
}
@property (weak, nonatomic) IBOutlet UIView *view_flag;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.toUser){
        lbl_title.text = [NSString stringWithFormat:@"%@ %@", self.toUser[PARSE_USER_FIRSTNAME], self.toUser[PARSE_USER_LASTSTNAME]];
        viewUsername.hidden = YES;
        self.view_flag.hidden = NO;
    } else {
        self.view_flag.hidden = YES;
        txtUsername.delegate = self;
        lbl_title.text = @"NEW MESSAGE";
        viewUsername.hidden = NO;
        usersArray = [[NSMutableArray alloc] init];
        dataArray = [[NSMutableArray alloc] init];
        me = [PFUser currentUser];
        [me fetchIfNeeded];
        [self fetchFriends];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (IBAction)onBack:(id)sender {
    if(self.room){
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [self.room fetchInBackgroundWithBlock:^(PFObject* obj, NSError * error){
            [SVProgressHUD dismiss];
            NSString * lastMessage = obj[PARSE_ROOM_LAST_MESSAGE];
            if(!lastMessage || lastMessage.length == 0){
                [self.room deleteInBackground];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showChat"]) {
        ChatDetailsViewController *vc = (ChatDetailsViewController *) segue.destinationViewController;
        vc.toUser = self.toUser;
        vc.room = self.room;
    }
}

- (void) isContainedinFriends:(PFUser *)user {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i=0;i<usersArray.count;i++){
        [tempArray addObject:[usersArray objectAtIndex:i]];
    }
    for (PFUser *item in tempArray){
        if ([item.objectId isEqualToString:user.objectId]){
            [usersArray removeObject:item];
        }
    }
}
- (void) fetchFriends
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    PFUser * me = [PFUser currentUser];
    usersArray = [NSMutableArray new];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery * queryFrom = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [queryFrom whereKey:PARSE_FRIEND_SENDER equalTo:me];
    PFQuery * queryTo = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [queryTo whereKey:PARSE_FRIEND_RECEIVER equalTo:me];
    PFQuery * myFriendQuery = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:queryFrom, queryTo, nil]];
    [myFriendQuery includeKey:PARSE_FRIEND_SENDER];
    [myFriendQuery includeKey:PARSE_FRIEND_RECEIVER];
    [myFriendQuery whereKey:PARSE_FRIEND_SENDER_ACCEPT equalTo:[NSNumber numberWithBool:YES]];
    [myFriendQuery whereKey:PARSE_FRIEND_RECEIVER_ACCEPT equalTo:[NSNumber numberWithBool:YES]];
    [myFriendQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            usersArray = [NSMutableArray new];
            for(PFObject * obj in array){
                PFUser * sender = obj[PARSE_FRIEND_SENDER];
                PFUser * to = obj[PARSE_FRIEND_RECEIVER];
                PFUser * me = [PFUser currentUser];
                if([sender.objectId isEqualToString:me.objectId])
                    [usersArray addObject:to];
                else
                    [usersArray addObject:sender];
            }
            
            PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
            [query1 whereKey:PARSE_ROOM_SENDER equalTo:me];
            [query1 whereKey:PARSE_ROOM_SENDER_REMOVE notEqualTo:[NSNumber numberWithBool:YES]];
            
            PFQuery *query2 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
            [query2 whereKey:PARSE_ROOM_RECEIVER equalTo:me];
            [query2 whereKey:PARSE_ROOM_RECEIVER_REMOVE notEqualTo:[NSNumber numberWithBool:YES]];
            
            NSMutableArray *queries = [[NSMutableArray alloc] init];
            [queries addObject:query1];
            [queries addObject:query2];
            PFQuery *query = [PFQuery orQueryWithSubqueries:queries];
//            [query whereKey:PARSE_ROOM_ENABLED equalTo:@YES];
            [query includeKey:PARSE_ROOM_RECEIVER];
            [query includeKey:PARSE_ROOM_SENDER];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                if (error){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
                } else {
                    NSMutableArray *resultArray = (NSMutableArray *) array;
                    for (NSInteger i=0;i<resultArray.count;i++){
                        PFObject *room = [resultArray objectAtIndex:i];
                        PFUser *sender = (PFUser *) room[PARSE_ROOM_SENDER];
                        PFUser *toUser;
                        if ([sender.objectId isEqualToString:me.objectId]){
                            toUser = (PFUser *) room[PARSE_ROOM_RECEIVER];
                        } else {
                            toUser = sender;
                        }
                        
                        [self isContainedinFriends:toUser];
                    }
                    dataArray = [[NSMutableArray alloc] init];
                    for (PFUser *item in usersArray){
                        PFUser *user = [item fetchIfNeeded];
                        [dataArray addObject:[NSString stringWithFormat:@"%@ %@", user[PARSE_USER_FIRSTNAME], user[PARSE_USER_LASTSTNAME]]];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        txtUsername.itemList = dataArray;
                        [SVProgressHUD dismiss];
                    });
                }
            }];
        }
    }];
}
- (void) textField:(IQDropDownTextField *)textField didSelectItem:(NSString *)item {
    NSLog(@"SELETECT %@", item);
}
- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == txtUsername){
        NSInteger currentIndex = [dataArray indexOfObject:txtUsername.selectedItem];
        if (currentIndex == NSNotFound){
            return;
        }
        
        PFUser *user = [usersArray objectAtIndex:currentIndex];
        if (!user){
            return;
        }
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
            return;
        }
        self.view_flag.hidden = NO;
        viewUsername.hidden = YES;
        lbl_title.text = [NSString stringWithFormat:@"%@ %@", user[PARSE_USER_FIRSTNAME], user[PARSE_USER_LASTSTNAME]];
    
        PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query1 whereKey:PARSE_ROOM_SENDER equalTo:me];
        [query1 whereKey:PARSE_ROOM_RECEIVER equalTo:user];
        
        PFQuery *query2 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query2 whereKey:PARSE_ROOM_RECEIVER equalTo:me];
        [query2 whereKey:PARSE_ROOM_SENDER equalTo:user];
        
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        [queries addObject:query1];
        [queries addObject:query2];
        PFQuery *query = [PFQuery orQueryWithSubqueries:queries];
        [query whereKey:PARSE_ROOM_ENABLED equalTo:@NO];
        [query includeKey:PARSE_ROOM_RECEIVER];
        [query includeKey:PARSE_ROOM_SENDER];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            if (error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
            } else {
                if (array.count > 0){
                    PFObject *room = (PFObject *)[array objectAtIndex:0];
                    room[PARSE_ROOM_ENABLED] = @YES;
                    [room saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                        [SVProgressHUD dismiss];
                        [[ChatDetailsViewController getInstance] setRoom:room User:user];
                    }];
                } else {
                    PFObject *room = [PFObject objectWithClassName:PARSE_TABLE_CHAT_ROOM];
                    room[PARSE_ROOM_SENDER] = me;
                    room[PARSE_ROOM_RECEIVER] = user;
                    room[PARSE_ROOM_LAST_MESSAGE] = @"";
                    room[PARSE_ROOM_ENABLED] = @YES;
                    room[PARSE_ROOM_IS_READ] = @YES;
                    [room saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                        [SVProgressHUD dismiss];
                        [[ChatDetailsViewController getInstance] setRoom:room User:user];
                    }];
                }
            }
        }];
    }
}
@end
