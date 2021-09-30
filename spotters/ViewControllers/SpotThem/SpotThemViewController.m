//
//  SpotThemViewController.m
//  spotters
//
//  Created by Techsviewer on 3/18/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SpotThemViewController.h"
#import "SwipeAbleView.h"
#import "SpotUserView.h"
#import "BuddyProfileVC.h"
#import "UserProfileVC.h"

@interface SpotThemViewController ()<IQDropDownTextFieldDelegate, SwipeAbleViewDelegate>
{
    PFUser * me;
    NSString * selectedGymId;
    NSMutableArray * gymNameList;
    NSMutableArray * myGymList;
    
    NSMutableArray * searchedUsers;
    
    NSMutableArray * myFriendList;
}
@property (weak, nonatomic) IBOutlet IQDropDownTextField *edtGym;
@property (weak, nonatomic) IBOutlet SwipeAbleView *m_swipeContainer;

@end

@implementation SpotThemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    self.edtGym.delegate = self;
    self.m_swipeContainer.delegate = self;
    [Util showWaitingMark];
    myFriendList = [NSMutableArray new];
    PFQuery * friendQuery1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [friendQuery1 whereKey:PARSE_FRIEND_SENDER equalTo:me];
    PFQuery * friendQuery2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [friendQuery2 whereKey:PARSE_FRIEND_RECEIVER equalTo:me];
    PFQuery * friendsQuery = [PFQuery orQueryWithSubqueries:@[friendQuery1, friendQuery2]];
    [friendsQuery includeKey:PARSE_FRIEND_SENDER];
    [friendsQuery includeKey:PARSE_FRIEND_RECEIVER];
    [friendsQuery whereKey:PARSE_FRIEND_SENDER_ACCEPT equalTo:[NSNumber numberWithBool:YES]];
    [friendsQuery whereKey:PARSE_FRIEND_RECEIVER_ACCEPT equalTo:[NSNumber numberWithBool:YES]];
    
    [Util findObjectsInBackground:friendsQuery vc:self handler:^(NSArray *resultObj) {
        for(PFObject * sub in resultObj){
            PFUser * sender = sub[PARSE_FRIEND_SENDER];
            PFUser * receiver = sub[PARSE_FRIEND_RECEIVER];
            if([sender.objectId isEqualToString:me.objectId]){
                [myFriendList addObject:receiver];
            }else{
                [myFriendList addObject:sender];
            }
        }
        NSMutableArray * mainGyms =  [NSMutableArray new];
        gymNameList = [NSMutableArray new];
        myGymList = [NSMutableArray new];
        [mainGyms addObject:me[PARSE_USER_MAINGYM]];
        [mainGyms addObjectsFromArray:me[PARSE_USER_SECONDGYMS]];
        
        [Util getGymNamesWithIds:mainGyms completionBlock:^(NSMutableArray * gymObjects){
            [Util hideWaitingMark];
            for(PFObject * object in gymObjects){
                NSString * strGymName = object[FIELD_SPECIALGYM_NAME];
                [gymNameList addObject:strGymName];
                [myGymList addObject:object];
            }
            self.edtGym.itemList = gymNameList;
            selectedGymId = [mainGyms firstObject];
            [self.edtGym setText:[gymNameList firstObject]];
            
            [self fetchUsersWithGymId:selectedGymId];
        }];
    }];
}

