//
//  AppStateManager.h
//  Partner
//
//  Created by star on 12/8/15.
//  Copyright (c) 2015 zapporoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppStateManager : NSObject

@property (assign, nonatomic) int alertCount;

@property (assign, nonatomic) BOOL isOutGoing;


@property (strong, nonatomic) NSString *callerId;
@property (strong, nonatomic) NSString *callerName;
@property (strong, nonatomic) NSString *receiverId;
@property (strong, nonatomic) NSString *receiverName;

@property (strong, nonatomic) NSString *sessionID;
@property (strong, nonatomic) NSString *publisherToken;
@property (copy, nonatomic) NSString *subscriberToken;


@property (strong, nonatomic) NSString *chatRoomId;

@property (assign) BOOL isCalling;
@property (assign) BOOL isChatting;

@property (assign) BOOL shouldShowHistory;
@property (assign) BOOL shouldShowChat;

// Smarter

/* Filters */
@property (nonatomic) NSInteger user_type;
@property (nonatomic) NSMutableArray *numberofQuestions;
@property (nonatomic) NSMutableArray *minutesofQuestions;
@property (nonatomic) NSMutableArray *ageofQuestions;

+ (AppStateManager *)sharedInstance;

- (void)playIncomingSound;
- (void)playOutgoingSound;
- (void)stopSound;

- (void)resetAlertCount;

@end
