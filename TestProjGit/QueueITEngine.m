#import <UIKit/UIKit.h>
#import "QueueITEngine.h"
#import "QueueITViewController.h"
#import "QueueService.h"
#import "QueueStatus.h"
#import "IOSUtils.h"

@implementation QueueITEngine

-(instancetype)initWithHost:(UIViewController *)host
                 customerId:(NSString*)customerId
             eventOrAliasId:(NSString*)eventOrAliasId
{
    self = [super init];
    if(self) {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //__weak typeof(self) weakSelf = self;
                
                NSString* userId = [IOSUtils getUserId];
                NSString* userAgent = [IOSUtils getUserAgent];
                
                [[QueueService sharedInstance] enqueue:customerId
                                        eventOrAliasId:eventOrAliasId
                                                userId:userId
                                             userAgent:userAgent
                                               success:^(QueueStatus *queueStatus)
                                               {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       QueueITViewController *queueVC = [[QueueITViewController alloc] initWithHost:host
                                                                                                                        queueEngine:self
                                                                                                                           queueUrl:queueStatus.queueUrlString];
                                                       [host presentModalViewController:queueVC animated:YES];
                                                   });
                                               }
                                               failure:^(NSError *error)
                                               {
                                               }];
            });
        });
    }
    return self;
}



@end