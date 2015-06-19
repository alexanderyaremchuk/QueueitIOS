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

    [self runAsync];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

- (void)runAsync {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:10.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* result = [self.webView stringByEvaluatingJavaScriptFromString:@"foo();"];
            if ([result  isEqual: @"725"]) {
                CustomerLogic* customer = [[CustomerLogic alloc]init];
                self.engine.queuePassedDelegate = customer;
                
                Turn* turnToken = [[Turn alloc]initWithQueueNumber:result];
                [self.engine.queuePassedDelegate notifyYourTurn:turnToken];
                
                [self.host dismissModalViewControllerAnimated:YES];
            }
        });
    });
}

@end
