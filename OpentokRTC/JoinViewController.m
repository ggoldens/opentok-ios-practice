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
@property (strong,nonatomic) NSString *backendUrl;

@end

@implementation JoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.backendUrl = @"https://opentokrtc-backend.herokuapp.com";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation*/

- (void) doRequest: (NSDictionary*)parameters  toUrl:(NSString*)url
{
    //Create the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    //Set request method to POST
    [request setHTTPMethod:@"POST"];
    
    //parse parameters to json format
    NSError * error = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONReadingMutableContainers error:&error];
    
    //NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               json = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:nil];
                               NSLog(@"Async JSON: %@", json);
                           }];
}

- (void) startNewRoom:(NSString*)userName withRoomName:(NSString*)roomName
{
    //Define json data parameters
    NSDictionary *parameters = @{
                                 @"room_name" : roomName,
                                 @"name" : userName
                                 };
    //Define the end-point url
    NSString *url = [NSString stringWithFormat:@"%@/%@", self.backendUrl, @"create-new-room"];
    
    //Execute request
    [self doRequest:parameters toUrl: url];
}

- (void) joinRoom:(NSString*)userName withToken:(NSString*)token
{
    //Define json data parameters
    NSDictionary *parameters = @{
                                 @"_id" : token,
                                 @"name" : userName
                                 };
    //Define the end-point url
    NSString *url = [NSString stringWithFormat:@"%@/%@", self.backendUrl, @"join-room"];
    
    //Execute request
    [self doRequest:parameters toUrl: url];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ViewController *vc = [segue destinationViewController];
    if ([segue.identifier isEqualToString:@"showJoin"]) {
        [self joinRoom:self.userName.text withToken:self.roomToken.text];
        NSDictionary *data = @{
                               @"user" : self.userName.text,
                               @"token" : self.roomToken.text,
                            };
        vc.roomData = data;
        
    } else {
       [self startNewRoom:self.userName.text withRoomName:self.roomName.text];
        NSDictionary *data = @{
                               @"user" : self.userName.text,
                               @"room" : self.roomName.text
                              };
        vc.roomData = data;
    }
}


@end
