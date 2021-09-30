//
//  Config.h
//
//  Created by IOS7 on 12/16/14.
//  Copyright (c) 2014 iOS. All rights reserved.
//

#import "AppStateManager.h"
/* ***************************************************************************/
/* ***************************** Paypal config ********************************/
/* ***************************************************************************/


/* ***************************************************************************/
/* ***************************** Stripe config ********************************/
/* ***************************************************************************/

#define STRIPE_KEY                                              @""
//#define STRIPE_KEY                              @""
#define STRIPE_URL                                              @"https://api.stripe.com/v1"
#define STRIPE_CHARGES                                          @"charges"
#define STRIPE_CUSTOMERS                                        @"customers"
#define STRIPE_TOKENS                                           @"tokens"
#define STRIPE_ACCOUNTS                                         @"accounts"
#define STRIPE_CONNECT_URL                                      @"https://stripe.smarter.brainyapps.tk"

#define NOTIFICATION_ACTIVE                                     @"NOTIFICATION_ACTIVE"
#define NOTIFICATION_BACKGROUND                                 @"NOTIFICATION_BACKGROUND"
#define PUSH_NOTIFICATION_TYPE                                  @"type"

#define SYSTEM_KEY_READ_ONBOARD                                 @"read_onboard"

#define USER_PUBLIC_STATE_PUBLIC                                0
#define USER_PUBLIC_STATE_FRIEND                                1


/* Remote Notification Type values */
#define REMOTE_NF_TYPE_NEW_ITEM                                 @"New_Iwant_Item"
#define REMOTE_NF_TYPE_NEW_CATEGORY                             @"New_Category"
#define REMOTE_NF_TYPE_FRIEND_INVITE                            @"Friend_Invite"
#define REMOTE_NF_TYPE_INVITE_ACCEPT                            @"Invite_Result_Accept"
#define REMOTE_NF_TYPE_INVITE_REJECT                            @"Invite_Result_Reject"
#define REMOTE_NF_TYPE_CLICK_EMPTY_CATEGORY                     @"Click_Empty_Category"
#define kChatReceiveNotification                                @"ChatReceiveNotification"
#define kChatReceiveNotificationUsers                           @"ChatReceiveNotificationUsers"
#define kNewAdPosted                                            @"kNewAdPosted"
#define kReceivedFollowRequest                                  @"kReceivedFollowRequest"
#define kHomeTapped                                             @"kHomeTapped"
#define kReceiveOtherNotification                               @"kReceiveOtherNotification"

enum {
    CHAT_TYPE_MESSAGE = 100,
    CHAT_TYPE_IMAGE = 200,
    CHAT_TYPE_VIDEO = 300
};

enum {
    REPORT_TYPE_POST = 100,
    REPORT_TYPE_USER = 200,
    REPORT_TYPE_AD = 300,
    REPORT_TYPE_STREAM = 400
};
typedef enum{
    p_t_newPost = 0,
    p_t_editPost
} PostType;

typedef enum{
    c_t_photo = 0,
    c_t_video
} CaptureType;

typedef enum {
    p_p_aboutTheApp = 0,
    p_p_privacyPolicy,
    p_p_termsAndConditions
} PPType;

typedef enum {
    reaction_comment = 0,
    reaction_like,
    reaction_reacted
} ReactionType;

//define enums
typedef enum{
    si_inappPurchase = 0,
    si_rateTheApp,
    si_sendFeedBack,
    si_aboutTheApp,
    si_privcyPoilcy,
    si_termsAndContidions,
    si_logOut
} SettingTVIndex;

enum {
    PUSH_TYPE_CHAT = 1,
    PUSH_TYPE_BAN,
    PUSH_TYPE_NEW_POST,
    PUSH_TYPE_DEL_POST,
    PUSH_TYPE_FOLLOW_REQUEST,
    PUSH_TYPE_FOLLOW_ACCEPTED,
    PUSH_TYPE_UNFOLLOW,
    PUSH_TYPE_LIKE,
    PUSH_TYPE_COMMENT
};


#define MAIN_COLOR                                              [UIColor colorWithRed:0/255.f green:202/255.f blue:37/255.f alpha:1.f]
#define MAIN_BORDER_COLOR                                       [UIColor colorWithRed:186/255.f green:186/255.f blue:186/255.f alpha:1.f]
#define MAIN_BORDER1_COLOR                                      [UIColor colorWithRed:209/255.f green:209/255.f blue:209/255.f alpha:1.f]
#define MAIN_BORDER2_COLOR                                      [UIColor colorWithRed:95/255.f green:95/255.f blue:95/255.f alpha:1.f]
#define MAIN_HEADER_COLOR                                       [UIColor colorWithRed:103/255.f green:103/255.f blue:103/255.f alpha:1.f]
#define MAIN_SWDEL_COLOR                                        [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
#define MAIN_DESEL_COLOR                                        [UIColor colorWithRed:206/255.f green:89/255.f blue:37/255.f alpha:1.f]
#define MAIN_HOLDER_COLOR                                       [UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.f]
#define MAIN_TRANS_COLOR                                        [UIColor colorWithRed:204/255.f green:227/255.f blue:244/255.f alpha:1.f]

