//
//  ViewController.h
//  OpentokRTC

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) NSDictionary *roomData;
@property (nonatomic,retain) NSMutableArray *tableData;
@property (weak, nonatomic) IBOutlet UITableView *tableViewObject;

- (void) appendMessageToTable:(NSString*)message;
@end
