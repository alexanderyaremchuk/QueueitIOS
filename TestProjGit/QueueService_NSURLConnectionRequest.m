#import "QueueService_NSURLConnectionRequest.h"


@interface QueueService_NSURLConnectionRequest()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, copy) QueueServiceSuccess successCallback;
@property (nonatomic, copy) QueueServiceFailure failureCallback;
@property (nonatomic, weak) id<QueueService_NSURLConnectionRequestDelegate> delegate;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@end

@implementation QueueService_NSURLConnectionRequest

- (instancetype)initWithRequest:(NSURLRequest *)request
                        success:(QueueServiceSuccess)success
                        failure:(QueueServiceFailure)failure
                       delegate:(id<QueueService_NSURLConnectionRequestDelegate>)delegate
{
    if ((self = [super init])) {
        self.request = request;
        self.successCallback = success;
        self.failureCallback = failure;
        self.uniqueIdentifier = [[NSUUID UUID] UUIDString];
        self.delegate = delegate;
        
        [self initiateRequest];
    }
    
    return self;
}

- (void)initiateRequest
{
    self.response = nil;
    self.data = [NSMutableData data];
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSURLRequest *request = [connection originalRequest];
    
    NSLog(@"%@ %@ FAIL %@", [request HTTPMethod], [request URL], error);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.failureCallback(error);
    });
    
    [self.delegate requestDidComplete:self];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSURLRequest *request = [connection originalRequest];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.successCallback(self.data);
    });
    
    if (self.data) {
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&jsonError];
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            NSString *errorMessage = [(NSDictionary *)json valueForKey:@"error"];
            if (errorMessage) {
                
            }
        }
    }
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        //self.failureCallback(error);
    //});
    
    [self.delegate requestDidComplete:self];
}

#pragma mark - Private helpers

- (void)appendData:(NSData *)data
{
    [self.data appendData:data];
}


@end
