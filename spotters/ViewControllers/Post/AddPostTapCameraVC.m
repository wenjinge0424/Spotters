//
//  AddPostTapCameraVC.m
//  Spotters
//
//  Created by developer on 6/20/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import "AddPostTapCameraVC.h"
#import "MyCameraViewController.h"

@interface AddPostTapCameraVC (){
    
    __weak IBOutlet UIImageView *imgRecordType;
    __weak IBOutlet UILabel *lblRecordTime;
    __weak IBOutlet UIImageView *imgPlayVideo;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIButton *btnSwitch;
    __weak IBOutlet UIButton *btnSnap;
    __weak IBOutlet UIImageView *imgSmall;
    
    
    MyCameraViewController* myCamerarVC;
    
    int current_capture_time;
    
    BOOL isRecording;
}

@end

@implementation AddPostTapCameraVC
@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mType = c_t_photo;
    [self changeUI];
    current_capture_time = 0;
    isRecording = NO;
    lblRecordTime.text = @"00:00:00";
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    myCamerarVC = (MyCameraViewController*) self.childViewControllers.lastObject;
    [myCamerarVC start];
    //    if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
    BOOL isAvailableFrontCamera = [MyCameraViewController isFrontCameraAvailable];
    BOOL isAvailableRearCamera = [MyCameraViewController isRearCameraAvailable];
    [btnSwitch setEnabled:isAvailableRearCamera && isAvailableFrontCamera ];
    
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [myCamerarVC stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) updateRecordTime
{
    if(!isRecording)
        return;
    current_capture_time ++;
    int hour = current_capture_time / 3600;
    int min = (current_capture_time - hour *3600) / 60;
    int second = current_capture_time - hour *3600 - min *60;
    lblRecordTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, second];
    [self performSelector:@selector(updateRecordTime) withObject:nil afterDelay:1];
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
- (IBAction)onTapType:(UISegmentedControl *)sender {
    _mType = sender.selectedSegmentIndex;
    [self changeUI];
}

- (void) changeUI{
    [imgRecordType setHidden: _mType == c_t_photo];
    [lblRecordTime setHidden: _mType == c_t_photo];
    [imgPlayVideo setHidden: _mType == c_t_photo];

    
}

- (IBAction)onSwitch:(id)sender {
    [myCamerarVC togglePosition];
}
- (IBAction)onSnap:(id)sender {
    if (_mType == c_t_photo) {
        [myCamerarVC capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
            if(!error) {
                [self.delegate myCaptureDelegate:image];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                NSLog(@"An error has occured: %@", error);
            }
        } exactSeenImage:YES];
        
    }
    else if (_mType == c_t_video) {
        btnSwitch.enabled = NO;
        if(!myCamerarVC.isRecording) {
            imgRecordType.image = [UIImage imageNamed:@"ic_recorded_time_recording.png"];
            NSURL *outputURL = [[[self applicationDocumentsDirectory]
                                 URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_upload", [Util randomStringWithLength:20]]] URLByAppendingPathExtension:@"mov"];
            isRecording = YES;
            [self performSelector:@selector(updateRecordTime) withObject:nil afterDelay:1];
            [myCamerarVC startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
//                VideoViewController *vc = [[VideoViewController alloc] initWithVideoUrl:outputFileUrl];
//                [self.navigationController pushViewController:vc animated:YES];
                isRecording = NO;
                UIImage* thumbImg = [Util generateThumbImage:outputFileUrl];
                if(thumbImg) {
                    [self.delegate myCaptureVideoThumbDelegate:thumbImg :outputFileUrl.absoluteString];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            isRecording = NO;
            btnSwitch.enabled = YES;
            imgRecordType.image = [UIImage imageNamed:@"ic_recorded_time_stoped.png"];
            [myCamerarVC stopRecording];
        }
    }
    
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
