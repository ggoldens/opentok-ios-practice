//
//  ViewController.h
//  OpentokRTC

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@interface ViewController : UIViewController

@property (strong,nonatomic) NSDictionary *roomData;
@property (nonatomic, strong) IBOutlet UITextField* timeDisplay;
@property (strong,nonatomic) NSString* string1;
@property (strong,nonatomic) NSString* string2;
@property (strong,nonatomic) ChatViewController *chatVC;



- (NSString *)getSessionStatus;
- (void)changeStatusLabelColor;

@end
