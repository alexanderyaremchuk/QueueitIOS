#import <UIKit/UIKit.h>
#import "QueueITEngine.h"

@interface TopsTableViewController : UITableViewController<QueuePassedDelegate, QueueTokenDelegate, QueueViewWillOpenDelegate, QueueDisabledDelegate, QueueITUnavailableDelegate, QueueUserExitedDelegate>
-(void)initAndRunQueueIt;
@end
