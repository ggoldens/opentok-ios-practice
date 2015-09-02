//
//  ViewController.m
//  Hello-World
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import "ViewController.h"
#import <OpenTok/OpenTok.h>

@interface ViewController ()
<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>
@end

@implementation ViewController {
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    
    //Views
    IBOutlet UIView *PublisherView;
    IBOutlet UIView *SubscriberView;
    
    //Buttons
    IBOutlet UIButton *ConnectButton;

    //Labels
    IBOutlet UILabel *StatusLabel;
    
    

}

// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
static NSString* const kApiKey = @"45321952";
// Replace with your generated session ID
static NSString* const kSessionId = @"1_MX40NTMyMTk1Mn5-MTQ0MDUxMzY5MDkyN35Ia2lqZmZUY0JtVlE4TUtmR0s1Vk1rWHZ-UH4";
// Replace with your generated token
static NSString* const kToken = @"T1==cGFydG5lcl9pZD00NTMyMTk1MiZzaWc9ZmMxMzEyYjhlNWI0MTYxYTM4MzEwNjBjOTJiNGM4YzdkNmEyNmY1Nzpyb2xlPW1vZGVyYXRvciZzZXNzaW9uX2lkPTFfTVg0ME5UTXlNVGsxTW41LU1UUTBNRFV4TXpZNU1Ea3lOMzVJYTJscVptWlVZMEp0VmxFNFRVdG1SMHMxVmsxcldIWi1VSDQmY3JlYXRlX3RpbWU9MTQ0MDUxMzcxMyZub25jZT0wLjIwMTc5OTE5MjY5MDA5MTYmZXhwaXJlX3RpbWU9MTQ0MzEwNTY2NCZjb25uZWN0aW9uX2RhdGE9";

// Change to NO to subscribe to streams other than your own.
static bool subscribeToSelf = NO;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Step 1: As the view comes into the foreground, initialize a new instance
    // of OTSession and begin the connection process.
    _session = [[OTSession alloc] initWithApiKey:kApiKey
                                       sessionId:kSessionId
                                        delegate:self];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice]
                                      userInterfaceIdiom])
    {
        return NO;
    } else {
        return YES;
    }
}
#pragma mark - OpenTok methods

/** 
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect
{
    OTError *error = nil;
    
    //Change the text of the status label
    StatusLabel.text = @"Connecting";
    
    //Change the status label color
    StatusLabel.textColor = [UIColor blueColor];
    
    [_session connectWithToken:kToken error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

/**
 * Disconnect from the session
 */
