//
//  MyProfileVC.m
//  Spotters
//
//  Created by developer on 6/19/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "MyProfileVC.h"
#import "ProfileTableViewCell.h"
#import "STDetailViewController.h"
#import "EditPostVC.h"

@interface MyProfileVC () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ProfileCellDelegate>{
    __weak IBOutlet UIImageView *imgAvatar;
    __weak IBOutlet UILabel *lblNotificationCnt;
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UILabel *lblAge;
    __weak IBOutlet UILabel *lblGym;
    __weak IBOutlet UITableView *tableView;
    PFUser* me;
    NSMutableArray *arr_posts;
    NSMutableArray *arr_images;
    NSMutableArray *arr_thumbs;
    NSMutableArray *arr_res;
    NSIndexPath* tappedIndex;

}

@end

@implementation MyProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lblNotificationCnt.text = @"( 3 )";
    tableView.dataSource = self;
    tableView.delegate = self;
    arr_posts = [[NSMutableArray alloc] init];
    arr_images = [[NSMutableArray alloc] init];
    arr_thumbs = [[NSMutableArray alloc] init];
    arr_res = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    me = [PFUser currentUser];
    [self loadProfile];
    [self getMyPosts];
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
    return arr_posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProfileTableViewCell* cell = (ProfileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ProfileTableViewCell"];
    if(cell){
        PFObject * object = [arr_posts objectAtIndex:indexPath.row];
        
        cell.delegate = self;
        UIImageView* imgV = (UIImageView*)[cell viewWithTag:1];
        UILabel* lblName = (UILabel*)[cell viewWithTag:2];
        UILabel* lblTime = (UILabel*)[cell viewWithTag:3];
        UIImageView* imgContent = (UIImageView*)[cell viewWithTag:4];
        UILabel* lblComment = (UILabel*)[cell viewWithTag:5];
        UILabel* lblProcess = (UILabel*)[cell viewWithTag:6];
        UILabel* lblLike = (UILabel*)[cell viewWithTag:7];
        [Util setAvatar:imgV withUser:me];
        lblName.text = [NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FIRSTNAME], me[PARSE_USER_LASTSTNAME]];
        
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
    //    UIViewController *vc = (UIViewController *)[Util getUIViewControllerFromStoryBoard:@"AdminReportedUserDetailVC"];
    //    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onEdit:(id)sender {
    [self gotoEditProfileVC];
}


#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self editPost];
            break;
            
        case 1:
            [self deletePost];
            
            break;
            
        default:
            break;
    }
}

- (void) gotoEditProfileVC {
    UIViewController *vc = (UIViewController *)[Util getUIViewControllerFromStoryBoard:@"EditProfileVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onEditPost:(id)sender {
    
    
    
}
- (IBAction)onGotoBuddyList:(id)sender {
    UIViewController *vc = (UIViewController *)[Util getUIViewControllerFromStoryBoard:@"BuddyListVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) loadProfile {
    [Util setAvatar:imgAvatar withUser:me];
    lblName.text = [NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FIRSTNAME], me[PARSE_USER_LASTSTNAME]];
    NSString * gymId = me[PARSE_USER_MAINGYM];
    [Util getGymNameWithId:gymId completionBlock:^(NSString* gymName){
        lblGym.text = gymName;
    }];
}

- (void) editPost {
    EditPostVC *vc = (EditPostVC *)[Util getUIViewControllerFromStoryBoard:@"EditPostVC"];
    vc.mType = p_t_editPost;
    if (tappedIndex) {
        if (tappedIndex.row < arr_posts.count) {
            PFObject* postObj = arr_posts[tappedIndex.row];
            if(postObj) {
                vc.postObj = postObj;
            }
        }
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) deletePost {
    if (tappedIndex){
        if (tappedIndex.row < arr_posts.count) {
            PFObject* delObj = arr_posts[tappedIndex.row];
            if(delObj) {
                [delObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded) {
                        [self getMyPosts];
                    }
                }];
            }
            
        }
    }
}

- (void) getMyPosts {
    [arr_images removeAllObjects];
    [arr_thumbs removeAllObjects];
    [arr_res removeAllObjects];
    [arr_posts removeAllObjects];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_POST];
    [query includeKeys:@[PARSE_POST_OWNER]];
    [query whereKey:PARSE_POST_OWNER equalTo: me];
    [query orderByDescending:@"updatedAt"];
    
    [Util showWaitingMark];
    [Util findObjectsInBackground:query vc:self handler:^(NSArray *resultObj) {
        [arr_posts removeAllObjects];
        arr_posts = [resultObj mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
    }];
}

- (void) tapEditBtn:(UITableViewCell *)cell{
    tappedIndex = [tableView indexPathForCell:cell];
    if(tappedIndex) {
        NSString *edit = @"Edit";
        NSString *Delete = @"Delete";
        NSString *cancelTitle = @"Cancel";
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:edit, Delete, nil];
        [actionSheet showInView:self.view];
    }
}

- (void) tapPostDetail:(UITableViewCell *)cell{
    tappedIndex = [tableView indexPathForCell:cell];
    if(tappedIndex) {
        PFObject * object = [arr_posts objectAtIndex:(int)tappedIndex.row];
        STDetailViewController *vc = (STDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"STDetailViewController"];
        vc.posInfo = object;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}
@end
