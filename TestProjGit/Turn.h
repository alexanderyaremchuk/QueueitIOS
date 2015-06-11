#import <Foundation/Foundation.h>

@interface Turn : NSObject

@property (nonatomic, strong) NSString* queueNumber;

-(instancetype)initWithQueueNumber:(NSString*)queueNumber;

@end