- (void)doDisconnect
{
    OTError *error = nil;
    
    //Change the text of the status label
    StatusLabel.text = @"Disconnecting";
    //Change the status label color
    StatusLabel.textColor = [UIColor blueColor];
    
    [_session disconnect:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

/**
 * Sets up an instance of OTPublisher to use with this session. OTPubilsher
 * binds to the device camera and microphone, and will provide A/V streams
 * to the OpenTok session.
 */
- (void)doPublish
{
    _publisher =
    [[OTPublisher alloc] initWithDelegate:self
                                     name:[[UIDevice currentDevice] name]];
   
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    
    [PublisherView addSubview:_publisher.view];
    [_publisher.view setFrame:CGRectMake(0, 0, PublisherView.bounds.size.width, PublisherView.bounds.size.height)];
}

/**
 * Cleans up the publisher and its view. At this point, the publisher should not
 * be attached to the session any more.
 */
- (void)cleanupPublisher {
    [_publisher.view removeFromSuperview];
    _publisher = nil;
    // this is a good place to notify the end-user that publishing has stopped.
}

/**
 * Instantiates a subscriber for the given stream and asynchronously begins the
 * process to begin receiving A/V content for this stream. Unlike doPublish, 
 * this method does not add the subscriber to the view hierarchy. Instead, we 
 * add the subscriber only after it has connected and begins receiving data.
 */
- (void)doSubscribe:(OTStream*)stream
{
    _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    
    OTError *error = nil;
    [_session subscribe:_subscriber error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

/**
 * Cleans the subscriber from the view hierarchy, if any.
 * NB: You do *not* have to call unsubscribe in your controller in response to
 * a streamDestroyed event. Any subscribers (or the publisher) for a stream will
 * be automatically removed from the session during cleanup of the stream.
 */
- (void)cleanupSubscriber
{
    [_subscriber.view removeFromSuperview];
    _subscriber = nil;
}

# pragma mark - OTSession delegate callbacks

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    
    //Change the text of the status label
    StatusLabel.text = [self getSessionStatus];
    
    //Change the status label color
    [self changeStatusLabelColor];
    
    //Change the text of the button
    [ConnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    // Step 2: We have successfully connected, now instantiate a publisher and
    // begin pushing A/V streams into OpenTok.
    
    
    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
    
    //Change the text of the status label
    StatusLabel.text = [self getSessionStatus];
    
    //Change the status label color
    [self changeStatusLabelColor];
    
    //Change the text of the button
    [ConnectButton setTitle:@"Connect" forState:UIControlStateNormal];
    
    //Clean all the subscribers
    [self cleanupSubscriber];
}


- (void)session:(OTSession*)mySession
  streamCreated:(OTStream *)stream
{
    NSLog(@"session streamCreated (%@)", stream.streamId);
    
    // Step 3a: (if NO == subscribeToSelf): Begin subscribing to a stream we
    // have seen on the OpenTok session.
    if (nil == _subscriber && !subscribeToSelf)
    {
        [self doSubscribe:stream];
    }
}

- (void)session:(OTSession*)session
streamDestroyed:(OTStream *)stream
{
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
}

- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
}

- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
    if ([_subscriber.stream.connection.connectionId
         isEqualToString:connection.connectionId])
    {
        [self cleanupSubscriber];
    }
}

- (void) session:(OTSession*)session
didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
}

# pragma mark - OTSubscriber delegate callbacks

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
    assert(_subscriber == subscriber);
    [_subscriber.view setFrame:CGRectMake(0, 0, SubscriberView.bounds.size.width,
                                         SubscriberView.bounds.size.height)];
    [SubscriberView addSubview:_subscriber.view];
}

- (void)subscriber:(OTSubscriberKit*)subscriber
  didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
}

# pragma mark - OTPublisher delegate callbacks

- (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
{
    // Step 3b: (if YES == subscribeToSelf): Our own publisher is now visible to
    // all participants in the OpenTok session. We will attempt to subscribe to
    // our own stream. Expect to see a slight delay in the subscriber video and
    // an echo of the audio coming from the device microphone.
    if (nil == _subscriber && subscribeToSelf)
    {
        [self doSubscribe:stream];
    }
}

- (void)publisher:(OTPublisherKit*)publisher
  streamDestroyed:(OTStream *)stream
{
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
    
    [self cleanupPublisher];
}

- (void)publisher:(OTPublisherKit*)publisher
 didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
    [self cleanupPublisher];
}

- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
	dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OTError"
                                                         message:string
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] ;
        [alert show];
    });
}

//Actions
- (IBAction)onConnectButtonTouched:(UIButton *)sender {
    if(_session.sessionConnectionStatus==OTSessionConnectionStatusConnected) {
        [self doDisconnect];
    } else {
        [self doConnect];
    }

    
}

//Utils
- (NSString*)getSessionStatus
{
    NSString* connectionStatus = @"";
    if (_session.sessionConnectionStatus==OTSessionConnectionStatusConnected) {
        connectionStatus = @"Connected";
    }else if (_session.sessionConnectionStatus==OTSessionConnectionStatusConnecting) {
        connectionStatus = @"Connecting";
    }else if (_session.sessionConnectionStatus==OTSessionConnectionStatusDisconnecting) {
        connectionStatus = @"Disconnecting";
    }else if (_session.sessionConnectionStatus==OTSessionConnectionStatusNotConnected) {
        connectionStatus = @"Disconnected";
    }else{
        connectionStatus = @"Failed";
    }
    
    return connectionStatus;

}
- (void) changeStatusLabelColor
{
    if (_session.sessionConnectionStatus==OTSessionConnectionStatusConnected) {
        StatusLabel.textColor = [UIColor greenColor];
    }else if (_session.sessionConnectionStatus==OTSessionConnectionStatusConnecting) {
        StatusLabel.textColor = [UIColor blueColor];
    }else if (_session.sessionConnectionStatus==OTSessionConnectionStatusDisconnecting) {
        StatusLabel.textColor = [UIColor blueColor];
    }else {
        StatusLabel.textColor = [UIColor redColor];
    }
}






@end
