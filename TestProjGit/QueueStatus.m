#import "QueueStatus.h"

NSString * const KEY_QUEUE_ID = @"QueueId";
NSString * const KEY_QUEUE_URL = @"QueueUrl";
NSString * const KEY_REQUERY_INTERVAl = @"AskAgainInMinutes";
NSString * const KEY_ERROR_MESSAGE = @"ErrorMessage";

@implementation QueueStatus

-(instancetype)init:(NSString *)queueId
           queueUrl:(NSString *)queueUrlString
    requeryInterval:(NSString*)requeryInterval
       errorMessage:(NSString*)errorMessage
{
    if(self = [super init]) {
        self.queueId = queueId;
        self.queueUrlString = queueUrlString;
        self.requeryInterval = requeryInterval;
        self.errorMessage = errorMessage;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [self init:dictionary[KEY_QUEUE_ID]
             queueUrl:dictionary[KEY_QUEUE_URL]
      requeryInterval:dictionary[KEY_REQUERY_INTERVAl]
         errorMessage:dictionary[KEY_ERROR_MESSAGE]];
}

@end
