#import <Foundation/Foundation.h>

@interface QueueStatus : NSObject

@property (nonatomic, strong) NSString* queueId;
@property (nonatomic, strong)NSString* queueUrlString;
@property (nonatomic, strong)NSString* requeryInterval;
@property (nonatomic, strong)NSString* errorMessage;

-(instancetype)init:(NSString*)queueId
           queueUrl:(NSString*)queueUrlString
    requeryInterval:(NSString*)requeryInterval
       errorMessage:(NSString*)errorMessage;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
