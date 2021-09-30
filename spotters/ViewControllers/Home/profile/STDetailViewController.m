//
//  STDetailViewController.m
//  Spotters
//
//  Created by Techsviewer on 8/10/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "STDetailViewController.h"
#import "CircleImageView.h"
#import "ImageCollectionViewCell.h"
#import "MediaViewController.h"

#define RUN_TYPE_COMMENT  0
#define RUN_TYPE_LIKES    1
#define RUN_TYPE_PROGRESS    2

@interface STDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
{
    __weak IBOutlet CircleImageView *img_userThumb;
    __weak IBOutlet UILabel *img_userName;
    __weak IBOutlet UILabel *lbl_postTime;
    
    __weak IBOutlet UICollectionView *collectionData;
    __weak IBOutlet UISegmentedControl *seg_type;
    __weak IBOutlet UITableView *tbl_data;
    
    NSMutableArray * commentList;
    NSMutableArray * imageArray;
    NSMutableArray * thumbArray;
    NSMutableArray * videoArray;
    
    int appRunType;
    NSMutableArray * m_showData;
    __weak IBOutlet UIPageControl *pageControl;
}
@end

@implementation STDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFUser * postOwner = self.posInfo[PARSE_POST_OWNER];
    PFFile * userThumb = postOwner[PARSE_USER_AVATAR];
    [Util setImage:img_userThumb imgFile:userThumb];
    img_userName.text = [NSString stringWithFormat:@"%@ %@", postOwner[PARSE_USER_FIRSTNAME], postOwner[PARSE_USER_LASTSTNAME]];
    NSDate* postedDate = self.posInfo.updatedAt;
    lbl_postTime.text = [Util getParseCommentDate:postedDate];
    
    imageArray = self.posInfo[PARSE_POST_IMAGES];
    thumbArray = self.posInfo[PARSE_POST_VIDEO_THUMBS];
    videoArray = self.posInfo[PARSE_POST_VIDEOS];
    collectionData.pagingEnabled = YES;
    collectionData.delegate = self;
    collectionData.dataSource = self;
    [collectionData reloadData];
    
    pageControl.numberOfPages = imageArray.count + thumbArray.count;
    [pageControl setCurrentPage:0];
    
    appRunType = RUN_TYPE_COMMENT;
    [self fetchData];
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) fetchData
{
    m_showData = [NSMutableArray new];
    [Util showWaitingMark];
    if(appRunType == RUN_TYPE_COMMENT){
        commentList = [NSMutableArray new];
        PFQuery* commentQuery = [PFQuery queryWithClassName:PARSE_TABLE_COMMENT];
        [commentQuery whereKey:PARSE_COMMENT_POST equalTo:self.posInfo];
        [commentQuery includeKeys:@[PARSE_COMMENT_OWNER]];
        [Util findObjectsInBackground:commentQuery vc:self handler:^(NSArray *resultObj) {
            if(resultObj){
                commentList = [[NSMutableArray alloc] initWithArray:resultObj];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [Util hideWaitingMark];
                m_showData = commentList;
                tbl_data.delegate = self;
                tbl_data.dataSource = self;
                [tbl_data reloadData];
            });
        }];
    }else if(appRunType == RUN_TYPE_LIKES){
        NSMutableArray * likes = self.posInfo[PARSE_POST_LIKES];
        m_showData = likes;
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util hideWaitingMark];
            tbl_data.delegate = self;
            tbl_data.dataSource = self;
            [tbl_data reloadData];
        });
    }else if(appRunType == RUN_TYPE_PROGRESS){
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util hideWaitingMark];
            tbl_data.delegate = self;
            tbl_data.dataSource = self;
            [tbl_data reloadData];
        });
    }
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSelectType:(id)sender {
    if(seg_type.selectedSegmentIndex == 0){
        appRunType = RUN_TYPE_COMMENT;
    }else if(seg_type.selectedSegmentIndex == 1){
        appRunType = RUN_TYPE_LIKES;
    }else if(seg_type.selectedSegmentIndex == 2){
        appRunType = RUN_TYPE_PROGRESS;
    }
    [self fetchData];
}

#pragma mark CollectionView delegate & datasource
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [imageArray count] + [thumbArray count];
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
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    if(cell){
        if(indexPath.row < imageArray.count){
            PFFile * imageFile = [imageArray objectAtIndex:indexPath.row];
            [Util setImage:cell.img_thumb imgFile:imageFile];
            [cell.btn_play setHidden:YES];
        }else{
            int index = (int)indexPath.row - (int)imageArray.count;
            PFFile * imageFile = [thumbArray objectAtIndex:index];
            [Util setImage:cell.img_thumb imgFile:imageFile];
            [cell.btn_play setHidden:NO];
            cell.btn_play.tag = index;
            [cell.btn_play addTarget:self action:@selector(onPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [pageControl setCurrentPage:indexPath.row];
}

- (void) onPlayVideo:(UIButton*)button
{
    PFFile * videoFile = [videoArray objectAtIndex:button.tag];
    if(videoFile){
        MediaViewController *vc = (MediaViewController *)[Util getUIViewControllerFromStoryBoard:@"MediaViewController"];
        vc.video = (PFFile*)videoFile;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [m_showData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(appRunType == RUN_TYPE_COMMENT){
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PostDetailTableViewCell"];
        if(cell){
            UIImageView* imgV = (UIImageView*)[cell viewWithTag:1];
            UILabel* lblName = (UILabel*)[cell viewWithTag:2];
            UILabel* lblTime = (UILabel*)[cell viewWithTag:3];
            UILabel* lblDesc = (UILabel*)[cell viewWithTag:4];
            PFObject * obj = [m_showData objectAtIndex:indexPath.row];
            NSDate* postedDate = obj.updatedAt;
            lblTime.text = [Util getParseCommentDate:postedDate];
            lblDesc.text = obj[PARSE_COMMENT_TEXT];
            PFUser * sender = obj[PARSE_COMMENT_OWNER];
            [sender fetchIfNeeded];
            lblName.text = [NSString stringWithFormat:@"%@ %@", sender[PARSE_USER_FIRSTNAME], sender[PARSE_USER_LASTSTNAME]];
            PFFile * imageF = sender[PARSE_USER_AVATAR];
            [Util setImage:imgV imgFile:imageF];
        }
        return cell;
    }else if(appRunType == RUN_TYPE_LIKES){//PostDetailTableViewCellLike
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PostDetailTableViewCellLike"];
        if(cell){
            UIImageView* imgV = (UIImageView*)[cell viewWithTag:1];
            UILabel* lblName = (UILabel*)[cell viewWithTag:2];
            lblName.text = @"";
            PFUser * postOwner = [m_showData objectAtIndex:indexPath.row];
            [postOwner fetchIfNeeded];
            PFFile * userThumb = postOwner[@"avatar"];
            [Util setImage:imgV imgFile:userThumb];
            lblName.text = [NSString stringWithFormat:@"%@ %@", postOwner[@"firstName"], postOwner[@"lastName"]];
        }
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(appRunType == RUN_TYPE_COMMENT){
        return 100;
    }else if(appRunType == RUN_TYPE_LIKES){
        return 60;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
