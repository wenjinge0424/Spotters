//
//  BuddyProfileVC.m
//  Spotters
//
//  Created by developer on 6/19/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "BuddyProfileVC.h"
#import "ChatViewController.h"
#import "ProfileTableViewCell.h"
#import "STDetailViewController.h"

@interface BuddyProfileVC () <UITableViewDelegate, UITableViewDataSource>{
    
    __weak IBOutlet UIImageView *imgAvatar;
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UILabel *lblAge;
    __weak IBOutlet UILabel *lblGym;
    __weak IBOutlet UILabel *lbl_bio;
    
    __weak IBOutlet UITableView *tableView;
    
    NSMutableArray *arr_posts;
    PFUser* me;
}

@end

@implementation BuddyProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util showWaitingMark];
    me = [PFUser currentUser];
    arr_posts = [[NSMutableArray alloc] init];
    if(self.user) {
        [Util setAvatar:imgAvatar withUser:self.user];
        lblName.text = [NSString stringWithFormat:@"%@ %@", self.user[PARSE_USER_FIRSTNAME], self.user[PARSE_USER_LASTSTNAME]];
        lbl_bio.text = [NSString stringWithFormat:@"About me: %@", self.user[PARSE_USER_BIO]];
        NSString * mainGymsId = self.user[PARSE_USER_MAINGYM];
        [Util getGymNameWithId:mainGymsId completionBlock:^(NSString * gymName){
            lblGym.text = gymName;
        }];
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_POST];
        [query includeKeys:@[FIELD_OWNER]];
        [query whereKey:FIELD_OWNER equalTo: self.user];
        [query orderByDescending:@"updatedAt"];
        
        [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
            [arr_posts removeAllObjects];
            arr_posts = [resultObj mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [Util hideWaitingMark];
                tableView.dataSource = self;
                tableView.delegate = self;
                [tableView reloadData];
            });
        }];
        
    }
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arr_posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProfileTableViewCell* cell = (ProfileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ProfileTableViewCell"];
    if(cell){
        PFObject * object = [arr_posts objectAtIndex:indexPath.row];
        UIImageView* imgV = (UIImageView*)[cell viewWithTag:1];
        UILabel* lblName = (UILabel*)[cell viewWithTag:2];
        UILabel* lblTime = (UILabel*)[cell viewWithTag:3];
        UIImageView* imgContent = (UIImageView*)[cell viewWithTag:4];
        UILabel* lblComment = (UILabel*)[cell viewWithTag:5];
        UILabel* lblProcess = (UILabel*)[cell viewWithTag:6];
        UILabel* lblLike = (UILabel*)[cell viewWithTag:7];
        [Util setAvatar:imgV withUser:self.user];
        lblName.text = [NSString stringWithFormat:@"%@ %@", self.user[PARSE_USER_FIRSTNAME], self.user[PARSE_USER_LASTSTNAME]];
        
        NSMutableArray * images = object[PARSE_POST_IMAGES];
        NSMutableArray * videos = object[PARSE_POST_VIDEO_THUMBS];
        NSDate* postedDate = object.updatedAt;
        lblTime.text = [Util getParseCommentDate:postedDate];
        PFFile * imageFile = nil;
        if(images.count > 0){
            imageFile = [images firstObject];
        }else if(videos.count > 0){
            imageFile = [videos firstObject];
        }
        if(imageFile){
            [Util setImage:imgContent imgFile:imageFile];
        }
        
        NSMutableArray * likedArray = object[PARSE_POST_LIKES];
        if(!likedArray) likedArray = [NSMutableArray new];
        lblLike.text = [NSString stringWithFormat:@"%lu", (unsigned long)likedArray.count];
        lblComment.text = [NSString stringWithFormat:@"%d", [object[PARSE_POST_COMMENT_COUNT] intValue]];
        lblProcess.text = @"0";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 400;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject * object = [arr_posts objectAtIndex:indexPath.row];
    STDetailViewController *vc = (STDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"STDetailViewController"];
    vc.posInfo = object;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
            }];
        }
        else {
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription finish:^{
            }];
        }
    }];
}
- (IBAction)onMessage:(id)sender {
    [self onMessages:self.user];
}
- (IBAction)onUnfriend:(id)sender {
    [Util showWaitingMark];
    PFQuery * friendQuery1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [friendQuery1 whereKey:PARSE_FRIEND_SENDER equalTo:me];
    [friendQuery1 whereKey:PARSE_FRIEND_RECEIVER equalTo:self.user];
    PFQuery * friendQuery2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIEND];
    [friendQuery2 whereKey:PARSE_FRIEND_RECEIVER equalTo:me];
    [friendQuery2 whereKey:PARSE_FRIEND_SENDER equalTo:self.user];
    PFQuery * friendsQuery = [PFQuery orQueryWithSubqueries:@[friendQuery1, friendQuery2]];
    [Util findObjectsInBackground:friendsQuery vc:self handler:^(NSArray *resultObj) {
        for(PFObject * obj in resultObj){
            [obj deleteInBackground];
        }
        [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}
@end
