#import "QueueITViewController.h"
#import "QueueITEngine.h"

@interface QueueITViewController ()<UIWebViewDelegate>

@property (nonatomic) UIWebView* webView;
@property (nonatomic, strong) UIViewController* host;
@property (nonatomic, strong) QueueITEngine* engine;
@property (nonatomic, strong)NSString* queueUrl;
@property (nonatomic, strong)NSString* eventTargetUrl;
@property (nonatomic, strong)UIActivityIndicatorView* spinner;
@property (nonatomic, strong)NSString* customerId;
@property (nonatomic, strong)NSString* eventId;
@property BOOL isQueuePassed;

@end

@implementation QueueITViewController

-(instancetype)initWithHost:(UIViewController *)host
                queueEngine:(QueueITEngine*) engine
                   queueUrl:(NSString*)queueUrl
             eventTargetUrl:(NSString*)eventTargetUrl
                 customerId:(NSString*)customerId
                    eventId:(NSString*)eventId
{
    self = [super init];
    if(self) {
        self.host = host;
        self.engine = engine;
        self.queueUrl = queueUrl;
        self.eventTargetUrl = eventTargetUrl;
        //self.queueUrl = @"http://queueitselenium.test-q.queue-it.net/queue/queueitselenium/iosappqueue02/12528132-2ae8-4844-9acd-be47e361dcb2/?ua=queueitselenium&app=ios";
        self.customerId = customerId;
        self.eventId = eventId;
        self.isQueuePassed = NO;
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

- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
    navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL* url = [webView.request mainDocumentURL];
    NSString* targetUrl = self.eventTargetUrl;
    
    NSLog(@"Target url: %@", targetUrl);
    NSLog(@"Requested url: %@", url);
    
    if(url != nil) {
        if ([targetUrl containsString:url.host]) {
            
            NSLog(@"Host: %@", url.host);
            
            self.isQueuePassed = YES;
            //[self.engine raiseQueuePassed:queueId];
            [self.host dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self.spinner stopAnimating];
    if (![self.webView isLoading])
    {
        //[self runAsync];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    }
}

-(void)appWillResignActive:(NSNotification*)note
{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Failed to load web view. %@", error.description);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self.host dismissViewControllerAnimated:YES completion:nil];
}

//- (void)runAsync
//{
//    NSString* queueId = [self getQueueId];
//    if (queueId)
//    {
//        if (!self.isQueuePassed)
//        {
//            self.isQueuePassed = YES;
//            [self.engine raiseQueuePassed:queueId];
//            [self.host dismissViewControllerAnimated:YES completion:nil];
//        }
//    }
//    else
//    {
//        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [NSThread sleepForTimeInterval:1.0f];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self runAsync];
//            });
//        });
//    }
//}
//
//-(NSString*)getQueueId
//{
//    NSString* queueId = [self.webView stringByEvaluatingJavaScriptFromString:@"GetQueueIdWhenRedirectedToTarget();"];
//    if ([queueId length] > 0) {
//        return queueId;
//    }
//    return nil;
//}

@end