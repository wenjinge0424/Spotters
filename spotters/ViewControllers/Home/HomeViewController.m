//
//  HomeViewController.m
//  spotters
//
//  Created by Techsviewer on 3/15/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "HomeViewController.h"
#import "MyProfileVC.h"
#import "EditPostVC.h"
#import "SpotThemViewController.h"
#import "MessagesVC.h"
#import "PostContainerCollectionViewCell.h"
#import "PostItem.h"
#import "SwipeAbleView.h"
#import "STDetailViewController.h"

@interface HomeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, SwipeAbleViewDelegate, UITextFieldDelegate>
{
    PFUser * me;
    NSMutableArray * myFriendList;
    NSMutableArray * postList;
    NSMutableArray * myGymList;
    
    int currentPageIndex;
}
@property (weak, nonatomic) IBOutlet UICollectionView *dataCollection;
@property (nonatomic, retain) SwipeAbleView * swipeView;
@property (weak, nonatomic) IBOutlet UITextField *edtComment;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edtComment.delegate = self;
    UIColor *color = [UIColor whiteColor];
    self.edtComment.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edtComment.placeholder attributes:@{NSForegroundColorAttributeName: color}];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData];
}
- (void) fetchData
{
    me = [PFUser currentUser];
    myFriendList = [NSMutableArray new];
    myGymList = [NSMutableArray new];
    currentPageIndex = 0;
    [Util showWaitingMark];
    [me fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        [myGymList addObject:me[PARSE_USER_MAINGYM]];
        [myGymList addObjectsFromArray:me[PARSE_USER_SECONDGYMS]];
        
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
            [Util hideWaitingMark];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dataCollection.delegate = self;
                self.dataCollection.dataSource = self;
                self.dataCollection.pagingEnabled = YES;
                self.dataCollection.showsVerticalScrollIndicator = NO;
                self.dataCollection.showsHorizontalScrollIndicator = NO;
                [self.dataCollection reloadData];
            });
        }];
    }];
}

