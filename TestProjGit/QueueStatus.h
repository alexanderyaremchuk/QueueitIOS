#import <Foundation/Foundation.h>

@interface QueueStatus : NSObject

@property (nonatomic, strong) NSString* queueId;
@property (nonatomic, strong)NSString* queueUrlString;
@property int requeryInterval;
@property (nonatomic, strong)NSString* errorMessage;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
