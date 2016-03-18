#import <UIKit/UIKit.h>
#import "QueueITEngine.h"
#import "QueueITViewController.h"
#import "QueueService.h"
#import "QueueStatus.h"
#import "IOSUtils.h"
#import "Reachability.h"
#import "QueueCache.h"

@interface QueueITEngine()
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic, strong)UIViewController* host;
@property (nonatomic, strong)NSString* customerId;
@property (nonatomic, strong)NSString* eventId;
@property (nonatomic, strong)NSString* layoutName;
@property (nonatomic, strong)NSString* language;
@property int delayInterval;
@property bool isInQueue;
@property bool requestInProgress;
@property int queueUrlTtl;
@property (nonatomic, strong)QueueCache* cache;
@property int deltaSec;
@end

@implementation QueueITEngine

static int MAX_RETRY_SEC = 10;
static int INITIAL_WAIT_RETRY_SEC = 1;

-(instancetype)initWithHost:(UIViewController *)host customerId:(NSString*)customerId eventOrAliasId:(NSString*)eventOrAliasId layoutName:(NSString*)layoutName language:(NSString*)language
{
    self = [super init];
    if(self) {
        self.cache = [QueueCache instance:customerId eventId:eventOrAliasId];
        self.host = host;
        self.customerId = customerId;
        self.eventId = eventOrAliasId;
        self.layoutName = layoutName;
        self.language = language;
        self.delayInterval = 0;
        self.isInQueue = NO;
        self.requestInProgress = NO;
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        self.deltaSec = INITIAL_WAIT_RETRY_SEC;
    }
    return self;
}

-(void)setViewDelay:(int)delayInterval {
    self.delayInterval = delayInterval;
}

-(void)checkConnection
{
    int count = 0;
    while (count < 5)
    {
        NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
        if (netStatus == NotReachable)
        {
            [NSThread sleepForTimeInterval:1.0f];
            count++;
        }
        else
        {
            return;
        }
    }
    @throw [NSException exceptionWithName:@"QueueITRuntimeException" reason:[self errorTypeEnumToString:NetworkUnavailable] userInfo:nil];
}

-(NSString*) errorTypeEnumToString:(QueueITRuntimeError)errorEnumVal
{
    NSArray *errorTypeArray = [[NSArray alloc] initWithObjects:QueueITRuntimeErrorArray];
    return [errorTypeArray objectAtIndex:errorEnumVal];
}

-(BOOL)isUserInQueue {
    return self.isInQueue;
}

-(BOOL)isRequestInProgress {
    return self.requestInProgress;
}

-(void)run
{
    [self checkConnection];
    
    if(self.requestInProgress)
    {
        @throw [NSException exceptionWithName:@"QueueITRuntimeException" reason:[self errorTypeEnumToString:RequestAlreadyInProgress] userInfo:nil];
    }
    
    self.requestInProgress = YES;
    
    if (![self tryShowQueueFromCache]) {
        [self tryEnqueue];
    }
    
}

-(BOOL)tryShowQueueFromCache
{
    if (![self.cache isEmpty])
    {
        NSString* urlTtlString = [self.cache getUtlTtl];
        long long cachedTime = [urlTtlString longLongValue];
        long currentTime = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
        if (currentTime < cachedTime)
        {
            NSString* targetUrl = [self.cache getTargetUrl];
            
            NSString* queueUrl = [self.cache getQueueUrl];
            //queueUrl = [NSString stringWithFormat:@"%@_HELLO_%@", [queueUrl substringToIndex:65], [queueUrl substringFromIndex:67]];
            
            NSLog(@"%@",queueUrl);
            
            [self showQueue:queueUrl targetUrl:targetUrl];
            return YES;
        }
    }
    return NO;
}

-(void)showQueue:(NSString*)queueUrl targetUrl:(NSString*)targetUrl
{
    [self raiseQueueViewWillOpen];
    QueueITViewController *queueVC = [[QueueITViewController alloc] initWithHost:self.host
                                                                     queueEngine:self
                                                                        queueUrl:queueUrl
                                                                  eventTargetUrl:targetUrl
                                                                      customerId:self.customerId
                                                                         eventId:self.eventId];

    if (self.delayInterval > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.host presentViewController:queueVC animated:YES completion:nil];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.host presentViewController:queueVC animated:YES completion:nil];
        });
    }
}

