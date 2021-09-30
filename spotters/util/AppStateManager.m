//
//  AppStateManager.m
//  Partner
//
//  Created by star on 12/8/15.
//  Copyright (c) 2015 zapporoo. All rights reserved.
//

#import "AppStateManager.h"
#import <AVFoundation/AVFoundation.h>


#define SOUND_VOLUME    1.0
#define INCOMING_SOUND  @"incoming_call_ring.wav"
#define OUTGOING_SOUND  @"outgoing_call_ring.wav"

static AppStateManager *sharedInstance = nil;

@interface AppStateManager() <AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPlayer;
}
@end

@implementation AppStateManager

+ (AppStateManager *)sharedInstance {
    
    if (!sharedInstance) {
        sharedInstance = [[AppStateManager alloc] init];
        sharedInstance.alertCount = 0;
        sharedInstance.chatRoomId = @"";
        
        // Smarter
        sharedInstance.user_type = 0;
        
        sharedInstance.numberofQuestions = [[NSMutableArray alloc] init];
        sharedInstance.minutesofQuestions = [[NSMutableArray alloc] init];
        sharedInstance.ageofQuestions = [[NSMutableArray alloc] init];
        // number of questions
        for (int i=0;i<60;i++){
            [sharedInstance.numberofQuestions addObject:[NSString stringWithFormat:@"%d", (5 * (i + 1))]];
            [sharedInstance.minutesofQuestions addObject:[NSString stringWithFormat:@"%d",(i + 1)]];
            [sharedInstance.ageofQuestions addObject:[NSString stringWithFormat:@"%d",(i + 1)]];
        }
    }
    
    return sharedInstance;
}

- (void)playIncomingSound {
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    NSURL *urlPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], INCOMING_SOUND]];
    NSError *err = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPath error:&err];
    audioPlayer.numberOfLoops = -1;
    audioPlayer.delegate = self;
    [audioPlayer setVolume:SOUND_VOLUME];
    [audioPlayer play];
}

- (void)playOutgoingSound {
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    NSURL *urlPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], OUTGOING_SOUND]];
    NSError *err = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPath error:&err];
    audioPlayer.numberOfLoops = -1;
    audioPlayer.delegate = self;
    [audioPlayer setVolume:SOUND_VOLUME];
    [audioPlayer play];
}

- (void)stopSound {
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer = nil;
    }
}

- (void)resetAlertCount {
    self.alertCount = 0;
}

@end
