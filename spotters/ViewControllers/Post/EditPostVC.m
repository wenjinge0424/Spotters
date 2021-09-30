//
//  EditPostVC.m
//  Spotters
//
//  Created by developer on 6/19/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "EditPostVC.h"
#import "AddPostTapCameraVC.h"
#import "ELCImagePickerHeader.h"
#import "MediaViewController.h"

@interface EditPostVC () <ELCImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MyCaptureDelegate, IQDropDownTextFieldDelegate>{
    
    __weak IBOutlet UIButton *btnCancel;
    __weak IBOutlet UIImageView *imgBack;
    
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UIButton *btnSave;
    __weak IBOutlet UIImageView *imgSend;
    __weak IBOutlet UIImageView *imgAvatar;
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UITextField *edt_caption;
    
    
    __weak IBOutlet UIImageView *imgPhotoDesc;
    __weak IBOutlet UILabel *lblPhotoDesc;
    __weak IBOutlet UIButton *btnPhotoDeleteAll;
    
    
    __weak IBOutlet UIImageView *imgVideoDesc;
    __weak IBOutlet UILabel *lblVideoDesc;
    __weak IBOutlet UIButton *btnVideoDeleteAll;
    
    PFUser* me;
    
    __weak IBOutlet UICollectionView *photoCollectionView;
    __weak IBOutlet UICollectionView *videoCollectionView;
    
    __weak IBOutlet IQDropDownTextField *edt_gynName;
    NSString * selectedGymId;
    NSMutableArray * gymNameList;
    NSMutableArray * myGymList;
}

@end

