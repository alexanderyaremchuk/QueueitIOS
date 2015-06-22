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
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* queueUrlCached = [defaults stringForKey:@"QUEUE_URL"];
        
        if (queueUrlCached)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showQueue:host queueUrl:queueUrlCached];
            });
        }
        else
        {
            [self tryEnqueue:host customerId:customerId eventOrAliasId:eventOrAliasId];
        }
    }
    return self;
}

-(void)showQueue:(UIViewController*)host queueUrl:(NSString*)queueUrl{
    QueueITViewController *queueVC = [[QueueITViewController alloc] initWithHost:host
                                                                     queueEngine:self
                                                                        queueUrl:queueUrl];
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
         
         if (queueStatus.requeryInterval > 0)
         {
             dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 [NSThread sleepForTimeInterval:queueStatus.requeryInterval];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self tryEnqueue:host customerId:customerId eventOrAliasId:eventOrAliasId];
                 });
             });
         }
         else
         {
             [self showQueue:host queueUrl:queueStatus.queueUrlString];
             [self updateCache:queueStatus.queueUrlString];
         }
     }
        failure:^(NSError *error)
     {
     }];
}

-(void)updateCache:(NSString*)queueUrl{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:queueUrl forKey:@"QUEUE_URL"];
    [defaults synchronize];
}

-(void) notifyYourTurn:(Turn *)turn
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QUEUE_URL"];
    
    NSString* message = @"You are through the queue now.";
    NSLog(@"%@", message);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your turn" message: message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


//TODO: after the YourTurn event has been fired here event listener is invoked and begins to check for a configured duration value (20 mins),
// if elapsed -> reset to call enqueue method again



@end