/* Page Notifcation */

/* Refresh Notifcation */

/* Remote Notification Type values */

/* Smarter */
#define NOTIFICATION_STATE_PENDING                              0
#define NOTIFICATION_STATE_ACCEPT                               1
#define NOTIFICATION_STATE_REJECT                               2



/* Spin Notification Data */
#define USER_TYPE                                               [AppStateManager sharedInstance].user_type

#define MAINGYM_ARRAY                     [[[NSMutableArray alloc] initWithObjects:@"Spotters Gyms", @"LA Fitness", @"Lifetime", @"24 Hour Fitness", @"Equinox", @"ClubCorp", @"Planet Fitness", @"Xsport Fitness", @"Crunch Fitness", @"Exos", @"Chelsea Piers", @"Anytime Fitness", @"WellBridge", @"Vasa Fitness", @"East Bank Club", @"Plus One", @"Fitness Formula", @"Muv Brands", @"Healthworks Group", @"Corporate Sports Unlimited", @"Corporate Fitness Works", @"Cooper Aerobics Enterprise", @"World Gym", @"Club One", @"Curves International", @"OrangeTheory Fitness", @"Snap Fitness", @"Youfit", @"Town Sport International", @"Golds Gym", @"E at Equinox", @"Fitness Rangers", @"Robles Fitness", @"HIIT Fitness", @"Sports Courts Fitness", @"220 Fitness", @"24 Hour Fitness Super Sport", @"Asylum Gym LA", @"Spectrum", @"TriFit", @"Breakthru Fitness", @"YAS Fitness Center", @"Crunch Fitness", @"North Park Fitness", @"The Private Gym", @"Chuze Fitness", @"Last Real Gym", @"Prime Fitness Training", @"Balanced Fitness and Health", @"FITNESS SF - SOMA", @"Sunset Gym", @"LiveFit Gym", @"Tangible Fitness", @"Independence Gym", @"EōS Fitness", @"Elite Fitness", @"Off The Grid Fitness", @"Fulcrum Fitness", @"Rival Fitness", @"Kubex Fitness", @"Iron Warrior Gym", @"Accolade Fitness", @"Flex Gym and Fitness", @"Access Fitness", @"Talwalkars", @"Powerhouse Gym", @"Retro Fitness", @"Barbell Brigade", @"In-Shape", @"Blink Fitness", @"Island Gym & Fitness", @"Bally Total Fitness", @"Metroflex Gym", @"Blink Fitness", @"Fitness First", @"McFit (Germany)", @"GoodLife Fitness (Canada)", @"Fitness 19", @"American Family Fitness", @"All Health Clubs", @"Cross Fit", @"Other gym", @"YMCA", @"University/College Campus", nil] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]

#define GENDER_PICKER_ARRAY                 [[NSArray alloc] initWithObjects:@"Male", @"Female", @"Both", nil]
#define PURPOSE_PICKER_ARRAY                 [[NSArray alloc] initWithObjects:@"Business (Friends)", @"Pleasure (Dating)", @"Both", nil]


#define STR_SENDFEEDBACK                                        @"Send FeedBack"
#define STR_APPOWNER_EMAIL                                      @"spottersapp@gmail.com"
#define STR_INFORMATION                                         @"Information"
#define STR_CANNOTSENDEMAIL                                     @"Your device is impossible to send Email."
#define STR_CONFIRM                                             @"Confirmation"
#define STR_CONFIRM_LOGOUT                                      @"Are you sure you want to logout?"
#define STR_CANCEL                                              @"Cancel"
#define STR_SENDEMAIL_SUCCESS                                   @"Sent Email successfully"
#define STR_SENDEMAIL_FAIL                                      @"Failed."
#define STRING_SUCCESS              @"Success"
#define STRING_ERROR                @"Error"
#define STR_REQUEST_ACCEPT_FAIL                      @"Request accept faul."
#define STR_REQUEST_DECLINE_FAIL                                  @"Request decline fail."
#define STR_ERROR_SINGLE                                        @"We detected an error. Help me review your answer and try again."
#define STR_ERROR_MULTI                                         @"We detected a few errors. Help me reivew your answers and try again."

/* Parse Table */
#define PARSE_FIELD_OBJECT_ID                                   @"objectId"
#define PARSE_FIELD_USER                                        @"user"
#define PARSE_FIELD_CHANNELS                                    @"channels"
#define PARSE_FIELD_CREATED_AT                                  @"createdAt"
#define PARSE_FIELD_UPDATED_AT                                  @"updatedAt"

