#import <Foundation/Foundation.h>

@interface QueueStatus : NSObject

@property (nonatomic, strong) NSString* queueId;
@property (nonatomic, strong)NSString* queueUrlString;

-(instancetype)init:(NSString*)queueId
           queueUrl:(NSString*)queueUrlString;

@end
