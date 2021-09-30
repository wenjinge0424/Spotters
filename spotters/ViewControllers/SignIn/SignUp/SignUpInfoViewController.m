//
//  SignUpInfoViewController.m
//  spotters
//
//  Created by Techsviewer on 3/15/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SignUpInfoViewController.h"
#import "SelectMainGymController.h"
#import "HomeViewController.h"

@interface SignUpInfoViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SelectMainGymControllerDelegate>
{
    int genderId;
    int purposeId;
    
    UIImage * selectedImage;
    
    BOOL isCamera;
    BOOL isGallery;
    BOOL hasPhoto;
    
    
    NSMutableArray * selectedMainGyms;
    NSMutableArray * selectedSecondGyms;
}
@property (weak, nonatomic) IBOutlet CircleImageView *imgThumb;
@property (weak, nonatomic) IBOutlet UITextField *edt_firstName;
@property (weak, nonatomic) IBOutlet UITextField *edt_gender;
@property (weak, nonatomic) IBOutlet UITextField *edt_purpose;
@property (weak, nonatomic) IBOutlet UITextField *edt_lastname;
@property (weak, nonatomic) IBOutlet UITextField *edt_mainGym;
@property (weak, nonatomic) IBOutlet UITextField *edt_secondGym;
@property (weak, nonatomic) IBOutlet UITextView *txt_bio;

@end

@implementation SignUpInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edt_firstName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_firstName.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.edt_lastname.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_lastname.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.edt_gender.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_gender.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.edt_purpose.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_purpose.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.edt_mainGym.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_mainGym.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.edt_secondGym.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_secondGym.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.txt_bio setPlaceholder:@"About yourself"];
    self.txt_bio.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.txt_bio.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    genderId = -1;
    purposeId = -1;
    
    self.imgThumb.delegate = self;
    self.imgThumb.layer.borderWidth = 0.1f;
    
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
- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    if(selectedImage){
        UIImage *edittedImage = selectedImage;
        NSData *imageData = UIImageJPEGRepresentation(edittedImage, 0.8);
        if (imageData != nil) {
            NSString *filename = @"ar.png";
            PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
            self.user[PARSE_USER_AVATAR] = imageFile;
        }
        [self signUpAction];
    }else{
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Yes" actionBlock:^(void) {
            [self signUpAction];
        }];
        [alert addButton:@"Upload Photo" actionBlock:^(void) {
            [self tapCircleImageView];
        }];
        [alert showError:@"Sign Up" subTitle:@"Are you sure you want to proceed without a profile photo?" closeButtonTitle:nil duration:0.0f];
    }
    
    
}
- (void) signUpAction
{
    self.user[PARSE_USER_FIRSTNAME] = self.edt_firstName.text;
    self.user[PARSE_USER_LASTSTNAME] = self.edt_lastname.text;
    self.user[PARSE_USER_FULLNAME] = [NSString stringWithFormat:@"%@ %@",self.edt_firstName.text, self.edt_lastname.text];
    self.user[PARSE_USER_GENDER] = [NSNumber numberWithInt:genderId];
    self.user[PARSE_USER_PURPOSID] = [NSNumber numberWithInt:purposeId];
    self.user[PARSE_USER_MAINGYM] = [selectedMainGyms firstObject];
    self.user[PARSE_USER_SECONDGYMS] = selectedSecondGyms;
    self.user[PARSE_USER_BIO] = self.txt_bio.text;
    [self.user setObject:[NSNumber numberWithBool:NO] forKey:PARSE_USER_IS_BANNED];
    self.user[PARSE_USER_TYPE] = [NSNumber numberWithInt:100];
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [Util setLoginUserName:self.user.username password:self.user.password];
            HomeViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeViewController"];
            [self.navigationController pushViewController:controller animated:YES];
        }else {
            NSString *message = [error localizedDescription];
            [Util showAlertTitle:self title:@"Error" message:message];
        }
    }];
}
    
- (BOOL) isValid {
    self.edt_firstName.text = [Util trim:_edt_firstName.text];
    self.edt_lastname.text = [Util trim:_edt_lastname.text];
    self.edt_gender.text = [Util trim:_edt_gender.text];
    self.edt_purpose.text = [Util trim:_edt_purpose.text];
    
    NSString *firstName = _edt_firstName.text;
    NSString *lastName = _edt_lastname.text;

    if(firstName.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please insert first name." finish:^{
            [_edt_firstName becomeFirstResponder];
        }] ;
        return NO;
    }
    if(lastName.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please insert last name." finish:^{
            [_edt_lastname becomeFirstResponder];
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
    if(self.txt_bio.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please insert about yourself." finish:^{
            [_txt_bio becomeFirstResponder];
        }] ;
    }
    return YES;
}


- (void) tapCircleImageView {
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

- (IBAction)onSelectGender:(id)sender {
    UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:@"Gender" message:@"Select from below" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Male" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.edt_gender.text = @"Male";
        genderId = 0;
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Female" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.edt_gender.text = @"Female";
        genderId = 1;
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Both" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.edt_gender.text = @"Both";
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
        self.edt_purpose.text = @"Business (Friends)";
        purposeId = 0;
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Pleasure (Dating)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.edt_purpose.text = @"Pleasure (Dating)";
        purposeId = 1;
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Both" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.edt_purpose.text = @"Both";
        purposeId = 2;
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}
- (IBAction)onSelectMainGym:(id)sender {
    SelectMainGymController * vc1 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectMainGymController"];
    vc1.ableCount = 1;
    vc1.selectedGYMIds = [NSMutableArray new];
    vc1.ctrTag = 1;
    vc1.isAdditionalMode = NO;
    vc1.delegate = self;
    [self.navigationController pushViewController:vc1 animated:YES];
}
- (IBAction)onSelectSecondGym:(id)sender {
    SelectMainGymController * vc1 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectMainGymController"];
    vc1.ableCount = 1;
    vc1.selectedGYMIds = [NSMutableArray new];
    vc1.ctrTag = 2;
    vc1.isAdditionalMode = NO;
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
        self.edt_mainGym.text = gymName;
    }else if(ctrTag == 2){
        self.edt_secondGym.text = gymName;
    }
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
    [self.imgThumb setImage:image];
    selectedImage = image;
    hasPhoto = YES;
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
