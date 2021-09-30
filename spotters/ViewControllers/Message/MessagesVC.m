//
//  MessagesVC.m
//  Spotters
//
//  Created by developer on 6/20/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "MessagesVC.h"
#import "ChatViewController.h"
#import "MessageItemCell.h"
#import "NSDate+NVTimeAgo.h"

MessagesVC *_sharedViewController;
@interface MessagesVC () <UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate>{
    
    __weak IBOutlet UITableView *tableView;
    NSMutableArray *dataArray;
    NSMutableDictionary * unreadCounts;
    int calcIndex;
    PFUser *me;
    __weak IBOutlet UILabel *lblTitle;
    
}

@end

@implementation MessagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    _sharedViewController = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRooms) name:kChatReceiveNotificationUsers object:nil];
}
+ (MessagesVC *)getInstance
{
    return _sharedViewController;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _sharedViewController = self;
    [self refreshRooms];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _sharedViewController = nil;
}
- (void) refreshRooms
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    if (![SVProgressHUD isVisible])
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    
    tableView.userInteractionEnabled = NO;
    
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
    //    [query whereKey:PARSE_ROOM_ENABLED equalTo:@YES];
    [query includeKey:PARSE_ROOM_RECEIVER];
    [query includeKey:PARSE_ROOM_SENDER];
    [query orderByDescending:PARSE_FIELD_UPDATED_AT];
    [query whereKeyExists:PARSE_ROOM_LAST_MESSAGE];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        
        unreadCounts = [NSMutableDictionary new];
        if (error){
            [SVProgressHUD dismiss];
            tableView.userInteractionEnabled = YES;
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            dataArray = (NSMutableArray *) array;
            calcIndex = 0;
            [self getUnreadCount:dataArray :calcIndex];
        }
    }];
}
- (void) getUnreadCount:(NSMutableArray *) roomArray :(int)index
{
    if(index >= roomArray.count){
        [SVProgressHUD dismiss];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView reloadData];
        tableView.userInteractionEnabled = YES;
    }else{
        calcIndex = index;
        PFObject * rommDict = [roomArray objectAtIndex:index];
        PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_HISTORY];
        [query whereKey:PARSE_HISTORY_ROOM equalTo:rommDict];
        [query whereKey:PARSE_HISTORY_SENDER notEqualTo:[PFUser currentUser]];
        [query whereKey:PARSE_ROOM_RECEIVER_REMOVE notEqualTo:[NSNumber numberWithBool:YES]];
        [query whereKey:PARSE_ROOM_IS_READ equalTo:[NSNumber numberWithBool:NO]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            if(array.count > 0){
                [unreadCounts setObject:[NSNumber numberWithInt:(int)array.count] forKey:rommDict.objectId];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                calcIndex ++;
                [self getUnreadCount:roomArray :calcIndex];
            });
        }];
    }
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
- (IBAction)onNewMessage:(id)sender {
    ChatViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MessageItemCell";
    MessageItemCell *cell = (MessageItemCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        cell.delegate = self;
        //        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" icon:nil backgroundColor:[UIColor colorWithRed:221.f/255.0f green:65.f/255.0f blue:65.f/255.0f alpha:1.0f]]];
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor colorWithRed:221.f/255.0f green:65.f/255.0f blue:65.f/255.0f alpha:1.0f]]];
        cell.rightButtons[0].tag = indexPath.row;
        cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
        cell.rightExpansion.expansionLayout = MGSwipeExpansionLayoutCenter;
        cell.rightExpansion.buttonIndex = 1;
        
        PFObject *room = [dataArray objectAtIndex:indexPath.row];
        PFUser *sender = room[PARSE_ROOM_SENDER];
        PFUser *toUser;
        if ([sender.objectId isEqualToString:me.objectId]){
            toUser = room[PARSE_ROOM_RECEIVER];
        } else {
            sender = me;
            toUser = room[PARSE_ROOM_SENDER];
        }
        [Util setImage:cell.img_thumb imgFile:(PFFile *)toUser[PARSE_USER_AVATAR]  withDefault:[UIImage imageNamed:@"ico_userProfile"]];
        cell.lbl_username.text  = [NSString stringWithFormat:@"%@ %@", toUser[PARSE_USER_FIRSTNAME], toUser[PARSE_USER_LASTSTNAME]];
        if (room[PARSE_ROOM_LAST_MESSAGE]){
            cell.lbl_lastMsg.text = room[PARSE_ROOM_LAST_MESSAGE];
            cell.lbl_time.text = [room.updatedAt formattedAsTimeAgo];
        };
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PFObject *room = [dataArray objectAtIndex:indexPath.row];
    PFUser *sender = room[PARSE_ROOM_SENDER];
    PFUser *toUser;
    if ([sender.objectId isEqualToString:me.objectId]){
        toUser = room[PARSE_ROOM_RECEIVER];
    } else {
        toUser = room[PARSE_ROOM_SENDER];
    }
    if (![room[PARSE_ROOM_IS_READ] boolValue]){
        PFUser *lastSender = room[PARSE_ROOM_LAST_SENDER];
        if (![lastSender.objectId isEqualToString:me.objectId]){
            room[PARSE_ROOM_IS_READ] = @YES;
            [room saveInBackground];
        }
    }
    
    ChatViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    controller.room = room;
    controller.toUser = toUser;
    [self.navigationController pushViewController:controller animated:YES];
}
- (BOOL) swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    int row = (int)[tableView indexPathForCell:cell].row;
    if(direction == MGSwipeDirectionRightToLeft){
        NSString *msg = @"Are you sure delete this message?";
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Yes" actionBlock:^(void) {
            if (![Util isConnectableInternet]){
                [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
                return;
            }
            tableView.userInteractionEnabled = NO;
            PFObject *room = [dataArray objectAtIndex:row];
            room[PARSE_ROOM_ENABLED] = @NO;
            //            room[PARSE_ROOM_LAST_MESSAGE] = @"";
            PFUser * room_sender = room[PARSE_ROOM_SENDER];
            if ([room_sender.objectId isEqualToString:me.objectId]){
                room[PARSE_ROOM_SENDER_REMOVE] = [NSNumber numberWithBool:YES];
            } else {
                room[PARSE_ROOM_RECEIVER_REMOVE] = [NSNumber numberWithBool:YES];
            }
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [room saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                
                PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_HISTORY];
                [query whereKey:PARSE_HISTORY_ROOM equalTo:room];
                [query includeKey:PARSE_HISTORY_SENDER];
                [query setLimit:1000];
                [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
                    for (int i=0;i<results.count;i++){
                        PFObject *item = [results objectAtIndex:i];
                        if ([room_sender.objectId isEqualToString:me.objectId]){
                            item[PARSE_ROOM_SENDER_REMOVE] = [NSNumber numberWithBool:YES];
                        } else {
                            item[PARSE_ROOM_RECEIVER_REMOVE] = [NSNumber numberWithBool:YES];
                        }
                        [item saveInBackground];
                    }
                    
                    [self refreshRooms];
                }];
            }];
        }];
        [alert addButton:@"No" actionBlock:^(void) {
        }];
        [alert showError:@"Delete" subTitle:msg closeButtonTitle:nil duration:0.0f];
        return YES;
    }
    return NO;
}

@end
