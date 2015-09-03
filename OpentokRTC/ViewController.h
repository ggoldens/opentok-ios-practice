//
//  ViewController.h
//  OpentokRTC

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong,nonatomic) NSDictionary *roomData;

- (NSString *)getSessionStatus;
- (void)changeStatusLabelColor;

@end
