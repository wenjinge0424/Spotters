//
//  SpotUserView.m
//  spotters
//
//  Created by Techsviewer on 3/18/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SpotUserView.h"
#import "CircleImageView.h"
#import "Utils.h"
#import "Config.h"
#import "SubImageCollectionViewCell.h"
#import "MediaViewController.h"

@interface SpotUserView()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray * extraImages;
}
@property (weak, nonatomic) IBOutlet CircleImageView *imgThumb;
@property (weak, nonatomic) IBOutlet UILabel *lbl_userName;
@property (weak, nonatomic) IBOutlet UILabel *txtNote;
@property (weak, nonatomic) IBOutlet UICollectionView *m_dataCollection;


@end


@implementation SpotUserView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"SpotUserView" owner:self options:nil] firstObject];
    if(self){
        self.imgThumb.layer.borderWidth = 0.1f;
        self.lbl_userName.text = @"";
        self.txtNote.text = @"";
        [self initializeSwipeDelegate];
        [self setFrame:frame];
        [self.m_dataCollection registerNib:[UINib nibWithNibName:@"SubImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SubImageCollectionViewCell"];
    }
    return self;
}
- (void) initializeForLoad
{
    if(self.currentUser){
        [Util setAvatar:self.imgThumb withUser:self.currentUser];
        self.lbl_userName.text = [NSString stringWithFormat:@"%@ %@", self.currentUser[PARSE_USER_FIRSTNAME], self.currentUser[PARSE_USER_LASTSTNAME] ];
        self.txtNote.text = self.currentUser[PARSE_USER_BIO];
        extraImages = [[NSMutableArray alloc] initWithArray:self.currentUser[PARSE_USER_EXTRAAVATAR]];
        if(!extraImages || extraImages.count != 4){
            extraImages = [NSMutableArray new];
            for(int i = 0;i<4;i++){
                [extraImages addObject:[NSNull new]];
            }
        }
        [self reloadCollectionView];
    }
}
- (void) reloadCollectionView
{
    self.m_dataCollection.scrollEnabled = YES;
    self.m_dataCollection.delegate = self;
    self.m_dataCollection.dataSource = self;
    [self.m_dataCollection reloadData];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}
- (CGSize) collectionView:(UICollectionView *) collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    int nHeight = (CGRectGetHeight(collectionView.frame));
    return CGSizeMake(nHeight, nHeight);
}
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SubImageCollectionViewCell" forIndexPath:indexPath];
    if(cell){
        NSObject * imgObj = [extraImages objectAtIndex:indexPath.row];
        if([imgObj isKindOfClass:[UIImage class]]){
            [cell.imgThumb setImage:(UIImage*)imgObj];
        }else if([imgObj isKindOfClass:[PFFile class]]){
            PFFile * imgFile = (PFFile*)imgObj;
            [Util setImage:cell.imgThumb imgFile:imgFile];
        }else{
            [cell.imgThumb setImage:[UIImage imageNamed:@"noAvatar.png"]];
        }
    }
    return cell;
}
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    NSObject * imgObj = [extraImages objectAtIndex:indexPath.row];
    if(self.navController && [imgObj isKindOfClass:[PFFile class]]){
        MediaViewController *vc = (MediaViewController *)[Util getUIViewControllerFromStoryBoard:@"MediaViewController"];
        vc.pf_image = (PFFile*)imgObj;
        [self.navController pushViewController:vc animated:YES];
    }
}
@end