- (void) fetchUsersWithGymId:(NSString*)gymId
{
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    NSMutableArray * unLikeUsers = me[PARSE_USER_UNLIKEUSER];
    if(!unLikeUsers) unLikeUsers = [NSMutableArray new];
    
    [Util showWaitingMark];
    PFQuery * query1 = [PFUser query];
    [query1 whereKey:PARSE_USER_MAINGYM equalTo:gymId];
    [query1 whereKey:PARSE_FIELD_OBJECT_ID notContainedIn:unLikeUsers];
    
    PFQuery * query2 = [PFUser query];
    [query2 whereKey:PARSE_USER_SECONDGYMS containedIn:@[gymId]];
    [query2 whereKey:PARSE_FIELD_OBJECT_ID notContainedIn:unLikeUsers];
    
    PFQuery * searchQuery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [searchQuery whereKey:PARSE_FIELD_OBJECT_ID notEqualTo:me.objectId];
    [searchQuery whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInteger:100]];
    [searchQuery orderByAscending:PARSE_FIELD_CREATED_AT];

    [searchQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [Util hideWaitingMark];
        if(error){
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        }else{
            [self loadSwipeAbleView:[[NSMutableArray alloc] initWithArray:objects]];
        }
    }];
}
- (void) loadSwipeAbleView:(NSMutableArray *)array
{
    searchedUsers = array;
    NSMutableArray * swipeAbleViews = [NSMutableArray new];
    for(PFUser * user in array){
        SpotUserView * view = [[SpotUserView alloc] initWithFrame:self.m_swipeContainer.bounds];
        view.currentUser = user;
        view.btn_action.tag = [array indexOfObject:user];
        view.navController = self.navigationController;
        [swipeAbleViews addObject:view];
        [view.btn_action addTarget:self action:@selector(onSelectItemAt:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.m_swipeContainer.allCards =  swipeAbleViews;
    [self.m_swipeContainer loadCards];
    [self.view layoutIfNeeded];
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
- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.edtGym){
        NSInteger currentIndex = [gymNameList indexOfObject:self.edtGym.selectedItem];
        PFObject * gymItem = [myGymList objectAtIndex:currentIndex];
        selectedGymId = gymItem.objectId;
        [self fetchUsersWithGymId:selectedGymId];
    }
}
- (bool) isFriend:(PFUser*)user
{
    for (PFUser * users in myFriendList) {
        if([users.objectId isEqualToString:user.objectId])
            return YES;
    }
    return NO;
}
- (void) onSelectItemAt:(UIButton*)button
{
    int index = (int)button.tag;
    PFUser * detectuser = [searchedUsers objectAtIndex:index];
    if([detectuser.objectId isEqualToString:me.objectId]){
        return;
    }
    if([self isFriend:detectuser]){
        BuddyProfileVC *vc = (BuddyProfileVC *)[Util getUIViewControllerFromStoryBoard:@"BuddyProfileVC"];
        vc.user = detectuser;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        UserProfileVC *vc = (UserProfileVC *)[Util getUIViewControllerFromStoryBoard:@"UserProfileVC"];
        vc.user = detectuser;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)selectCardSwipedRight:(UIView *)card
{
    if([card isKindOfClass:[SpotUserView class]]){
        PFUser * detectuser = ((SpotUserView*)card).currentUser;
        if([detectuser.objectId isEqualToString:me.objectId]){
            return;
        }
        if([self isFriend:detectuser]){
            return;
        }else{
            [self sendFriendRequst:detectuser];
        }
    }
}
- (void) selectCardSwipedLeft:(UIView *)card
{
    if([card isKindOfClass:[SpotUserView class]]){
        PFUser * detectuser = ((SpotUserView*)card).currentUser;
        if([detectuser.objectId isEqualToString:me.objectId]){
            return;
        }
        if([self isFriend:detectuser]){
            return;
        }else{
            [self unLikeUser:detectuser];
        }
    }
}
- (void) sendFriendRequst:(PFUser*) toUser
{
    [Util showWaitingMark];
    me = [PFUser currentUser];
    PFQuery * friendQuery1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [friendQuery1 whereKey:PARSE_FRIEND_SENDER equalTo:me];
    [friendQuery1 whereKey:PARSE_FRIEND_RECEIVER equalTo:toUser];
    PFQuery * friendQuery2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [friendQuery2 whereKey:PARSE_FRIEND_RECEIVER equalTo:me];
    [friendQuery2 whereKey:PARSE_FRIEND_SENDER equalTo:toUser];
    PFQuery * friendsQuery = [PFQuery orQueryWithSubqueries:@[friendQuery1, friendQuery2]];
    [Util findObjectsInBackground:friendsQuery vc:self handler:^(NSArray *resultObj) {
        if(resultObj && resultObj.count > 0){
            PFObject * request = [resultObj firstObject];
            PFUser * receiver = request[PARSE_FRIEND_RECEIVER];
            if([receiver.objectId isEqualToString:me.objectId]){
                request[PARSE_FRIEND_RECEIVER_ACCEPT] = [NSNumber numberWithBool:YES];
                [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    myFriendList = [NSMutableArray new];
                    PFQuery * friendQuery1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
                    [friendQuery1 whereKey:PARSE_FRIEND_SENDER equalTo:me];
                    PFQuery * friendQuery2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
                    [friendQuery2 whereKey:PARSE_FRIEND_RECEIVER equalTo:me];
                    PFQuery * friendsQuery = [PFQuery orQueryWithSubqueries:@[friendQuery1, friendQuery2]];
                    [friendsQuery includeKey:PARSE_FRIEND_SENDER];
                    [friendsQuery includeKey:PARSE_FRIEND_RECEIVER];
                    [friendsQuery whereKey:PARSE_FRIEND_SENDER_ACCEPT equalTo:[NSNumber numberWithBool:YES]];
                    [friendsQuery whereKey:PARSE_FRIEND_RECEIVER_ACCEPT equalTo:[NSNumber numberWithBool:YES]];
                    
                    [Util findObjectsInBackground:friendsQuery vc:self handler:^(NSArray *resultObj) {
                        [Util hideWaitingMark];
                        for(PFObject * sub in resultObj){
                            PFUser * sender = sub[PARSE_FRIEND_SENDER];
                            PFUser * receiver = sub[PARSE_FRIEND_RECEIVER];
                            if([sender.objectId isEqualToString:me.objectId]){
                                [myFriendList addObject:receiver];
                            }else{
                                [myFriendList addObject:sender];
                            }
                        }
                        
                        NSString * message = [NSString stringWithFormat:@"%@ %@ send friend request to you.", me[PARSE_USER_FIRSTNAME], me[PARSE_USER_LASTSTNAME]];
                        [Util sendPushNotification:toUser[PARSE_USER_EMAIL] message:message type:PUSH_TYPE_FOLLOW_REQUEST];
                    }];
                }];
            }else{
                [Util hideWaitingMark];
            }
            
        }else{
            PFObject * friendObj = [PFObject objectWithClassName:PARSE_TABLE_FRIEND];
            friendObj[PARSE_FRIEND_SENDER] = me;
            friendObj[PARSE_FRIEND_RECEIVER] = toUser;
            friendObj[PARSE_FRIEND_SENDER_ACCEPT] = [NSNumber numberWithBool:YES];
            friendObj[PARSE_FRIEND_RECEIVER_ACCEPT] = [NSNumber numberWithBool:NO];
            [friendObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [Util hideWaitingMark];
            }];
        }
    }];
    
}
- (void) unLikeUser:(PFUser*)toUser
{
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    NSMutableArray * unLikeUsers = me[PARSE_USER_UNLIKEUSER];
    if(!unLikeUsers) unLikeUsers = [NSMutableArray new];
    BOOL alreadyContains = NO;
    for(NSString * subUser in unLikeUsers){
        if([subUser isEqualToString:toUser.objectId]){
            alreadyContains = YES;
        }
    }
    if(!alreadyContains){
        [unLikeUsers addObject:toUser.objectId];
    }
    me[PARSE_USER_UNLIKEUSER] = unLikeUsers;
    [Util showWaitingMark];
    [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [Util hideWaitingMark];
    }];
}
@end
