#import <UIKit/UIKit.h>
#import "QueueITEngine.h"
#import "QueueITViewController.h"

@implementation QueueITEngine

-(instancetype)initWithHost:(UIViewController *)host{
    self = [super init];
    if(self) {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:2.0f];
            dispatch_async(dispatch_get_main_queue(), ^{
                QueueITViewController *queueVC = [[QueueITViewController alloc] initWithHost:host queueEngine:self];
                [host presentModalViewController:queueVC animated:YES];
            });
        });
    }
    return self;
}

@end
