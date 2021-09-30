//
//  NotificationsVC.m
//  Spotters
//
//  Created by developer on 6/20/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "NotificationsVC.h"
#import "NotificationsBuddyRequestTableViewCell.h"
#import "NotificationsReactionsTableViewCell.h"
#import "NoDataTableViewCell.h"

@interface NotificationsVC () <UITableViewDataSource, UITableViewDelegate, BuddyRequestDelegate>{
    
    __weak IBOutlet UITableView *tableView;
    NSMutableArray* arr_request;
    NSMutableArray* arr_reactions;
    PFObject* me;
}

@end
NotificationsVC *_sharedNotViewController;
@implementation NotificationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sharedNotViewController = self;
    tableView.dataSource = self;
    tableView.delegate = self;
    
    me = [PFUser currentUser];
    [self fetchData];
    
}
+ (NotificationsVC *)getInstance
{
    return _sharedNotViewController;
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _sharedNotViewController = nil;
}
- (void) reloadNotification
{
    [self fetchData];
}
- (void) fetchData
{
    [Util showWaitingMark];
    arr_request = [[NSMutableArray alloc] init];
    arr_reactions = [[NSMutableArray alloc] init];
    PFQuery * friendQuery = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [friendQuery whereKey:PARSE_FRIEND_RECEIVER equalTo:me];
    [friendQuery whereKey:PARSE_FRIEND_RECEIVER_ACCEPT equalTo:[NSNumber numberWithBool:NO]];
    [friendQuery includeKey:PARSE_FRIEND_SENDER];
    [friendQuery includeKey:PARSE_FRIEND_RECEIVER];
    [friendQuery orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:friendQuery vc:self handler:^(NSArray *resultObj) {
        [arr_request removeAllObjects];
        for(PFObject* obj in resultObj ) {
            PFUser * sender = obj[PARSE_FRIEND_SENDER];
            [arr_request addObject:sender];
        }
        [tableView reloadData];
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_REACT_NOTIFICATIONS];
        [query includeKeys:@[FIELD_OWNER]];
        [query whereKey:FIELD_OWNER equalTo: me];
        [query orderByDescending:@"updatedAt"];
        
        [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
            [arr_reactions removeAllObjects];
            arr_reactions = [resultObj mutableCopy];
            
            [Util hideWaitingMark];
            [tableView reloadData];
            
        }];
    }];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if(arr_request.count > 0)
            return arr_request.count;
        return 1;
    }
    if(arr_reactions.count > 0)
        return arr_reactions.count;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if(arr_request.count > 0){
            static NSString* cellId = @"NotificationsBuddyRequestTableViewCell";
            NotificationsBuddyRequestTableViewCell* cell = (NotificationsBuddyRequestTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellId];
            
            cell.delegate = self;
            UIImageView* imgV = (UIImageView*)[cell viewWithTag:1];
            UILabel* lblTitle = (UILabel*)[cell viewWithTag:2];
            UILabel* lblDesc = (UILabel*)[cell viewWithTag:3];
            
            PFUser* user = arr_request[indexPath.row];
            [Util setAvatar:imgV withUser:user];
            lblTitle.text = [NSString stringWithFormat:@"%@ %@", user[PARSE_USER_FIRSTNAME], user[PARSE_USER_LASTSTNAME]];
            return cell;
        }else{
            static NSString* cellId = @"NoDataTableViewCell";
            NoDataTableViewCell* cell = (NoDataTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellId];
            if(cell){
                cell.lbl_noDate.text = @"You have no friend request at this moment.";
            }
            return cell;
        }
        return nil;
        
    }
    else {
        if(arr_reactions.count > 0){
            static NSString* cellId = @"NotificationsReactionsTableViewCell";
            NotificationsReactionsTableViewCell* cell = (NotificationsReactionsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellId];
            
            UIImageView* imgV = (UIImageView*)[cell viewWithTag:1];
            UILabel* lblTitle = (UILabel*)[cell viewWithTag:2];
            UILabel* lblDesc = (UILabel*)[cell viewWithTag:3];
            cell.lbl_noData.hidden = YES;
            PFObject* reactObj = arr_reactions[indexPath.row];
            if(reactObj){
                int reactType = [reactObj[FIELD_REACT_TYPE] intValue];
                switch (reactType) {
                    case reaction_comment:
                        imgV.image = [UIImage imageNamed:@"ic_comments_c.png"];
                        lblDesc.text = @"COMMENTED YOUR POST";
                        break;
                    case reaction_like:
                        imgV.image = [UIImage imageNamed:@"ic_likes_c.png"];
                        lblDesc.text = @"LIKED YOUR POST";
                        break;
                    case reaction_reacted:
                        imgV.image = [UIImage imageNamed:@"ic_progress_c.png"];
                        
                        lblDesc.text = @"REACTED TO YOUR POST";
                        break;
                        
                    default:
                        break;
                }
                PFUser* user = reactObj[FIELD_REPORTER];
                if(user) {
                    [user fetchIfNeeded];
                    lblTitle.text = [NSString stringWithFormat:@"%@ %@", user[PARSE_USER_FIRSTNAME], user[PARSE_USER_LASTSTNAME] ];
                }
            }
            return cell;
        }else{
            static NSString* cellId = @"NoDataTableViewCell";
            NoDataTableViewCell* cell = (NoDataTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellId];
            if(cell){
                cell.lbl_noDate.text = @"You have no reactions at this moment.";
            }
            return cell;
        }
        
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0) {
        return 70;
    }
    else if(indexPath.section == 1) {
        return 70;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 40)];
    UIImageView* imgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    imgV.image = [UIImage imageNamed:@"ic_dot_big.png"];
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 300, 40)];
    if (section == 0){
        lbl.text = @"Friend Requests";
    }
    else if (section == 1) {
        lbl.text = @"Reactions";
    }
    [headerV addSubview:imgV];
    [headerV addSubview:lbl];
    return headerV;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%d      %d", indexPath.section, indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (void) getRequests {
    
    PFQuery * friendQuery2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [friendQuery2 whereKey:PARSE_FRIEND_RECEIVER equalTo:me];
    [friendQuery2 whereKey:PARSE_FRIEND_RECEIVER_ACCEPT equalTo:[NSNumber numberWithBool:NO]];
    [friendQuery2 includeKey:PARSE_FRIEND_SENDER];
    [friendQuery2 includeKey:PARSE_FRIEND_RECEIVER];
    [friendQuery2 orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:friendQuery2 vc:self handler:^(NSArray *resultObj) {
        [arr_request removeAllObjects];
        for(PFObject* obj in resultObj ) {
            PFUser * sender = obj[PARSE_FRIEND_SENDER];
            [arr_request addObject:sender];
        }
        [tableView reloadData];
    }];
}

