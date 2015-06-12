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
    
    QueueITEngine* queueRunner = [[QueueITEngine alloc]initWithHost:self];
}

@end
