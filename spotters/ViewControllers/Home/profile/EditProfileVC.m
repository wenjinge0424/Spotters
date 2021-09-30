//
//  EditProfileVC.m
//  Spotters
//
//  Created by developer on 6/19/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "EditProfileVC.h"
#import <GooglePlaces/GooglePlaces.h>
#import "SPHLocationPickerViewController.h"
#import "ExampleAutoCompleteTableViewDataSource.h"
#import "KGWLocationPickerViewController.h"
#import "SelectMainGymController.h"
#import "SpecialGymViewController.h"
#import "EditImageCollectionViewCell.h"

@interface EditProfileVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, SelectMainGymControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>{
    __weak IBOutlet UIImageView *imgAvatar;
    __weak IBOutlet UITextField *tfFirstName;
    __weak IBOutlet UITextField *tfLastName;
    __weak IBOutlet UITextField *tfGender;
    __weak IBOutlet UITextField *tfPurpose;
    __weak IBOutlet UITextField *tfGym;
    __weak IBOutlet UITextField *tfSearchGym;
    __weak IBOutlet UITextField *tfEmail;
    __weak IBOutlet UITextField *tfPassword;
    __weak IBOutlet UITextField *tfConfirmPwd;
    __weak IBOutlet UITextView *txtNote;
    __weak IBOutlet UICollectionView *collectionExtra;
    PFUser* me;
    //picker view
    int genderId;
    int purposeId;
    
    UIImage * selectedImage;
    
    BOOL isCamera;
    BOOL isGallery;
    BOOL hasPhoto;
    
    
    NSMutableArray * selectedMainGyms;
    NSMutableArray * selectedSecondGyms;
    
    int max_main_gym;
    int max_search_gym;
    
    int currentImageViewTag;
    NSMutableArray * extraImageArray;
}

@end

