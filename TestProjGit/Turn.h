#import <Foundation/Foundation.h>

@interface Turn : NSObject

@property (nonatomic, strong) NSString* queueNumber;
@property (nonatomic, strong) NSString* customerId;
@property (nonatomic, strong) NSString* eventId;

-(instancetype)initWithQueueNumber:(NSString*)queueNumber customerId:(NSString*)customerId eventId:(NSString*)eventId;

@end
