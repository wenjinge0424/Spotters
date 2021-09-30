//
//  PostItem.m
//  spotters
//
//  Created by Techsviewer on 3/20/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "PostItem.h"
#import "CircleImageView.h"
#import "Utils.h"
#import "Config.h"

@interface PostItem ()
@property (weak, nonatomic) IBOutlet UIImageView *img_data;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet CircleImageView *img_userThumb;
@property (weak, nonatomic) IBOutlet UILabel *lbl_dateTime;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_mainGym;

@property (weak, nonatomic) IBOutlet UILabel *lbl_likeCount;
@property (weak, nonatomic) IBOutlet UILabel *lbl_processCount;
@property (weak, nonatomic) IBOutlet UILabel *lbl_commentCount;
@end

@implementation PostItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"PostItem" owner:self options:nil] firstObject];
    if(self){
        self.lbl_name.text = @"";
        self.lbl_dateTime.text = @"";
        self.lbl_title.text = @"";
        [self initializeSwipeDelegate];
        self.lbl_mainGym.text = @"";
        self.lbl_likeCount.text = @"";
        self.lbl_processCount.text = @"0";
        self.lbl_commentCount.text = @"";
        [self setFrame:frame];
    }
    return self;
}
- (void) initializeForLoad
{
    if(self.currentPost){
        dispatch_async(dispatch_get_main_queue(), ^{
            PFUser * postOwner = self.currentPost[PARSE_POST_OWNER];
            [Util setImage:self.img_userThumb imgFile:postOwner[PARSE_USER_AVATAR]];
            self.lbl_name.text = [NSString stringWithFormat:@"%@ %@", postOwner[PARSE_USER_FIRSTNAME], postOwner[PARSE_USER_LASTSTNAME]];
            NSDate * postedDate = self.currentPost.updatedAt;
            self.lbl_dateTime.text = [Util getParseCommentDate:postedDate];
            self.lbl_title.text = self.currentPost[FIELD_CAPTION];
            NSString * postGymId = self.currentPost[FIELD_BASEGYMID];
            [Util getGymNameWithId:postGymId completionBlock:^(NSString *gymname) {
                self.lbl_mainGym.text = gymname;
            }];
            NSMutableArray * imageArray = self.currentPost[PARSE_POST_IMAGES];
            NSMutableArray * thumbArray = self.currentPost[PARSE_POST_VIDEO_THUMBS];
            if(imageArray.count > 0){
                PFFile * firstImage = [imageArray firstObject];
                [Util setImage:self.img_data imgFile:firstImage];
            }else if(thumbArray.count > 0){
                PFFile * firstImage = [thumbArray firstObject];
                [Util setImage:self.img_data imgFile:firstImage];
            }
            NSMutableArray * likedArray = self.currentPost[PARSE_POST_LIKES];
            if(!likedArray) likedArray = [NSMutableArray new];
            self.lbl_likeCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)likedArray.count];
            self.lbl_commentCount.text = [NSString stringWithFormat:@"%d", [self.currentPost[PARSE_POST_COMMENT_COUNT] intValue]];
        });
    }
}
- (void) refreshView
{
    [Util showWaitingMark];
    [self.currentPost fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.currentPost = object;
        [Util hideWaitingMark];
        [self initializeForLoad];
    }];
}
@end
