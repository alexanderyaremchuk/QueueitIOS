#import "ShellViewController.h"
#import "QueueITViewController.h"
#import "QueueITEngine.h"
#import "QueueService.h"
#import "QueueStatus.h"

@interface ShellViewController ()
@end

@implementation ShellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor orangeColor]];
    UILabel* nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 10, 200, 50)];
    nameLabel.text = @"Host app's page";
    [self.view addSubview:nameLabel];
    
    __weak typeof(self) weakSelf = self;
    
    [[QueueService sharedInstance] enqueue:@"frwitest"
                            eventOrAliasId:@"queue0515"
                                    userId:@"A" userAgent:@"B"
                                   success:^(QueueStatus *queueStatus)
                                   {
                                   }

                                   failure:^(NSError *error)
                                   {
                                   }];
    
    //QueueITEngine* engine = [[QueueITEngine alloc]initWithHost:self];

}

@end