@implementation EditProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    // Do any additional setup after loading the view.
    tfFirstName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:tfFirstName.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    tfLastName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:tfLastName.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    tfGender.attributedPlaceholder = [[NSAttributedString alloc] initWithString:tfGender.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    tfPurpose.attributedPlaceholder = [[NSAttributedString alloc] initWithString:tfPurpose.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    tfGym.attributedPlaceholder = [[NSAttributedString alloc] initWithString:tfGym.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    tfSearchGym.attributedPlaceholder = [[NSAttributedString alloc] initWithString:tfSearchGym.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    [txtNote setPlaceholder:@"About yourself"];
    txtNote.attributedPlaceholder = [[NSAttributedString alloc] initWithString:txtNote.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    
    genderId = -1;
    purposeId = -1;
    [self loadProfile];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) loadProfile {
    [Util setAvatar:imgAvatar withUser:me];
    
    tfFirstName.text = me[PARSE_USER_FIRSTNAME];
    tfLastName.text = me[PARSE_USER_LASTSTNAME];
    genderId = [me[PARSE_USER_GENDER] intValue];
    tfGender.text = GENDER_PICKER_ARRAY[genderId];
    purposeId = [me[PARSE_USER_PURPOSID] intValue];
    tfPurpose.text = PURPOSE_PICKER_ARRAY[purposeId];
    txtNote.text = me[PARSE_USER_BIO];
    selectedMainGyms = [[NSMutableArray alloc] initWithObjects:me[PARSE_USER_MAINGYM], nil];
    selectedSecondGyms = me[PARSE_USER_SECONDGYMS];
    
    int mainGymId = [me[PARSE_USER_MAINGYM] intValue];
    [Util getGymNameWithId:[NSString stringWithFormat:@"%d", mainGymId] completionBlock:^(NSString * gynName){
        tfGym.text = gynName;
    }];
    [Util getGymNamesWithIds:selectedSecondGyms completionBlock:^(NSMutableArray *gymObjects) {
        if(gymObjects.count > 1){
            NSString * strGymName = [NSString stringWithFormat:@"%d gyms", (int)gymObjects.count];
            tfSearchGym.text = strGymName;
        }else{
            PFObject * firstGym = [gymObjects firstObject];
            NSString * gymName = firstGym[@"name"];
            tfSearchGym.text = gymName;
        }
    }];
    
    
    NSDate * purchasedDate = me[FIELD_BUY_DATE];
    int buyType = [me[FIELD_BUY_ID] intValue];
    if(!purchasedDate){
        max_main_gym = 1;
        max_search_gym = 2;
    }else if([purchasedDate timeIntervalSinceNow] + 30*24*3600 < 0){
        max_main_gym = 1;
        max_search_gym = 2;
    }else if(buyType == 1){
        max_main_gym = 1;
        max_search_gym = 5;
    }else if(buyType == 2){
        max_main_gym = 1;
        max_search_gym = 20;
    }
    tfEmail.text = me.username;
    tfPassword.text = me[PARSE_USER_PREVIEWPWD];
    tfConfirmPwd.text = me[PARSE_USER_PREVIEWPWD];
    
    extraImageArray = [[NSMutableArray alloc] initWithArray:me[PARSE_USER_EXTRAAVATAR]];
    if(!extraImageArray || extraImageArray.count != 4){
        extraImageArray = [NSMutableArray new];
        for(int i = 0;i<4;i++){
            [extraImageArray addObject:[NSNull new]];
        }
    }
    
    collectionExtra.delegate = self;
    collectionExtra.dataSource = self;
    [collectionExtra reloadData];
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
    EditImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EditImageCollectionViewCell" forIndexPath:indexPath];
    if(cell){
        NSObject * imgObj = [extraImageArray objectAtIndex:indexPath.row];
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
    currentImageViewTag = (int)indexPath.row + 1;
    [self onSelectProfileImage];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onSelectGnder:(id)sender {
    UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:@"Gender" message:@"Select from below" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Male" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        tfGender.text = @"Male";
        genderId = 0;
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Female" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        tfGender.text = @"Female";
        genderId = 1;
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Both" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        tfGender.text = @"Both";
        genderId = 2;
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}
- (IBAction)onSelectPurpose:(id)sender {
    UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:@"Purpose" message:@"Select from below" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Business (Friends)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        tfPurpose.text = @"Business (Friends)";
        purposeId = 0;
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Pleasure (Dating)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        tfPurpose.text = @"Pleasure (Dating)";
        purposeId = 1;
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Both" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        tfPurpose.text = @"Both";
        purposeId = 2;
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}
- (IBAction)onSelectMainGym:(id)sender {
    SelectMainGymController *vc1 = (SelectMainGymController *)[Util getUIViewControllerFromStoryBoard:@"SelectMainGymController"];
    vc1.ableCount = max_main_gym;
    vc1.selectedGYMIds = selectedMainGyms;
    vc1.ctrTag = 1;
    vc1.isAdditionalMode = YES;
    vc1.delegate = self;
    [self.navigationController pushViewController:vc1 animated:YES];
}
- (IBAction)onSelectSecondGym:(id)sender {
    SelectMainGymController *vc1 = (SelectMainGymController *)[Util getUIViewControllerFromStoryBoard:@"SelectMainGymController"];
    vc1.ableCount = max_search_gym;
    vc1.selectedGYMIds = selectedSecondGyms;
    vc1.ctrTag = 2;
    vc1.isAdditionalMode = YES;
    vc1.delegate = self;
    [self.navigationController pushViewController:vc1 animated:YES];
}
- (void) SelectMainGymControllerDelegate_didSelected:(NSMutableArray *)selectedGym :(int)ctrTag
{
    if(ctrTag == 1){
        selectedMainGyms = selectedGym;
    }else if(ctrTag == 2){
        selectedSecondGyms = selectedGym;
    }
}
- (void) SelectMainGymControllerDelegate_didSelectedWithName:(NSString *)gymName :(int)ctrTag
{
    if(ctrTag == 1){
        tfGym.text = gymName;
    }else if(ctrTag == 2){
        tfSearchGym.text = gymName;
    }
}


- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSave:(id)sender {
    if(![self isValid]) {
        return;
    }
    BOOL needUpdateExtraImg = NO;
    BOOL needMoreExtraImg = NO;
    for(NSObject * subItem in extraImageArray){
        if([subItem isKindOfClass:[NSNull class]]){
            needMoreExtraImg = YES;
        }else if([subItem isKindOfClass:[UIImage class]]){
            needUpdateExtraImg = YES;
        }
    }
    if(needMoreExtraImg){
        [Util showAlertTitle:self title:@"Error" message:@"Please upload 4 extra profile photos." finish:^{}] ;
        return;
    }
    NSMutableArray * ExtraImageArray = [NSMutableArray new];
    for(NSObject * subItem in extraImageArray){
        if([subItem isKindOfClass:[PFFile class]]){
            [ExtraImageArray addObject:subItem];
        }else if([subItem isKindOfClass:[UIImage class]]){
            UIImage * subImage = (UIImage*)subItem;
            NSData *imageData = UIImageJPEGRepresentation(subImage, 0.8);
            NSString *filename = @"subItem.png";
            PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
            [ExtraImageArray addObject:imageFile];
        }
    }
    if(needUpdateExtraImg){
        me[PARSE_USER_EXTRAAVATAR] = ExtraImageArray;
    }
    
    if(selectedImage){
        UIImage *edittedImage = selectedImage;
        NSData *imageData = UIImageJPEGRepresentation(edittedImage, 0.8);
        if (imageData != nil) {
            NSString *filename = @"ar.png";
            PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
            me[PARSE_USER_AVATAR] = imageFile;
        }
    }
    
    me[PARSE_USER_FIRSTNAME] = tfFirstName.text;
    me[PARSE_USER_LASTSTNAME] = tfLastName.text;
    me[PARSE_USER_FULLNAME] = [NSString stringWithFormat:@"%@ %@",tfFirstName.text, tfLastName.text];
    me[PARSE_USER_GENDER] = [NSNumber numberWithInt:genderId];
    me[PARSE_USER_PURPOSID] = [NSNumber numberWithInt:purposeId];
    me[PARSE_USER_MAINGYM] = [selectedMainGyms firstObject];
    me[PARSE_USER_SECONDGYMS] = selectedSecondGyms;
    me[PARSE_USER_BIO] = txtNote.text;
    [me setObject:[NSNumber numberWithBool:NO] forKey:PARSE_USER_IS_BANNED];
    me[PARSE_USER_TYPE] = [NSNumber numberWithInt:100];
    me.password = tfPassword.text;
    [Util showWaitingMark];
    [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [Util hideWaitingMark];
        if (succeeded){
            [Util setLoginUserName:me.username password:tfPassword.text];
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            NSString *message = [error localizedDescription];
            [Util showAlertTitle:self title:@"Error" message:message];
        }
    }];
}



- (BOOL) isValid {
    tfFirstName.text = [Util trim:tfFirstName.text];
    tfLastName.text = [Util trim:tfLastName.text];
    tfGender.text = [Util trim:tfGender.text];
    tfPurpose.text = [Util trim:tfPurpose.text];
    
    NSString *firstName = tfFirstName.text;
    NSString *lastName = tfLastName.text;
    
    if(firstName.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please insert first name." finish:^{
            [tfFirstName becomeFirstResponder];
        }] ;
        return NO;
    }
    if(lastName.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please insert last name." finish:^{
            [tfLastName becomeFirstResponder];
        }] ;
        return NO;
    }
    if(genderId < 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please select your gender." finish:^{
        }] ;
        return NO;
    }
    if(purposeId < 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please select your purpose." finish:^{
        }] ;
        return NO;
    }
    if(!selectedMainGyms || selectedMainGyms.count == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please select your main gym." finish:^{
        }] ;
        return NO;
    }
    if(!selectedSecondGyms || selectedSecondGyms.count == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please select your secondary gym." finish:^{
        }] ;
        return NO;
    }
    if(txtNote.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please insert about yourself." finish:^{
            [txtNote becomeFirstResponder];
        }] ;
    }
    return YES;
}



- (IBAction)onTapAddPhoto:(id)sender {
    currentImageViewTag = 0;
    [self onSelectProfileImage];
}
- (void) onSelectProfileImage
{
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Take a new photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onTakePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Select from gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onChoosePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

// circle imageview delegate
- (void)onChoosePhoto:(id)sender {
    if (![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    isGallery = YES;
    isCamera = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)onTakePhoto:(id)sender {
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    isCamera = YES;
    isGallery = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isCamera && ![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    if(currentImageViewTag == 0){
        [imgAvatar setImage:image];
        selectedImage = image;
        hasPhoto = YES;
    }else{
        int extraImageIndex = currentImageViewTag - 1;
        [extraImageArray replaceObjectAtIndex:extraImageIndex withObject:image];
        collectionExtra.delegate = self;
        collectionExtra.dataSource = self;
        [collectionExtra reloadData];
    }
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    if (isCamera && ![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
}
@end