@implementation EditPostVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    
    edt_gynName.delegate = self;
    gymNameList = [NSMutableArray new];
    myGymList = [NSMutableArray new];
    NSMutableArray * mainGyms =  [NSMutableArray new];
    [mainGyms addObject:me[PARSE_USER_MAINGYM]];
    [mainGyms addObjectsFromArray:me[PARSE_USER_SECONDGYMS]];
    [Util showWaitingMark];
    [Util getGymNamesWithIds:mainGyms completionBlock:^(NSMutableArray * gymObjects){
        [Util hideWaitingMark];
        for(PFObject * object in gymObjects){
            NSString * strGymName = object[FIELD_SPECIALGYM_NAME];
            [gymNameList addObject:strGymName];
            [myGymList addObject:object];
        }
        edt_gynName.itemList = gymNameList;
        
        if(_mType == p_t_newPost){
            NSMutableArray * mainGyms =  [NSMutableArray new];
            [mainGyms addObject:me[PARSE_USER_MAINGYM]];
            [mainGyms addObjectsFromArray:me[PARSE_USER_SECONDGYMS]];
            selectedGymId = [mainGyms firstObject];
            [Util getGymNameWithId:selectedGymId completionBlock:^(NSString * gymName){
                edt_gynName.text = gymName;
            }];
            
            [imgBack setHidden:NO];
            [btnCancel setTitle:@"" forState:UIControlStateNormal];
            lblTitle.text = @"Add Post";
            [imgSend setHidden:NO];
            [btnSave setTitle:@"" forState:UIControlStateNormal];
            
        }
        else{
            [imgBack setHidden:YES];
            [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
            lblTitle.text = @"Edit Post";
            [imgSend setHidden:YES];
            [btnSave setTitle:@"Save" forState:UIControlStateNormal];
            selectedGymId = self.postObj[FIELD_BASEGYMID];
            [Util getGymNameWithId:selectedGymId completionBlock:^(NSString * gymName){
                edt_gynName.text = gymName;
            }];
            if(self.postObj)
                edt_caption.text = self.postObj[FIELD_CAPTION];
        }
        
        photoCollectionView.dataSource = self;
        photoCollectionView.delegate = self;
        videoCollectionView.dataSource = self;
        videoCollectionView.delegate = self;
        if(_mType == p_t_newPost){
            self.chosenImages = [[NSMutableArray alloc] init];
            self.chosenVideos = [[NSMutableArray alloc] init];
            self.chosenImgThumbs = [[NSMutableArray alloc] init];
        }else{
            self.chosenImages = self.postObj[PARSE_POST_IMAGES];
            self.chosenVideos = self.postObj[PARSE_POST_VIDEOS];
            self.chosenImgThumbs = self.postObj[PARSE_POST_VIDEO_THUMBS];
        }
        [self refreshPhotoCV];
        [self refreshVideoCV];
        
        
        me = [PFUser currentUser];
        [self loadProfile];
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == edt_gynName){
        NSInteger currentIndex = [gymNameList indexOfObject:edt_gynName.selectedItem];
        PFObject * gymItem = [myGymList objectAtIndex:currentIndex];
        selectedGymId = gymItem.objectId;
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
- (IBAction)onTapCamera:(id)sender {
    AddPostTapCameraVC *vc = (AddPostTapCameraVC *)[Util getUIViewControllerFromStoryBoard:@"AddPostTapCameraVC"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onTapGallery:(id)sender {
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    
    elcPicker.maximumImagesCount = 30; //Set the maximum number of images to select to 100
    elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
    elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
    elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
    elcPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie]; //Supports image and movie types
    
    elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) loadProfile {
    [Util setAvatar:imgAvatar withUser:me];
    lblName.text = [NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FIRSTNAME], me[PARSE_USER_LASTSTNAME]];
}

//select photo

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                if(image) {
                    if ([self.chosenImages count] < 30) {
                        [self.chosenImages addObject:image];
                    }
                }
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
            if ([dict objectForKey:UIImagePickerControllerReferenceURL]){
                NSData *data = [dict objectForKey:UIImagePickerControllerReferenceURL];
                if (data) {
                    if([self.chosenVideos count] < 5) {
                        [self.chosenVideos addObject:data];
                    }
                }
                
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                if (image) {
                    if ([self.chosenImgThumbs count] < 5) {
                        [self.chosenImgThumbs addObject:image];
                    }
                }
                
                
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }
    }
    
    [self refreshPhotoCV];
    [self refreshVideoCV];
    
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) refreshPhotoCV{
    BOOL isHidePhoto = [self.chosenImages count] == 0;
    [imgPhotoDesc setHidden: isHidePhoto];
    [lblPhotoDesc setHidden:isHidePhoto];
    lblPhotoDesc.text = [NSString stringWithFormat:@"Added Photo | %lu", [self.chosenImages count] ];
    [btnPhotoDeleteAll setHidden:isHidePhoto];
    [photoCollectionView reloadData];
    
}

- (void) refreshVideoCV{
    BOOL isHideVideo = [self.chosenImgThumbs count] == 0;
    [imgVideoDesc setHidden:isHideVideo];
    [lblVideoDesc setHidden:isHideVideo];
    lblVideoDesc.text = [NSString stringWithFormat:@"Added Video | %lu", [self.chosenImgThumbs count] ];
    [btnVideoDeleteAll setHidden:isHideVideo];
    [videoCollectionView reloadData];
}



#pragma mark CollectionView delegate & datasource
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == photoCollectionView) {
        return self.chosenImages.count;
    }
    else if (collectionView == videoCollectionView) {
        return self.chosenImgThumbs.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == photoCollectionView) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
        UIImageView *imgV = (UIImageView *)[cell viewWithTag:1];
        NSObject * imageObj = self.chosenImages[indexPath.row];
        if([imageObj isKindOfClass:[UIImage class]]){
            imgV.image = self.chosenImages[indexPath.row];
        }else if([imageObj isKindOfClass:[PFFile class]]){
            [Util setImage:imgV imgFile:(PFFile*)imageObj];
        }
        return cell;
    }
    else if (collectionView == videoCollectionView) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"videoCell" forIndexPath:indexPath];
        UIImageView *imgV = (UIImageView *)[cell viewWithTag:1];
        NSObject * imageObj = self.chosenImgThumbs[indexPath.row];
        if([imageObj isKindOfClass:[UIImage class]]){
            imgV.image = self.chosenImgThumbs[indexPath.row];
        }else if([imageObj isKindOfClass:[PFFile class]]){
            [Util setImage:imgV imgFile:(PFFile*)imageObj];
        }
        return cell;
    }
    
    return [[UICollectionViewCell alloc] init];
    
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == photoCollectionView) {
        NSObject * imageObj = self.chosenImages[indexPath.row];
        MediaViewController *vc = (MediaViewController *)[Util getUIViewControllerFromStoryBoard:@"MediaViewController"];
        if([imageObj isKindOfClass:[UIImage class]]){
            vc.image = (UIImage*)imageObj;
        }else if([imageObj isKindOfClass:[PFFile class]]){
            vc.pf_image = (PFFile*)imageObj;
        }
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (collectionView == videoCollectionView) {
        NSObject * videoObj = self.chosenVideos[indexPath.row];
        MediaViewController *vc = (MediaViewController *)[Util getUIViewControllerFromStoryBoard:@"MediaViewController"];
        if([videoObj isKindOfClass:[PFFile class]]){
            vc.video = (PFFile*)videoObj;
        }else if([videoObj isKindOfClass:[NSData class]]){
            vc.localVideoData = (NSData*)videoObj;
        }else if([videoObj isKindOfClass:[NSString class]]){
            vc.localVideoUrl = (NSString*)videoObj;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGSize) collectionView:(UICollectionView *) collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    int nWidth = (CGRectGetWidth(collectionView.frame)  ) / 4;
    int nHeight = nWidth;
    return CGSizeMake(nWidth, nHeight);
}
- (IBAction)onDeleteAllPhotos:(id)sender {
    [self.chosenImages removeAllObjects];
    [self refreshPhotoCV];
}
- (IBAction)onDeleteAllVideos:(id)sender {
    [self.chosenImgThumbs removeAllObjects];
    [self.chosenVideos removeAllObjects];
    [self refreshVideoCV];
}

- (void) myCaptureDelegate:(UIImage *)capturedImage{
    if(self.chosenImages.count >= 30){
        [Util showAlertTitle:self title:@"" message:@"You can't add more photos."];
        return;
    }
    [self.chosenImages addObject:capturedImage];
    [self refreshPhotoCV];
}

- (void) myCaptureVideoThumbDelegate:(UIImage *)capturedVideoThumb :(NSString*)videoFilePath{
    if(self.chosenImgThumbs.count >= 5){
        [Util showAlertTitle:self title:@"" message:@"You can't add more videos."];
        return;
    }
    [self.chosenImgThumbs addObject:capturedVideoThumb];
    [self.chosenVideos addObject:videoFilePath];
    [self refreshVideoCV];
}
- (IBAction)onSave:(id)sender {
    if(edt_caption.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected." finish:^{
       }];
        return;
    }
    if(_mType == p_t_newPost) {
        PFObject* postObj = [PFObject objectWithClassName:PARSE_TABLE_POST];
        [postObj setObject:me forKey:PARSE_POST_OWNER];
        NSInteger genderId = [me[PARSE_USER_GENDER] intValue];
        NSInteger purposeId = [me[PARSE_USER_PURPOSID] intValue];
        [postObj setObject:[NSNumber numberWithInteger:genderId]  forKey:PARSE_USER_GENDER];
        [postObj setObject:[NSNumber numberWithInteger:purposeId]  forKey:PARSE_USER_PURPOSID];
//        [postObj setObject:me[FIELD_GEOPOINT] forKey:FIELD_GEOPOINT];
        [postObj setObject:selectedGymId forKey:FIELD_BASEGYMID];
        [postObj setObject:edt_caption.text forKey:FIELD_CAPTION];
        
        NSMutableArray * imageDatas = [NSMutableArray new];
        for (int i = 0; i < self.chosenImages.count; i++) {
            NSObject * imageObj = self.chosenImages[i];
            if([imageObj isKindOfClass:[UIImage class]]){
                UIImage *image = (UIImage*)imageObj;
                if(image){
                    image = [Util getUploadingImageFromImage:image];
                    NSData *data = UIImageJPEGRepresentation(image, 0.8);
                    PFFile * file = [PFFile fileWithData:data];
                    [imageDatas addObject:file];
                }
            }else if([imageObj isKindOfClass:[PFFile class]]){
                [imageDatas addObject:imageObj];
            }
            
        }
        [postObj setObject:imageDatas forKey:PARSE_POST_IMAGES];
        
        NSMutableArray * videoDatas = [NSMutableArray new];
        NSMutableArray * videoThumbDatas = [NSMutableArray new];
        for (int j = 0; j < self.chosenImgThumbs.count; j++) {
            NSObject * imageObj = self.chosenImgThumbs[j];
            if([imageObj isKindOfClass:[UIImage class]]){
                UIImage *image = (UIImage*)imageObj;
                if(image){
                    image = [Util getUploadingImageFromImage:image];
                    NSData *data = UIImageJPEGRepresentation(image, 0.8);
                    PFFile * file = [PFFile fileWithData:data];
                    [videoThumbDatas addObject:file];
                }
            }else if([imageObj isKindOfClass:[PFFile class]]){
                [videoThumbDatas addObject:imageObj];
            }
            NSObject * videoObj = self.chosenVideos[j];
            if([videoObj isKindOfClass:[NSString class]]){
                NSString * videoUrl = (NSString*)videoObj;
                NSData * videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoUrl]];
                PFFile * file = [PFFile fileWithName:@"video.mov" data:videoData];
                [videoDatas addObject:file];
            }else if([videoObj isKindOfClass:[NSData class]]){
                PFFile * file = [PFFile fileWithName:@"video.mov" data:(NSData*)videoObj];
                [videoDatas addObject:file];
            }else if([videoObj isKindOfClass:[PFFile class]]){
                [videoDatas addObject:videoObj];
            }
        }
        [postObj setObject:videoThumbDatas forKey:PARSE_POST_VIDEO_THUMBS];
        [postObj setObject:videoDatas forKey:PARSE_POST_VIDEOS];
        [Util showWaitingMark];
        [postObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [Util hideWaitingMark];
            if (succeeded){
                [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else{
                [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
            }
        }];
    }
    else if (_mType == p_t_editPost) {
        if(_postObj) {
            _postObj[FIELD_CAPTION] = edt_caption.text;
            [_postObj setObject:[NSNumber numberWithInt:selectedGymId] forKey:FIELD_BASEGYMID];
            [_postObj removeObjectForKey:PARSE_POST_IMAGES];
            [_postObj removeObjectForKey:PARSE_POST_VIDEOS];
            NSMutableArray * imageDatas = [NSMutableArray new];
            for (int i = 0; i < self.chosenImages.count; i++) {
                NSObject * imageObj = self.chosenImages[i];
                if([imageObj isKindOfClass:[UIImage class]]){
                    UIImage *image = (UIImage*)imageObj;
                    if(image){
                        image = [Util getUploadingImageFromImage:image];
                        NSData *data = UIImageJPEGRepresentation(image, 0.8);
                        PFFile * file = [PFFile fileWithData:data];
                        [imageDatas addObject:file];
                    }
                }else if([imageObj isKindOfClass:[PFFile class]]){
                    [imageDatas addObject:imageObj];
                }
                
            }
            [_postObj setObject:imageDatas forKey:PARSE_POST_IMAGES];
            
            NSMutableArray * videoDatas = [NSMutableArray new];
            NSMutableArray * videoThumbDatas = [NSMutableArray new];
            for (int j = 0; j < self.chosenImgThumbs.count; j++) {
                NSObject * imageObj = self.chosenImgThumbs[j];
                if([imageObj isKindOfClass:[UIImage class]]){
                    UIImage *image = (UIImage*)imageObj;
                    if(image){
                        image = [Util getUploadingImageFromImage:image];
                        NSData *data = UIImageJPEGRepresentation(image, 0.8);
                        PFFile * file = [PFFile fileWithData:data];
                        [videoThumbDatas addObject:file];
                    }
                }else if([imageObj isKindOfClass:[PFFile class]]){
                    [videoThumbDatas addObject:imageObj];
                }
                NSObject * videoObj = self.chosenVideos[j];
                if([videoObj isKindOfClass:[NSString class]]){
                    NSString * videoUrl = (NSString*)videoObj;
                    NSData * videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoUrl]];
                    PFFile * file = [PFFile fileWithName:@"video.mov" data:videoData];
                    [videoDatas addObject:file];
                }else if([videoObj isKindOfClass:[NSData class]]){
                    PFFile * file = [PFFile fileWithName:@"video.mov" data:(NSData*)videoObj];
                    [videoDatas addObject:file];
                }else if([videoObj isKindOfClass:[PFFile class]]){
                    [videoDatas addObject:videoObj];
                }
            }
            [_postObj setObject:videoThumbDatas forKey:PARSE_POST_VIDEO_THUMBS];
            [_postObj setObject:videoDatas forKey:PARSE_POST_VIDEOS];
            [Util showWaitingMark];
            [_postObj saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                [Util hideWaitingMark];
                [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }];
        }
    }
}

@end
