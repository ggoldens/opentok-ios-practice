//
//  ViewController.h
//  OpentokRTC

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) NSMutableArray *tableData;
@property (weak, nonatomic) IBOutlet UITableView *tableViewObject;

@end
