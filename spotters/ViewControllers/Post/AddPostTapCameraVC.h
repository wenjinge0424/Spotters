//
//  AddPostTapCameraVC.h
//  Spotters
//
//  Created by developer on 6/20/18.
//  Copyright © 2018 com.brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol MyCaptureDelegate <NSObject>
- (void) myCaptureDelegate : (UIImage*) capturedImage;
- (void) myCaptureVideoThumbDelegate : (UIImage*) capturedVideoThumb :(NSString*)videoFilePath;
//- (void) myCaptureDelegate : (UIImage*) capturedImage;
@end

@interface AddPostTapCameraVC : BaseViewController
@property (atomic) NSInteger mType;
@property (nonatomic, weak) id <MyCaptureDelegate> delegate;
@end
