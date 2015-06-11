#import "Turn.h"

@implementation Turn

-(instancetype)initWithQueueNumber:(NSString*)queueNumebr
{
    if (self = [super init]) {
        self.queueNumber = queueNumebr;
    }
    
    return self;
}

@end