/* User Table */
#define PARSE_TABLE_USER                                        @"User"
#define PARSE_USER_FULLNAME                                     @"fullName"
#define PARSE_USER_FIRSTNAME                                    @"firstName"
#define PARSE_USER_LASTSTNAME                                   @"lastName"
#define PARSE_USER_NAME                                         @"username"
#define PARSE_USER_EMAIL                                        @"email"
#define PARSE_USER_PASSWORD                                     @"password"
#define PARSE_USER_LOCATION                                     @"location"
#define PARSE_USER_GEOPOINT                                     @"geoPoint"
#define PARSE_USER_TYPE                                         @"userType"
#define PARSE_USER_AVATAR                                       @"avatar"
#define PARSE_USER_EXTRAAVATAR                                  @"extraAvatar"
#define PARSE_USER_FINGERPHOTO                                  @"fingerPhoto"
#define PARSE_USER_FACEBOOKID                                   @"facebookid"
#define PARSE_USER_GOOGLEID                                     @"googleid"
#define PARSE_USER_BUSINESS_ACCOUNT_ID                          @"accountId"
#define PARSE_USER_IS_BANNED                                    @"isBanned"
#define PARSE_USER_PARENT                                       @"parent"
#define PARSE_USER_TEACHER_LIST                                 @"teacherList"
#define PARSE_USER_STUDENT_LIST                                 @"studentList"
#define PARSE_USER_ACCOUNT_ID                                   @"accountId"
#define PARSE_USER_FRINEDS                                      @"friends"
#define PARSE_USER_PRODUCTS                                     @"products"
#define PARSE_USER_PREVIEWPWD                                   @"previewPassword"
#define PARSE_USER_POSTTYPE                                   @"postType"
#define PARSE_USER_INTEREST                                   @"interest"
#define PARSE_USER_GENDER                                   @"genderId"
#define PARSE_USER_PURPOSID                                   @"purposeId"
#define PARSE_USER_MAINGYM                                     @"mainGymId"
#define PARSE_USER_SECONDGYMS                                     @"secondGyms"
#define PARSE_USER_BIO                                     @"bio"
#define PARSE_USER_UNLIKEUSER                                     @"unLikeUser"

// special gym
#define PARSE_TABLE_SPECIALGYM                                     @"Special_gym"
#define FIELD_SPECIALGYM_OWNER                                     @"owner"
#define FIELD_SPECIALGYM_NAME                                    @"name"
#define FIELD_SPECIALGYM_TYPE                                    @"type"
#define FIELD_SPECIALGYM_AVAILABLEDATE                                    @"availableDate"
#define FIELD_BUY_DATE                               @"buy_date"
#define FIELD_BUY_ID                               @"buy_Id"

#define  FIELD_BASEGYMID  @"baseGymId"
#define FIELD_CAPTION                               @"cation"
#define FIELD_REACT_TYPE                                        @"type"
#define  FIELD_REPORTER  @"reporter"
// pending sport table
#define PARSE_TABLE_PENDING_BUDDY                               @"PendingBuddy"
#define FIELD_REQUESTER                                         @"requester"
#define  FIELD_OWNER  @"owner"
// notifications table for reactions
#define PARSE_TABLE_REACT_NOTIFICATIONS                         @"ReactNotifications"

/* Post Table */
#define PARSE_TABLE_POST                                        @"Posts"
#define PARSE_POST_OWNER                                        @"owner"
#define PARSE_POST_IMAGE                                        @"image"
#define PARSE_POST_CATEGORY                                     @"category"
#define PARSE_POST_TITLE                                        @"title"
#define PARSE_POST_TITLE_COLOR                                  @"titleColor"
#define PARSE_POST_LIKES                                        @"liked"
#define PARSE_POST_UNLIKES                                        @"unlikes"
#define PARSE_POST_IS_VIDEO                                     @"isVideo"
#define PARSE_POST_VIDEO                                        @"video"
#define PARSE_POST_DESCRIPTION                                  @"description"
#define PARSE_POST_COMMENT_COUNT                                @"commentCount"
#define PARSE_POST_IS_PRIVATE                                   @"isPrivate"
#define PARSE_POST_VIDEO_THUMBS                              @"video_thumbs"
#define PARSE_POST_VIDEOS                                        @"video"
#define PARSE_POST_IMAGES                               @"images"

/* AD Table */
#define PARSE_TABLE_AD                                        @"Ads"
#define PARSE_AD_OWNER                                        @"owner"
#define PARSE_AD_IMAGE                                        @"image"
#define PARSE_AD_TITLE                                        @"title"
#define PARSE_AD_IS_VIDEO                                     @"isVideo"
#define PARSE_AD_VIDEO                                        @"video"
#define PARSE_AD_DESCRIPTION                                  @"description"
#define PARSE_AD_PRICE                                        @"price"

