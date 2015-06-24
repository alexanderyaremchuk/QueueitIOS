#import "ShellViewController.h"
#import "QueueITViewController.h"
#import "QueueITEngine.h"

@interface ShellViewController ()
@property(nonatomic, strong)QueueITEngine* engine;
@end

@implementation ShellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor orangeColor]];
    UILabel* nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 10, 200, 50)];
    nameLabel.text = @"Host app's page";
    [self.view addSubview:nameLabel];
    
    NSString* safetyNetId = @"safetynet0515";
    NSString* queueEventId = @"queue0515";
    NSString* idleEventId = @"idle4life";
    NSString* disabledEventId = @"disabled062015";
    
    self.engine = [[QueueITEngine alloc]initWithHost:self
                                          customerId:@"frwitest"
                                      eventOrAliasId:queueEventId];
    self.engine.queuePassedDelegate = self;
    [self.engine run];
}

-(void) notifyYourTurn:(Turn *)turn
{
    NSLog(@"Your queue number is: %@", turn.queueId);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your turn"
                                                    message: [NSString stringWithFormat: @"You are through the queue. Your queue number is: %@", turn.queueId]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end