//
//  JoinViewController.m
//  OpentokRTC
//
//  Created by Andrea Phillips on 02/09/2015.
//  Copyright (c) 2015 Agilityfeat. All rights reserved.
//

#import "JoinViewController.h"
#import "ViewController.h"

@interface JoinViewController ()

@property (nonatomic, weak) IBOutlet UITextField *userName;
@property (nonatomic, weak) IBOutlet UITextField *roomName;
@property (nonatomic, weak) IBOutlet UITextField *roomToken;

@end

@implementation JoinViewController

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
    if ([segue.identifier isEqualToString:@"showJoin"]) {
        ViewController *vc = [segue destinationViewController];
        NSDictionary *data = @{
                               @"user" : self.userName.text,
                               @"room" : self.roomName.text,
                               @"token" : self.roomToken.text,
                            };
        
        vc.roomData = data;
        
    }
}


@end
