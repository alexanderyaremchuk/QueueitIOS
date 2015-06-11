#import "ShopViewController.h"
#import "CustomerLogic.h"

@interface ShopViewController ()<UIWebViewDelegate>
@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* urlAddress = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:urlAddress];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
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
        [NSThread sleepForTimeInterval:5.0f];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* result = [self.webView stringByEvaluatingJavaScriptFromString:@"foo();"];
            if ([result  isEqual: @"your turn"]) {
                self.webView.hidden = NO;
                
                CustomerLogic* customer = [[CustomerLogic alloc]init];
                self.yourTurnDelegate = customer;
                
                Turn* turnToken = [[Turn alloc]initWithQueueNumber:result];
                [self.yourTurnDelegate notifyYourTurn:turnToken];
            }
        });
        
        [NSThread sleepForTimeInterval:5.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.webView.hidden = YES;
        });
    });
}

@end