- (void) reloadViewWithGymId:(NSString*)gymId atContainerView:(UIView*)container withNoDataLabel:(UILabel*)noLabel
{
    [Util showWaitingMark];
    [noLabel setHidden:YES];
    postList=  [NSMutableArray new];
    
    PFQuery * postQuery = [PFQuery queryWithClassName:PARSE_TABLE_POST];
    [postQuery whereKey:FIELD_BASEGYMID equalTo:gymId];
    [postQuery whereKey:PARSE_POST_UNLIKES notContainedIn:@[me]];
    [postQuery includeKey:PARSE_POST_OWNER];
    [postQuery orderByAscending:PARSE_FIELD_UPDATED_AT];
    [Util findObjectsInBackground:postQuery vc:self handler:^(NSArray *resultObj) {
        for(PFObject * sub in resultObj){
            [postList addObject:sub];
        }
        [Util hideWaitingMark];
        dispatch_async(dispatch_get_main_queue(), ^{
            for(UIView * subView in container.subviews){
                [subView removeFromSuperview];
            }
            if(postList.count == 0){
                [noLabel setHidden:NO];
            }else{
                [noLabel setHidden:YES];
                self.swipeView = [[SwipeAbleView alloc] initWithFrame:container.bounds];
                self.swipeView.delegate = self;
                [container addSubview:self.swipeView];
                NSMutableArray * swipeAbleViews = [NSMutableArray new];
                for(PFObject * post in postList){
                    PostItem * view = [[PostItem alloc] initWithFrame:self.swipeView.bounds];
                    view.currentPost = post;
                    view.btn_action.tag = [postList indexOfObject:post];
                    [swipeAbleViews addObject:view];
                    [view.btn_action addTarget:self action:@selector(onSelectPostAt:) forControlEvents:UIControlEventTouchUpInside];
                }
                self.swipeView.allCards =  swipeAbleViews;
                [self.swipeView loadCards];
            }
        });
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
#pragma mark CollectionView delegate & datasource
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [myGymList count];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (CGSize) collectionView:(UICollectionView *) collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    int nWidth = (CGRectGetWidth(collectionView.frame));
    int nHeight = (CGRectGetHeight(collectionView.frame));
    return CGSizeMake(nWidth, nHeight);
}
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PostContainerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostContainerCollectionViewCell" forIndexPath:indexPath];
    if(cell){
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    currentPageIndex = (int)indexPath.row;
    if([cell isKindOfClass:[PostContainerCollectionViewCell class]]){
        PostContainerCollectionViewCell * customCell = (PostContainerCollectionViewCell*) cell;
        [self reloadViewWithGymId:[myGymList objectAtIndex:currentPageIndex] atContainerView:customCell.containerView withNoDataLabel:customCell.lbl_noResult];
    }
}
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}
- (BOOL) isFriend:(PFUser*)user
{
    for (PFUser * subUser in myFriendList) {
        if([subUser.objectId isEqualToString:user.objectId]){
            return YES;
        }
    }
    return NO;
}
- (void)onSelectPostAt:(UIButton*)button
{
    int index = (int)button.tag;
    if(postList.count > index){
        PFObject * postObj = [postList objectAtIndex:index];
        PFUser * postOwner = postObj[PARSE_POST_OWNER];
        if([self isFriend:postOwner]){
            STDetailViewController *vc = (STDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"STDetailViewController"];
            vc.posInfo = postObj;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [Util showAlertTitle:self title:@"Error" message:@"You have no permission to read this post."];
        }
    }
}
- (void)selectCardSwipedRight:(UIView *)card
{
    if([card isKindOfClass:[PostItem class]]){
        PFObject * postObj = ((PostItem*)card).currentPost;
        PFUser * postOwner = postObj[PARSE_POST_OWNER];
        NSMutableArray * likeArray = postObj[PARSE_POST_LIKES];
        BOOL alreadyLikes = NO;
        for(PFUser * subUser in likeArray){
            if([subUser.objectId isEqualToString:me.objectId]){
                alreadyLikes = YES;
            }
        }
        if(!alreadyLikes){
            [Util showWaitingMark];
            if(!likeArray || likeArray.count == 0)
                likeArray = [NSMutableArray new];
            [likeArray addObject:me];
            postObj[PARSE_POST_LIKES] = likeArray;
            [postObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                PFObject * notificationObj = [PFObject objectWithClassName:PARSE_TABLE_REACT_NOTIFICATIONS];
                notificationObj[FIELD_REACT_TYPE] = [NSNumber numberWithInt:reaction_like];
                notificationObj[FIELD_REPORTER] = me;
                notificationObj[FIELD_OWNER] = postOwner;
                [notificationObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    [Util hideWaitingMark];
                    NSString * message = [NSString stringWithFormat:@"%@ %@ like your post.", me[PARSE_USER_FIRSTNAME], me[PARSE_USER_LASTSTNAME]];
                    [Util sendPushNotification:postOwner[PARSE_USER_EMAIL] message:message type:PUSH_TYPE_LIKE];
                }];
            }];
        }
    }
}
- (void) selectCardSwipedLeft:(UIView *)card
{
    if([card isKindOfClass:[PostItem class]]){
        PFObject * postObj = ((PostItem*)card).currentPost;
        NSMutableArray * unLikeArray = postObj[PARSE_POST_UNLIKES];
        BOOL alreadyUnLikes = NO;
        for(PFUser * subUser in unLikeArray){
            if([subUser.objectId isEqualToString:me.objectId]){
                alreadyUnLikes = YES;
            }
        }
        if(!alreadyUnLikes){
            [Util showWaitingMark];
            if(!unLikeArray || unLikeArray.count == 0)
                unLikeArray = [NSMutableArray new];
            [unLikeArray addObject:me];
            postObj[PARSE_POST_UNLIKES] = unLikeArray;
            [postObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [Util hideWaitingMark];
            }];
        }
    }
}
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    UIView * currentPostView = [self.swipeView currentLoadingView];
    if(currentPostView && [currentPostView isKindOfClass:[PostItem class]]){
        PFObject * postObj = ((PostItem*)currentPostView).currentPost;
        if(postObj){
            PFUser * owner = postObj[PARSE_POST_OWNER];
            if([self isFriend:owner]){
                return YES;
            }
        }
    }
    return NO;
}
- (IBAction)onSendComment:(id)sender {
    UIView * currentPostView = [self.swipeView currentLoadingView];
    if(currentPostView && [currentPostView isKindOfClass:[PostItem class]]){
        PFObject * postObj = ((PostItem*)currentPostView).currentPost;
        if(postObj){
            PFUser * owner = postObj[PARSE_POST_OWNER];
            if([self isFriend:owner]){
                if(self.edtComment.text.length == 0){
                    [Util showAlertTitle:self title:@"Error" message:@"Please enter comment text."];
                }else{
                    [Util showWaitingMark];
                    PFObject* comment = [PFObject objectWithClassName:PARSE_TABLE_COMMENT];
                    [comment setObject:me forKey:FIELD_OWNER];
                    [comment setObject:postObj forKey:PARSE_COMMENT_POST];
                    [comment setObject:self.edtComment.text forKey:PARSE_COMMENT_TEXT];
                    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        int commentCount = [postObj[PARSE_POST_COMMENT_COUNT] intValue];
                        postObj[PARSE_POST_COMMENT_COUNT] = [NSNumber numberWithInt:commentCount + 1];
                        [postObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            
                            PFObject * notificationObj = [PFObject objectWithClassName:PARSE_TABLE_REACT_NOTIFICATIONS];
                            notificationObj[FIELD_REACT_TYPE] = [NSNumber numberWithInt:reaction_comment];
                            notificationObj[FIELD_REPORTER] = me;
                            notificationObj[FIELD_OWNER] = owner;
                            [notificationObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                [Util hideWaitingMark];
                                
                                [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                                    PostItem * customView = (PostItem*)currentPostView;
                                    [customView refreshView];
                                    
                                    NSString * message = [NSString stringWithFormat:@"%@ %@ comment to your post.", me[PARSE_USER_FIRSTNAME], me[PARSE_USER_LASTSTNAME]];
                                    [Util sendPushNotification:owner[PARSE_USER_EMAIL] message:message type:PUSH_TYPE_COMMENT];
                                }];
                            }];
                        }];
                    }];
                }
            }else{
                [Util showAlertTitle:self title:@"Error" message:@"You have no permission to read this post."];
            }
        }
    }
}
//////// action
- (IBAction)onGotoMyProfile:(id)sender {
    MyProfileVC * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MyProfileVC"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onPOst:(id)sender {
    EditPostVC *vc = (EditPostVC *)[Util getUIViewControllerFromStoryBoard:@"EditPostVC"];
    vc.mType = p_t_newPost;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onGotoSetting:(id)sender {
    UIViewController *vc = (UIViewController *)[Util getUIViewControllerFromStoryBoard:@"SettingVC"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onNotification:(id)sender {
    UIViewController *vc = (UIViewController *)[Util getUIViewControllerFromStoryBoard:@"NotificationsVC"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onSpotThem:(id)sender {
    SpotThemViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SpotThemViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onMessage:(id)sender {
    MessagesVC * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MessagesVC"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
