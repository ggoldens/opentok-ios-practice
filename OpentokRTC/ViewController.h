//
//  ViewController.h
//  Hello-World
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong,nonatomic) NSDictionary *roomData;

- (NSString *)getSessionStatus;
- (void)changeStatusLabelColor;

@end
