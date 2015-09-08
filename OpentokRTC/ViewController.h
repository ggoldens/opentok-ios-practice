//
//  ViewController.h
//  OpentokRTC

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong,nonatomic) NSDictionary *roomData;
@property (nonatomic, strong) IBOutlet UITextField* timeDisplay;

- (NSString *)getSessionStatus;
- (void)changeStatusLabelColor;

@end
