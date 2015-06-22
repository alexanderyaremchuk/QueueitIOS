#import "ShellViewController.h"
#import "QueueITViewController.h"
#import "QueueITEngine.h"

@interface ShellViewController ()
@end

@implementation ShellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor orangeColor]];
    UILabel* nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 10, 200, 50)];
    nameLabel.text = @"Host app's page";
    [self.view addSubview:nameLabel];
    
    NSString* safetyNetId = @"safetynet0515"; //ISSUE: returns requeryInterval is null, queueUrl is null, only queueId has value;
    NSString* queueEventId = @"queue0515";
    NSString* idleEventId = @"idle4life"; //ISSUE: idle page loads and stays indefinetely, what to do with it?
    NSString* disabledEventId = @"disabled062015"; //ISSUE: has requeryInterval set, but never delivers any queryUrl after continuous requests
    
    QueueITEngine* engine = [[QueueITEngine alloc]initWithHost:self
                                                    customerId:@"frwitest"
                                                eventOrAliasId:safetyNetId];
    //engine.queuePassedDelegate = self;
    
}

-(void) notifyYourTurn:(Turn *)turn
{
    NSLog(@"Your queue number is: %@", turn.queueNumber);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your turn"
                                                    message: [NSString stringWithFormat: @"You are through the queue. Your queue number is: %@", turn.queueNumber]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end