#import "CustomerLogic.h"

@implementation CustomerLogic

-(void) notifyYourTurn:(Turn *)turn
{
    NSLog(@"Your queue number is: %@", turn.queueNumber);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your turn"
                                                    message: [NSString stringWithFormat: @"You are through the queue. Your queue number is: %@", turn.queueNumber]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];

}

@end
