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
    NSString* customerId = @"sasha";
    NSString* eventAlias = @"wed5";
    NSString* layoutName = @"mobileios";
    NSString* language = @"en-US";
    
    self.engine = [[QueueITEngine alloc]initWithHost:self customerId:customerId eventOrAliasId:eventAlias layoutName:layoutName language:language];
    [self.engine setViewDelay:5];
    self.engine.queuePassedDelegate = self;
    self.engine.queueViewWillOpenDelegate = self;
    self.engine.queueDisabledDelegate = self;
    
    [self testOne];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self testSome];
//    });
    
    NSLog(@"user is %@ queue: from initAndRunQueueIt", self.engine.isUserInQueue ? @"in" : @"out of");
}

-(void)testOne {
    @try
    {
        [self.engine run];
    }
    @catch (NSException *exception)
    {
        if ([exception reason] == [self.engine errorTypeEnumToString:NetworkUnavailable]) {
            NSLog(@"%@", [exception reason]);
            NSLog(@"Network unavailable was caught in TopsTableViewController");
            NSLog(@"isRequestInProgress - %@", self.engine.isRequestInProgress ? @"YES" : @"NO");
        } else {
            NSLog(@"Other exception was caught in TopsTableViewController");
        }
    }
}


-(void) testSome
{
    for (int i = 0; i < 35; i++) {
        @try
        {
            [self.engine run];
        }
        @catch (NSException *exception)
        {
            NSLog(@"%@", [exception reason]);
            NSLog(@"isRequestInProgress - %@", self.engine.isRequestInProgress ? @"YES" : @"NO");
            [NSThread sleepForTimeInterval:2.0f];
        }
    }
}

-(void) testMany
{
    @try
    {
        for (int i = 0; i < 10; i++) {
            [self.engine run];
        }
    }
    @catch (NSException *exception)
    {
        if ([exception reason] == [self.engine errorTypeEnumToString:RequestAlreadyInProgress]) {
            NSLog(@"Request already in progress was caught in TopsTableViewController");
        } else {
            NSLog(@"Other exception was caught in TopsTableViewController");
        }
        
        NSLog(@"%@", [exception reason]);
        NSLog(@"isRequestInProgress - %@", self.engine.isRequestInProgress ? @"YES" : @"NO");
        [NSThread sleepForTimeInterval:2.0f];
        [self testMany];
    }
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

-(void) notifyYourTurn
{
    NSLog(@"user is %@ queue: from 'notifyYourTurn", self.engine.isUserInQueue ? @"in" : @"out of");
    NSLog(@"TopsTableViewController. There is no more queueId");
    NSString* message = [NSString stringWithFormat: @"Tops: You are through the queue."];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your turn" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    NSLog(@"isRequestInProgress - %@", self.engine.isRequestInProgress ? @"YES" : @"NO");
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
