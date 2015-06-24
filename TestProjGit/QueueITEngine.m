#import <UIKit/UIKit.h>
#import "QueueITEngine.h"
#import "QueueITViewController.h"
#import "QueueService.h"
#import "QueueStatus.h"
#import "IOSUtils.h"

@interface QueueITEngine()
@property (nonatomic, strong)UIViewController* host;
@property (nonatomic, strong)NSString* customerId;
@property (nonatomic, strong)NSString* eventId;
@end

@implementation QueueITEngine

-(instancetype)initWithHost:(UIViewController *)host customerId:(NSString*)customerId eventOrAliasId:(NSString*)eventOrAliasId
{
    self = [super init];
    if(self) {
        self.host = host;
        self.customerId = customerId;
        self.eventId = eventOrAliasId;
    }
    return self;
}

-(void)run
{
    NSString * key = [NSString stringWithFormat:@"%@-%@",self.customerId, self.eventId];
    
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* queueUrlCached = [defaults stringForKey:key];
    
    if (queueUrlCached)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showQueue:self.host queueUrl:queueUrlCached customerId:self.customerId eventId:self.eventId];
        });
    }
    else
    {
        [self tryEnqueue:self.host customerId:self.customerId eventOrAliasId:self.eventId];
    }
}

-(void)showQueue:(UIViewController*)host queueUrl:(NSString*)queueUrl customerId:(NSString*)customerId eventId:(NSString*)eventId
{
    QueueITViewController *queueVC = [[QueueITViewController alloc] initWithHost:host
                                                                     queueEngine:self
                                                                        queueUrl:queueUrl
                                                                      customerId:customerId eventId:eventId];
    [host presentModalViewController:queueVC animated:YES];
}

-(void)tryEnqueue:(UIViewController *)host customerId:(NSString*)customerId eventOrAliasId:(NSString*)eventOrAliasId
{
    NSString* userId = [IOSUtils getUserId];
    NSString* userAgent = [IOSUtils getUserAgent];
    NSString* appType = @"iOS";
    
    QueueService* qs = [QueueService sharedInstance];
    [qs enqueue:customerId
 eventOrAliasId:eventOrAliasId
         userId:userId userAgent:userAgent
        appType:appType
        success:^(QueueStatus *queueStatus)
        {
             if (queueStatus.errorType != (id)[NSNull null])
             {
                 if ([queueStatus.errorType isEqualToString:@"Configuration"])//ISSUE: when incorrect eventId is provided -> Runtime error type is returned instead of Config.
                 {
                     NSException *e = [NSException exceptionWithName:@"ConfigurationException" reason:queueStatus.errorMessage userInfo:nil];
                     @throw e;
                 }
                 if ([queueStatus.errorType isEqualToString:@"Runtime"])//ISSUE: when incorrect eventId is provided -> Runtime error type is returned instead of Config.
                 {
                     NSException *e = [NSException exceptionWithName:@"RuntimeException" reason:queueStatus.errorMessage userInfo:nil];
                     @throw e;
                 }
                 //TODO: add 1 more else ifs for 1 more errorTypes and throw custom exceptions
             }
             
             NSLog(@"queueUrl: %@, requeryInterval: %i", queueStatus.queueUrlString, queueStatus.requeryInterval);
             
             if (queueStatus.queueId != (id)[NSNull null] && queueStatus.queueUrlString == (id)[NSNull null] && queueStatus.requeryInterval == 0) //SafetyNet -> do nothing
             {
             }
             else if (queueStatus.queueId != (id)[NSNull null] && queueStatus.queueUrlString != (id)[NSNull null] && queueStatus.requeryInterval == 0) //InQueue -> show queue page
             {
                 [self showQueue:host queueUrl:queueStatus.queueUrlString customerId:customerId eventId:eventOrAliasId];
                 [self updateCache:queueStatus.queueUrlString urlTTL:queueStatus.queueUrlTTL customerId:customerId eventId:eventOrAliasId];
             }
             else if (queueStatus.queueId == (id)[NSNull null] && queueStatus.queueUrlString != (id)[NSNull null] && queueStatus.requeryInterval == 0) //Idle -> show queue page
             {
                 [self showQueue:host queueUrl:queueStatus.queueUrlString customerId:customerId eventId:eventOrAliasId];
             }
             else if (queueStatus.requeryInterval > 0) //DisableEvent case -> continue polling at requeryInterval
             {
                 dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     [NSThread sleepForTimeInterval:queueStatus.requeryInterval];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self tryEnqueue:host customerId:customerId eventOrAliasId:eventOrAliasId];
                     });
                 });
             }
        }
        failure:^(NSError *error)
        {
         //TODO: for any not 200 http status codes throw custom exception
        }];
}

-(void)updateCache:(NSString*)queueUrl urlTTL:(int)queueUrlTTL customerId:(NSString*)customerId eventId:(NSString*)eventId{
    NSString * key = [NSString stringWithFormat:@"%@-%@",customerId, eventId];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:queueUrl forKey:key];
    [defaults synchronize];
}

-(void) raiseQueuePassed:(NSString *)queueId
{
    Turn* turn = [[Turn alloc]init:queueId];
    [self.queuePassedDelegate notifyYourTurn:turn];
    
    NSString * key = [NSString stringWithFormat:@"%@-%@", self.customerId, self.eventId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

@end