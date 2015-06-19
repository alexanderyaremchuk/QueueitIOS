#import "QueueITViewController.h"
#import "CustomerLogic.h"
#import "QueueITEngine.h"

@interface QueueITViewController ()<UIWebViewDelegate>

@property (nonatomic) UIWebView* webView;
@property (nonatomic, strong) UIViewController* host;
@property (nonatomic, strong) QueueITEngine* engine;
@property (nonatomic, strong)NSString* queueUrl;

@end

@implementation QueueITViewController

static int loadCount = 0;

-(instancetype)initWithHost:(UIViewController *)host queueEngine:(QueueITEngine*) engine
                   queueUrl:(NSString*)queueUrl
{
    self = [super init];
    if(self) {
        self.host = host;
        self.engine = engine;
        self.queueUrl = queueUrl;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.webView];
    
    //NSString* urlAddress = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    //NSURL *url = [NSURL fileURLWithPath:urlAddress];
    //NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
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
        Turn* turnToken = [[Turn alloc]initWithQueueNumber:@"725"];
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
