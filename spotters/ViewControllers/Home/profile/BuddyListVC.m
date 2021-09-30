//
//  BuddyListVC.m
//  Spotters
//
//  Created by developer on 6/19/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "BuddyListVC.h"
#import "BuddyProfileVC.h"

@interface BuddyListVC () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>{
    
    __weak IBOutlet UITableView *tableView;
    NSMutableArray* arr_buddy;
    NSMutableArray* search_arr_buddy;
    PFUser* me;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation BuddyListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableView.dataSource = self;
    tableView.delegate = self;
    arr_buddy = [NSMutableArray new];
    me = [PFUser currentUser];
    self.searchBar.delegate = self;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getBuddy];
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



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return search_arr_buddy.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"BuddyListTableViewCell"];
    UIImageView* imgV = (UIImageView*)[cell viewWithTag:1];
    UILabel* lblName = (UILabel*)[cell viewWithTag:2];
    PFUser* user = search_arr_buddy[indexPath.row];
    [user fetchIfNeeded];
    [Util setAvatar:imgV withUser:user];
    lblName.text = [NSString stringWithFormat:@"%@ %@", user[PARSE_USER_FIRSTNAME], user[PARSE_USER_LASTSTNAME]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BuddyProfileVC *vc = (BuddyProfileVC *)[Util getUIViewControllerFromStoryBoard:@"BuddyProfileVC"];
    PFUser* user = search_arr_buddy[indexPath.row];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) getBuddy{
    [Util showWaitingMark];
    [me fetchIfNeeded];
    arr_buddy = [NSMutableArray new];
    
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
                [arr_buddy addObject:receiver];
            }else{
                [arr_buddy addObject:sender];
            }
        }
        
        [Util hideWaitingMark];
        [self reloadSearchTable];
    }];
}
- (void) reloadSearchTable
{
    NSString * searchString = self.searchBar.text;
    search_arr_buddy = [NSMutableArray new];
    for(PFUser * user in arr_buddy){
        NSString * name = [NSString stringWithFormat:@"%@ %@", user[PARSE_USER_FIRSTNAME], user[PARSE_USER_LASTSTNAME]];
        if(searchString.length == 0){
            [search_arr_buddy addObject:user];
        }else{
            if([Util stringIsMatched:name searchKey:searchString]){
                [search_arr_buddy addObject:user];
            }
        }
    }
    [tableView reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
   [self reloadSearchTable];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self reloadSearchTable];
}
@end
