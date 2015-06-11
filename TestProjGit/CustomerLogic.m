#import "CustomerLogic.h"

@implementation CustomerLogic

-(void) notifyYourTurn:(Turn *)turn
{
    NSLog(@"Your queue number is: %@", turn.queueNumber);
}

@end
