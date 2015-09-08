//
//  TBoxScreenShare.h
//  OpentokRTC
//
//  Created by Andrea Phillips on 07/09/2015.
//  Copyright (c) 2015 Agilityfeat. All rights reserved.
//
#import <OpenTok/OpenTok.h>

@protocol OTVideoCapture;

/**
 * Periodically sends video frames to an OpenTok Publisher by rendering the
 * CALayer for a UIView.
 */
@interface TBoxScreenShare : NSObject <OTVideoCapture>

@property(readonly) UIView* view;

/**
 * Initializes a video capturer that will grab rendered stills of the view.
 */
- (instancetype)initWithView:(UIView*)view;

@end

