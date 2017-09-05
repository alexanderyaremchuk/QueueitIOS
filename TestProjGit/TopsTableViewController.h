#import <UIKit/UIKit.h>
#import "QueueITEngine.h"
#import "QueuePassedInfo.h"

@interface TopsTableViewController : UITableViewController<QueuePassedDelegate, QueueViewWillOpenDelegate, QueueDisabledDelegate, QueueITUnavailableDelegate, QueueUserExitedDelegate>
-(void)initAndRunQueueIt;
@end
