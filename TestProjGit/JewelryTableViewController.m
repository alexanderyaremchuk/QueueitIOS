#import "JewelryTableViewController.h"

@interface JewelryTableViewController ()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *images;
@property(nonatomic, strong)QueueITEngine* engine;
@end

@implementation JewelryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *data = @[@"Juice Bangle", @"Starfish Cuff", @"Basket surprise"];
    NSArray *imagesData = @[@"b.jpeg", @"c.jpeg", @"d.jpeg"];
    
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
    NSString* customerId = @"frwitest";
    NSString* eventAlias = @"iosapp";
    
    self.engine = [[QueueITEngine alloc]initWithHost:self customerId:customerId eventOrAliasId:eventAlias];
    self.engine.queuePassedDelegate = self;
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

-(void) notifyYourTurn:(Turn *)turn
{
    NSLog(@"Your queue number is: %@", turn.queueId);
    NSString* message = [NSString stringWithFormat: @"Jewelry: You are through the queue. Your queue number is: %@", turn.queueId];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your turn" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