-(void)tryEnqueue
{
    NSString* userId = [IOSUtils getUserId];
    NSString* userAgent = [NSString stringWithFormat:@"%@;%@", [IOSUtils getUserAgent], [IOSUtils getLibraryVersion]];
    NSString* sdkVersion = [IOSUtils getSdkVersion];
    
    QueueService* qs = [QueueService sharedInstance];
    [qs enqueue:self.customerId
 eventOrAliasId:self.eventId
         userId:userId userAgent:userAgent
        sdkVersion:sdkVersion
     layoutName:self.layoutName
       language:self.language
        success:^(QueueStatus *queueStatus)
         {
             //SafetyNet
             if (queueStatus.queueId != (id)[NSNull null] && queueStatus.queueUrlString == (id)[NSNull null] && queueStatus.requeryInterval == 0)
             {
                 self.requestInProgress = NO;
             }
             //InQueue
             else if (queueStatus.queueId != (id)[NSNull null] && queueStatus.queueUrlString != (id)[NSNull null] && queueStatus.requeryInterval == 0)
             {
                 self.queueUrlTtl = queueStatus.queueUrlTTL;
                 [self showQueue:queueStatus.queueUrlString targetUrl:queueStatus.eventTargetUrl];
                 
                 NSString* urlTtlString = [self convertTtlMinutesToSecondsString:queueStatus.queueUrlTTL];
                 [self.cache update:queueStatus.queueUrlString urlTTL:urlTtlString targetUrl:queueStatus.eventTargetUrl];
             }
             //Idle
             else if (queueStatus.queueId == (id)[NSNull null] && queueStatus.queueUrlString != (id)[NSNull null] && queueStatus.requeryInterval == 0)
             {
                 [self showQueue:queueStatus.queueUrlString targetUrl:queueStatus.eventTargetUrl];
             }
             //Disabled
             else if (queueStatus.requeryInterval > 0)
             {
                 self.requestInProgress = NO;
                 [self raiseQueueDisabled];
             }
         }
        failure:^(NSError *error, NSString* errorMessage)
         {
             if (error.code >= 400 && error.code < 500)
             {
                 @throw [NSException exceptionWithName:@"QueueITConfigurationException" reason:errorMessage userInfo:error.userInfo];
             }
             else
             {
                 [self enqueueRetryMonitor];
             }
         }];
}

-(void)enqueueRetryMonitor
{
    if (self.deltaSec < MAX_RETRY_SEC)
    {
        [self tryEnqueue];
        
        [NSThread sleepForTimeInterval:self.deltaSec];
        self.deltaSec = self.deltaSec * 2;
    }
    else
    {
        self.deltaSec = INITIAL_WAIT_RETRY_SEC;
        self.requestInProgress = NO;
        @throw [NSException exceptionWithName:@"QueueITUnavailableException" reason:@"QueueIT service is currently unavailable. Please, contact Queue-IT support for assistance" userInfo:nil];
    }
}

-(NSString*)convertTtlMinutesToSecondsString:(int)ttlMinutes
{
    long currentTime = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
    int secondsToAdd = ttlMinutes * 60.0;
    long timeStapm = currentTime + secondsToAdd;
    NSString* urlTtlString = [NSString stringWithFormat:@"%li", timeStapm];
    return urlTtlString;
}

-(void) raiseQueuePassed
{
    [self.cache clear];
    
    self.isInQueue = NO;
    self.requestInProgress = NO;
    [self.queuePassedDelegate notifyYourTurn];
}

-(void) raiseQueueViewWillOpen
{
    self.isInQueue = YES;
    [self.queueViewWillOpenDelegate notifyQueueViewWillOpen];
}

-(void) raiseQueueDisabled
{
    [self.queueDisabledDelegate notifyQueueDisabled];
}

-(void)updateQueuePageUrl:(NSString *)queuePageUrl
{
    if (![self.cache isEmpty]) {
        NSString* urlTtlString = [self.cache getUtlTtl];
        NSString* targetUrl = [self.cache getTargetUrl];
        [self.cache update:queuePageUrl urlTTL:urlTtlString targetUrl:targetUrl];
    }
}

@end