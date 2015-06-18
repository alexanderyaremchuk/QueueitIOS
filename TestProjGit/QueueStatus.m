#import "QueueStatus.h"

@implementation QueueStatus

-(instancetype)init:(NSString *)queueId queueUrl:(NSString *)queueUrlString{
    if(self = [super init]) {
        self.queueId = queueId;
        self.queueUrlString = queueUrlString;
    }
    
    return self;
}

@end