/*Notification Table*/
#define PARSE_TABLE_NOTIFICATION                                        @"Notification"
#define PARSE_NOTIFICATION_SENDER                                       @"sender"
#define PARSE_NOTIFICATION_RECEIVER                                     @"receiver"
#define PARSE_NOTIFICATION_TYPE                                         @"type"
#define PARSE_NOTIFICATION_READ                                         @"isRead"

#define SYSTEM_NOTIFICATION_TYPE_ACCEPT                                       0
#define SYSTEM_NOTIFICATION_TYPE_LIKE                                         1
#define SYSTEM_NOTIFICATION_TYPE_COMMENT                                      2


/* Comment Table */
#define PARSE_TABLE_COMMENT                                     @"Comment"
#define PARSE_COMMENT_OWNER                                      @"owner"
#define PARSE_COMMENT_POST                                      @"post"
#define PARSE_COMMENT_TEXT                                      @"content"


/*Friends table*/
#define PARSE_TABLE_FRIEND                                        @"Friends"
#define PARSE_FRIEND_SENDER                                       @"sender"
#define PARSE_FRIEND_RECEIVER                                     @"receiver"
#define PARSE_FRIEND_SENDER_ACCEPT                                @"sender_accept"
#define PARSE_FRIEND_RECEIVER_ACCEPT                              @"receiver_accept"


/*Follow table*/
#define PARSE_TABLE_FOLLOW                                      @"Follow"
#define PARSE_FOLLOW_FROM                                       @"fromUser"
#define PARSE_FOLLOW_TO                                         @"toUser"
#define PARSE_FOLLOW_ACTIVE                                     @"isActive"
#define PARSE_FOLLOW_READ                                         @"isRead"

/* Chat Room */
#define PARSE_TABLE_CHAT_ROOM                                   @"ChatRoom"
#define PARSE_ROOM_SENDER                                       @"sender"
#define PARSE_ROOM_RECEIVER                                     @"receiver"
#define PARSE_ROOM_LAST_MESSAGE                                 @"lastMsg"
#define PARSE_ROOM_ENABLED                                      @"isAvailable"
#define PARSE_ROOM_IS_READ                                      @"isRead"
#define PARSE_ROOM_LAST_SENDER                                  @"message_sender"
#define PARSE_ROOM_SENDER_REMOVE                                 @"senderDeleted"
#define PARSE_ROOM_RECEIVER_REMOVE                                 @"receiverDeleted"

/* Chat History */
#define PARSE_TABLE_CHAT_HISTORY                                @"ChatHistory"
#define PARSE_HISTORY_ROOM                                      @"room"
#define PARSE_HISTORY_SENDER                                    @"sender"
#define PARSE_HISTORY_RECEIVER                                  @"receiver"
#define PARSE_HISTORY_TYPE                                      @"type"
#define PARSE_HISTORY_MESSAGE                                   @"message"
#define PARSE_HISTORY_IMAGE                                     @"image"
#define PARSE_HISTORY_VIDEO                                     @"video"

/* Report Table */
#define PARSE_TABLE_REPORT                                      @"Report"
#define PARSE_REPORT_POST                                       @"post"
#define PARSE_REPORT_AD                                       @"ad"
#define PARSE_REPORT_STREAM                                       @"stream"
#define PARSE_REPORT_OWNER                                      @"owner"
#define PARSE_REPORT_REPORTER                                   @"reporter"
#define PARSE_REPORT_TYPE                                       @"type"
#define PARSE_REPORT_DESCRIPTION                                @"description"

/* Purchase Table */
#define PARSE_TABLE_PAYMENT                                      @"Payments"
#define PARSE_PAYMENT_OWNER                                      @"owner"
#define PARSE_PAYMENT_TYPE                                       @"type"

/* AD Table */
#define PARSE_TABLE_STREAMS                                              @"Streams"
#define PARSE_STREAMS_OWNER                                        @"owner"
#define PARSE_STREAMS_IMAGE                                        @"image"
#define PARSE_STREAMS_VIDEO                                        @"video"
#define PARSE_STREAMS_LOCATION                                        @"location"
#define PARSE_STREAMS_DESCRIPTION                                  @"description"
#define PARSE_STREAMS_ISVIDEO                                  @"isVideo"
#define PARSE_STREAMS_ISYOUTUBE                                  @"isYoutube"
#define PARSE_STREAMS_ISRUNNING                                @"isRunning"
#define PARSE_STREAMS_IDENTIFY                                @"streamId"
#define PARSE_STREAMS_YOUTUBEID                                @"youtubeId"