- (void) getReactions {
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_REACT_NOTIFICATIONS];
    [query includeKeys:@[FIELD_OWNER]];
    [query whereKey:FIELD_OWNER equalTo: me];
    [query orderByDescending:@"updatedAt"];
    
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_reactions removeAllObjects];
        arr_reactions = [resultObj mutableCopy];
        [tableView reloadData];
        
    }];
}
- (BOOL) userArrayContainsUser:(PFUser*)user inArray:(NSArray*)array
{
    for(PFUser * sub in array){
        if([sub.objectId isEqualToString:user.objectId]){
            return YES;
        }
    }
    return NO;
}
- (void) tapAccept:(UITableViewCell *)cell{
    NSIndexPath* tappedIndex = [tableView indexPathForCell:cell];
    if (tappedIndex) {
        PFUser* user = arr_request[tappedIndex.row];
        
        [Util showWaitingMark];
        PFQuery * friendQuery1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
        [friendQuery1 whereKey:PARSE_FRIEND_SENDER equalTo:me];
        [friendQuery1 whereKey:PARSE_FRIEND_RECEIVER equalTo:user];
        PFQuery * friendQuery2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
        [friendQuery2 whereKey:PARSE_FRIEND_RECEIVER equalTo:me];
        [friendQuery2 whereKey:PARSE_FRIEND_SENDER equalTo:user];
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
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self getRequests];
                            });
                        }];
                    }];
                }
            }else{
                [Util hideWaitingMark];
            }
        }];
    }
}

- (void) tapDecline:(UITableViewCell *)cell{
    NSIndexPath* tappedIndex = [tableView indexPathForCell:cell];
    if (tappedIndex) {
        PFUser* user = arr_request[tappedIndex.row];
        [Util showWaitingMark];
        PFQuery * friendQuery1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
        [friendQuery1 whereKey:PARSE_FRIEND_SENDER equalTo:me];
        [friendQuery1 whereKey:PARSE_FRIEND_RECEIVER equalTo:user];
        PFQuery * friendQuery2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
        [friendQuery2 whereKey:PARSE_FRIEND_RECEIVER equalTo:me];
        [friendQuery2 whereKey:PARSE_FRIEND_SENDER equalTo:user];
        PFQuery * friendsQuery = [PFQuery orQueryWithSubqueries:@[friendQuery1, friendQuery2]];
        [Util findObjectsInBackground:friendsQuery vc:self handler:^(NSArray *resultObj) {
            if(resultObj && resultObj.count > 0){
                PFObject * request = [resultObj firstObject];
                [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    [Util hideWaitingMark];
                    [Util showAlertTitle:self title:STRING_SUCCESS message:@"Success" finish:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self getRequests];
                        });
                    }];
                }];
            }
        }];
    }
}
@end
