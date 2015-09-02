//
//  ViewController.h
//  Hello-World
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak,nonatomic) NSString *userName;
@property (weak,nonatomic) NSString *roomName;
@property (weak,nonatomic) NSString *roomToken;

- (NSString *)getSessionStatus;
- (void)changeStatusLabelColor;

@end
