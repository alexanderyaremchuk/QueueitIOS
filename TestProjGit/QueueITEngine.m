#import <UIKit/UIKit.h>
#import "QueueITEngine.h"
#import "QueueITViewController.h"
#import "QueueService.h"
#import "QueueStatus.h"
#import "IOSUtils.h"

@interface QueueITEngine()<QueuePassedDelegate>
@end

@implementation QueueITEngine

-(instancetype)initWithHost:(UIViewController *)host customerId:(NSString*)customerId eventOrAliasId:(NSString*)eventOrAliasId
{
    self = [super init];
    if(self) {
        self.queuePassedDelegate = self;
        
        NSString * key = [NSString stringWithFormat:@"%@-%@",customerId, eventOrAliasId];
        
        //[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* queueUrlCached = [defaults stringForKey:key];
        
        if (queueUrlCached)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showQueue:host queueUrl:queueUrlCached customerId:customerId eventId:eventOrAliasId];
            });
        }
        else
        {
            [self tryEnqueue:host customerId:customerId eventOrAliasId:eventOrAliasId];
        }
    }
    return self;
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
             NSLog(@"queueUrl: %@, requeryInterval: %i", queueStatus.queueUrlString, queueStatus.requeryInterval);
             
             if (queueStatus.queueId != (id)[NSNull null] && queueStatus.queueUrlString == (id)[NSNull null] && queueStatus.requeryInterval == 0) //SafetyNet case -> do nothing
             {
             }
             else if (queueStatus.queueId != (id)[NSNull null] && queueStatus.queueUrlString != (id)[NSNull null] && queueStatus.requeryInterval == 0) //InQueue case -> show queue page
             {
                 [self showQueue:host queueUrl:queueStatus.queueUrlString customerId:customerId eventId:eventOrAliasId];
                 [self updateCache:queueStatus.queueUrlString urlTTL:queueStatus.queueUrlTTL customerId:customerId eventId:eventOrAliasId];
             }
             else if (queueStatus.queueId == (id)[NSNull null] && queueStatus.queueUrlString != (id)[NSNull null] && queueStatus.requeryInterval == 0) //Idle case -> show queue page
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
        }];
}

-(void)updateCache:(NSString*)queueUrl urlTTL:(int)queueUrlTTL customerId:(NSString*)customerId eventId:(NSString*)eventId{
    NSString * key = [NSString stringWithFormat:@"%@-%@",customerId, eventId];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:queueUrl forKey:key];
    [defaults synchronize];
}

-(void) notifyYourTurn:(Turn *)turn
{
    NSString * key = [NSString stringWithFormat:@"%@-%@", turn.customerId, turn.eventId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    
    NSString* message = @"You are through the queue now.";
    NSLog(@"%@", message);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your turn" message: message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


//TODO: after the YourTurn event has been fired here event listener is invoked and begins to check for a configured duration value (20 mins),
// if elapsed -> reset to call enqueue method again



@end