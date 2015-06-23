#import "QueueITViewController.h"
#import "CustomerLogic.h"
#import "QueueITEngine.h"

@interface QueueITViewController ()<UIWebViewDelegate>

@property (nonatomic) UIWebView* webView;
@property (nonatomic, strong) UIViewController* host;
@property (nonatomic, strong) QueueITEngine* engine;
@property (nonatomic, strong)NSString* queueUrl;
@property (nonatomic, strong)UIActivityIndicatorView* spinner;
@property (nonatomic, strong)NSString* customerId;
@property (nonatomic, strong)NSString* eventId;

@end

@implementation QueueITViewController

static int loadCount = 0;

-(instancetype)initWithHost:(UIViewController *)host
                queueEngine:(QueueITEngine*) engine
                   queueUrl:(NSString*)queueUrl
                 customerId:(NSString*)customerId
                    eventId:(NSString*)eventId
{
    self = [super init];
    if(self) {
        self.host = host;
        self.engine = engine;
        self.queueUrl = queueUrl;
        self.customerId = customerId;
        self.eventId = eventId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    self.spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.spinner setColor:[UIColor grayColor]];
    [self.spinner startAnimating];
    
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.webView];
    [self.webView addSubview:self.spinner];
    
    NSURL *urlAddress = [NSURL URLWithString:self.queueUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlAddress];
    [self.webView loadRequest:request];
    self.webView.delegate = self;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self.spinner stopAnimating];
    if (![self.webView isLoading])
    {
        loadCount++;
        [self runAsync];
    }
    
    //if loadCount > 1 -> consider what to do here instead of running [self runAsync]
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

- (void)runAsync
{
    if ([self isDone])
    {
        //TODO: get queueId from js and pass below
        Turn* turnToken = [[Turn alloc]initWithQueueNumber:@"SHOULD BE RETURNED FROM JS CALL" customerId:self.customerId eventId:self.eventId];
        [self.engine.queuePassedDelegate notifyYourTurn:turnToken];
        [self.host dismissModalViewControllerAnimated:YES];
    }
    else
    {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:1.0f];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self runAsync];
            });
        });
    }
}

-(BOOL)isDone{
    NSString* result = [self.webView stringByEvaluatingJavaScriptFromString:@"GetQueueStatus();"];
    if ([result  isEqual: @"true"]) {
        return YES;
    }
    return NO;
}

//-(BOOL)isDone{
//    NSString* result = [self.webView stringByEvaluatingJavaScriptFromString:@"GetQueueStatus();"];
//    if ([result  isEqual: @"true"] || loadCount > 1) {
//            return YES;
//        }
//    return NO;
//}

@end
