//
//  ViewController.m
//  OpentokRTC

#import "ViewController.h"
#import <OpenTok/OpenTok.h>
#import "TBoxScreenShare.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface ViewController ()
<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>
@end

@implementation ViewController {
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    
    dispatch_queue_t  _queue;
    dispatch_source_t _timer;
    
    //Views
    IBOutlet UIView *PublisherView;
    IBOutlet UIView *SubscriberView;
    
    //Buttons
    IBOutlet UIButton *ConnectButton;
    
    IBOutlet UIButton *muteBtn;
    IBOutlet UIButton *videoBtn;
    //Labels
    IBOutlet UILabel *WelcomeLabel;
    IBOutlet UILabel *StatusLabel;
    IBOutlet UILabel *RoomLabel;
    IBOutlet UILabel *TalkingWithLabel;
    
    //Texts
    IBOutlet UITextField *txtToken;

    //Buttons
    IBOutlet UIButton *CopyTokenButton;
}

// Change to NO to subscribe to streams other than your own.
static bool subscribeToSelf = NO;
static bool publisherMuted = NO;
static bool publisherStreaming = YES;
static bool screenSharing = NO;


@synthesize timeDisplay;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RoomLabel.text = self.roomData[@"apiData"][@"room"][@"room_name"];
    txtToken.text = self.roomData[@"apiData"][@"room"][@"_id"];
    WelcomeLabel.text = [NSString stringWithFormat: @"Hello, %@", self.roomData[@"user"]];
    
    TalkingWithLabel.text = @"";
    
    // Setup a timer to periodically update the UI. This gives us something
    // dynamic that we can see on the receiver's end to verify everything works.
    _queue = dispatch_queue_create("ticker-timer", 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0),
                              10ull * NSEC_PER_MSEC, 1ull * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(_timer, ^{
        double timestamp = [[NSDate date] timeIntervalSince1970];
        int64_t timeInMilisInt64 = (int64_t)(timestamp*1000);
        
        NSString *mills = [NSString stringWithFormat:@"%lld", timeInMilisInt64];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.timeDisplay setText:mills];
        });
    });
    
    dispatch_resume(_timer);

    
    
    // Step 1: As the view comes into the foreground, initialize a new instance
    // of OTSession and begin the connection process.
    _session = [[OTSession alloc] initWithApiKey:self.roomData[@"apiData"][@"apiKey"]
                                       sessionId:self.roomData[@"apiData"][@"room"][@"sessionid"]
                                        delegate:self];
    
    //Do connect
    [self doConnect];
    
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
    
    ConnectButton.hidden = YES;
    
    
    //Change the status label color
    StatusLabel.textColor = [UIColor blueColor];
    
    [_session connectWithToken:self.roomData[@"apiData"][@"token"] error:&error];
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
    [PublisherView sendSubviewToBack:_publisher.view];
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
    //TalkingWithLabel.text = @"";
    
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
    
    //Show disconnect Button
    ConnectButton.hidden = NO;
    
    
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
    
    TalkingWithLabel.text = @"";
    
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
    NSString *text = [[NSString alloc] initWithFormat:@"Connected with %@", subscriber.stream.connection.data];
    TalkingWithLabel.text = text;
    NSLog(@"%@", text);
    
    assert(_subscriber == subscriber);
    [_subscriber.view setFrame:CGRectMake(0, 0, SubscriberView.bounds.size.width,
                                          SubscriberView.bounds.size.height)];
    [SubscriberView addSubview:_subscriber.view];
    [SubscriberView sendSubviewToBack: _subscriber.view];
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
- (IBAction)mute:(UIButton *)sender {
    publisherMuted = !publisherMuted;
    if(publisherMuted){
        muteBtn.alpha = 0.5;
    }else{
        muteBtn.alpha = 1;
    }
    [_publisher setPublishAudio:!publisherMuted];
    NSLog(@"MUTE");
}

- (IBAction)videoChange:(UIButton *)sender {
    publisherStreaming = !publisherStreaming;
    if(publisherStreaming){
        videoBtn.alpha = 0.5;
    }else{
        videoBtn.alpha = 1;
    }
    [_publisher setPublishVideo:!publisherStreaming];
}

- (IBAction)screenShareTouch:(id)sender {
    screenSharing = !screenSharing;
    if(screenSharing){
        [_publisher setVideoType:OTPublisherKitVideoTypeCamera];
        
        // This disables the audio fallback feature when using routed sessions.
        _publisher.audioFallbackEnabled = YES;
        
    }else{
        
        // Additionally, the publisher video type can be updated to signal to
        // receivers that the video is from a screencast. This value also disables
        // some downsample scaling that is used to adapt to changing network
        // conditions. We will send at a lower framerate to compensate for this.
        [_publisher setVideoType:OTPublisherKitVideoTypeScreen];
        
        // This disables the audio fallback feature when using routed sessions.
        _publisher.audioFallbackEnabled = NO;
        
        // Finally, wire up the video source.
        TBoxScreenShare* videoCapture = [[TBoxScreenShare alloc] initWithView:self.view];
        [_publisher setVideoCapture:videoCapture];
        
        
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

- (IBAction)onCloseTouched:(id)sender {
    
    [self doDisconnect];
}





@end
