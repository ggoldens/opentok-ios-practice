//
//  ChatViewController.m
//  OpentokRTC

#import "ChatViewController.h"
#import "ViewController.h"
#import <OpenTok/OpenTok.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface ChatViewController ()

@end

@implementation ChatViewController {
    
    
    IBOutlet UITableView *messageTableView;
    
    IBOutlet UITextField *txtMessage;
    OTSubscriber* _subscriber;

}

@synthesize tableData,tableViewObject;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tableViewObject setDelegate:self];
    [tableViewObject setDataSource:self];
    tableData = [[NSMutableArray alloc] init];
    

    //Defining the notification to receive chat messages
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveChatMessageNotification:)
                                                 name:@"newChatMessageReceived"
                                               object:nil];

    
}

- (void) receiveChatMessageNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"newChatMessageReceived"]) {
        [self appendMessageToTable:notification.userInfo[@"message"]];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - markup TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    
    return [tableData count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    static NSString *simpleTableIdentifier = @"MessageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:@"geekPic.jpg"];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Selected Value is %@",[tableData objectAtIndex:indexPath.row]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [alertView show];
    
}

- (void) appendMessageToTable:(NSString*)message
{
    //append the new message
    [tableData addObject:message];
    
    //Reload the tableView
    [tableViewObject reloadData];
    
    //Scroll to bottom
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: [tableData count]-1 inSection: 0];
    [tableViewObject scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];

}

- (IBAction)onSendButtonTouched:(id)sender {
    
    [self appendMessageToTable:txtMessage.text];
    [self sendMessage:txtMessage.text];
    
    //empty the textField
    txtMessage.text = @"";
    
}

- (void)sendMessage:(NSString*)message
{
    
    NSDictionary *userInfo = @{@"message": message};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sendChatMessage"
     object:self
     userInfo:userInfo];
    
}
- (IBAction)onBackButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}








@end
