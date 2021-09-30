//
//  MediaViewController.m
//  smallplayerbigplay
//
//  Created by Techsviewer on 7/26/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "MediaViewController.h"
#import "LMMediaPlayerView.h"

@interface MediaViewController ()<LMMediaPlayerViewDelegate>
{
    LMMediaPlayerView *playerView_;
    BOOL isPlaying;
}
@property (weak, nonatomic) IBOutlet UIView *videoContainer;
@property (weak, nonatomic) IBOutlet UIImageView *image_photo;
@property (weak, nonatomic) IBOutlet UIView *view_topbar;

@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appdidActive:) name:NOTIFICATION_ACTIVE object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appdidbackground:) name:NOTIFICATION_BACKGROUND object:nil];
    
    BOOL isVideo = NO;
    if (self.video){
        isVideo = YES;
    } else if(self.localVideoUrl){
        isVideo = YES;
    } else if(self.localVideoData){
        isVideo = YES;
    }else {
        isVideo = NO;
    }
    if (isVideo){// video
        [self.videoContainer setHidden:NO];
        [self.image_photo setHidden:YES];
        isPlaying = NO;
        [self performSelector:@selector(onPlayVideo) withObject:nil afterDelay:0.5];
    } else if (self.image) { // image
        [self.videoContainer setHidden:YES];
        [self.image_photo setHidden:NO];
        [self.image_photo setImage:self.image];
    } else if(self.pf_image){
        [self.videoContainer setHidden:YES];
        [self.image_photo setHidden:NO];
        self.image_photo.contentMode = UIViewContentModeScaleAspectFit;
        [Util setImage:self.image_photo imgFile:self.pf_image];
    }
    
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (playerView_.mediaPlayer){
        isPlaying = NO;
        [playerView_.mediaPlayer pause];
        playerView_.delegate = nil;
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
- (void) appdidActive:(NSNotification *) notif {
    if (self.video){
        _videoContainer.hidden = NO;
        if (playerView_.mediaPlayer){
            isPlaying = NO;
            [playerView_.mediaPlayer pause];
        }
    }
}

- (void) appdidbackground:(NSNotification *) notif {
    if (self.video){
        if (playerView_.mediaPlayer){
            isPlaying = NO;
            [playerView_.mediaPlayer pause];
        }
    }
}
- (void) initializeVideo
{
    if(!playerView_){
        playerView_ = [LMMediaPlayerView sharedPlayerView];
        playerView_.frame = _videoContainer.bounds;
        playerView_.delegate = self;
        [playerView_ setHeaderViewHidden:YES];
        [playerView_ setFooterViewHidden:NO];
        playerView_.previousButton.hidden = YES;
        playerView_.nextButton.hidden = YES;
        
        playerView_.delegate = self;
        
        _videoContainer.backgroundColor = [UIColor blackColor];
        playerView_.frame = _videoContainer.bounds;
        [_videoContainer addSubview:playerView_];
    }
}
#pragma mark - LMMediaPlayerViewDelegate

- (BOOL)mediaPlayerViewWillStartPlaying:(LMMediaPlayerView *)playerView media:(LMMediaItem *)media
{
    return YES;
}
- (void)mediaPlayerViewDidFinishPlaying:(LMMediaPlayerView *)playerView media:(LMMediaItem *)media
{
    [playerView_ setFullscreen:NO animated:YES];
}
- (void)mediaPlayerViewWillChangeState:(LMMediaPlayerView *)playerView state:(LMMediaPlaybackState)state
{
    if(state == LMMediaPlaybackStatePaused || state == LMMediaPlaybackStateStopped){
        [playerView_ setFullscreen:NO animated:YES];
    }
}
- (IBAction)onback:(id)sender {
    if(playerView_){
        [playerView_.mediaPlayer stop];
        playerView_.delegate = nil;
    }
    [self.image_photo setHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) onPlayVideo
{
    if (isPlaying){
        if (playerView_.mediaPlayer){
            [playerView_.mediaPlayer pause];
        }
    } else {
        if (playerView_.mediaPlayer){
            [playerView_.mediaPlayer play];
        } else {
            [self playVideo];
        }
    }
}
- (void) playVideo {
    if (self.video){
        [self showVideoMoment:self.video];
    }else if(self.localVideoUrl){
        [self playVideo:self.localVideoUrl];
    }else if(self.localVideoData){
        [self playVideoWithData:self.localVideoData];
    }
}
- (NSString *) getDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}
- (void) showVideoMoment:(PFFile *)file
{
    if (!file){
        if (playerView_.mediaPlayer){
            isPlaying = NO;
            [playerView_.mediaPlayer pause];
        }
        return;
    }
    
    NSString *docPath = [self getDocumentDirectoryPath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, file.name];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists){
        [self playVideo:filePath];
    } else {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                NSLog(@"Error get Video Data from Server");
            } else {
                [data writeToFile:filePath atomically:YES];
                [self playVideo:filePath];
            }
        }];
    }
}

- (void)playVideo:(NSString *)filePath
{
    [self initializeVideo];
    LMMediaItem *item = [[LMMediaItem alloc] initWithInfo:@{LMMediaItemInfoURLKey:[NSURL fileURLWithPath:filePath], LMMediaItemInfoContentTypeKey:@(LMMediaItemContentTypeVideo)}];
    [playerView_.mediaPlayer removeAllMediaInQueue];
    [playerView_.mediaPlayer addMedia:item];
    [playerView_.mediaPlayer play];
    isPlaying = YES;
}
- (void)playVideoWithData:(NSData *)data
{
    NSString *docPath = [self getDocumentDirectoryPath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, @"tmp.mov"];
    [self playVideo:filePath];
}

@end
