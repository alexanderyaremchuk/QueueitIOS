#import "Turn.h"

@implementation Turn

-(instancetype)initWithQueueNumber:(NSString*)queueNumebr customerId:(NSString *)customerId eventId:(NSString *)eventId
{
    if (self = [super init]) {
        self.queueNumber = queueNumebr;
        self.customerId = customerId;
        self.eventId = eventId;
    }
    
    return self;
}

@end
