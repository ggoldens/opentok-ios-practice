//
//  JoinViewController.m
//  OpentokRTC
//
//  Created by Andrea Phillips on 02/09/2015.
//  Copyright (c) 2015 Agilityfeat. All rights reserved.
//

#import "JoinViewController.h"

@interface JoinViewController ()

@end

@implementation JoinViewController

@synthesize userName;
@synthesize roomName;
@synthesize roomToken;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRecipeDetail"]) {
        segue.destinationViewController.userName = self.userName.text;
        segue.destinationViewController.roomName = self.roomName.text;
        segue.destinationViewController.tokenName = self.roomToken.text;

    }
}


@end
