//
//  ChatViewController.m
//  OpentokRTC

#import "ChatViewController.h"
#import <OpenTok/OpenTok.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface ChatViewController ()

@end

@implementation ChatViewController {
    

    IBOutlet UITableView *messageTableView;
    
    IBOutlet UITextField *txtMessage;
}

@synthesize tableData,tableViewObject;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tableViewObject setDelegate:self];
    [tableViewObject setDataSource:self];
    
    tableData = [[NSMutableArray alloc] init];

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

- (IBAction)onSendButtonTouched:(id)sender {
    [tableData addObject:txtMessage.text];
}




@end
