//
//  JoinViewController.h
//  OpentokRTC
//
//  Created by Andrea Phillips on 02/09/2015.
//  Copyright (c) 2015 Agilityfeat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JoinViewController : UIViewController
- (void) startNewRoom:(NSString*)userName withRoomName:(NSString*)roomName;
- (void) doRequest: (NSDictionary*)parameters  toUrl:(NSString*)url;
- (void) joinRoom:(NSString*)userName withToken:(NSString*)token;

@end


