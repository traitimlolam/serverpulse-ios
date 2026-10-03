#import <UIKit/UIKit.h>

@protocol SettingsDelegate <NSObject>
- (void)settingsDidUpdate;
@end

@interface SettingsViewController : UIViewController
@property (nonatomic, weak) id<SettingsDelegate> delegate;
@end
