#import "TopsTableViewController.h"

@interface TopsTableViewController ()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *images;
@property(nonatomic, strong)QueueITEngine* engine;
@end

@implementation TopsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *data = @[@"Amelia Tunic", @"Sarasota", @"Arya Tank Top", @"Minka Trapese"];
    NSArray *imagesData = @[@"1.jpeg", @"2.jpeg", @"3.jpeg", @"4.jpeg"];
    
    self.items = [[NSMutableArray alloc]init];
    self.images = [[NSMutableArray alloc]init];
    
    for (NSString *item in data) {
        [self.items addObject:item];
    }
    
    for (NSString *item in imagesData) {
        [self.images addObject:item];
    }
    
    [self initAndRunQueueIt];
}

-(void)initAndRunQueueIt
{
    //NSString* customerId = @"alyatest";
    NSString* customerId = @"alex";
    NSString* eventAlias = @"iosapp";
    NSString* layoutName = @"mobileios";
    NSString* language = @"en-US";
    
    self.engine = [[QueueITEngine alloc]initWithHost:self customerId:customerId eventOrAliasId:eventAlias layoutName:layoutName language:language];
    self.engine.queuePassedDelegate = self;
    self.engine.queueViewWillOpenDelegate = self;
    self.engine.queueDisabledDelegate = self;
    [self.engine run];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    cell.textLabel.text = [self.items objectAtIndex:indexPath.row];
    
    
    cell.imageView.image = [UIImage imageNamed:[self.images objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) notifyYourTurn:(NSString *)queueId
{
    NSLog(@"Your queue number is: %@ : TopsTableViewController", queueId);
    NSString* message = [NSString stringWithFormat: @"Tops: You are through the queue. Your queue number is: %@", queueId];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your turn" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void) notifyQueueViewWillOpen
{
    NSLog(@"Queue will open");
}

-(void) notifyQueueDisabled
{
    NSLog(@"Queue is disabled");
}

@end
