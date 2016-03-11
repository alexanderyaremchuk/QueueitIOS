#import <Foundation/Foundation.h>

@interface QueueCache : NSObject

+ (QueueCache *)instance:(NSString *)customerId eventId:(NSString*)eventId;
-(BOOL)isEmpty;
-(NSString*) getUtlTtl;
-(NSString*) getQueueUrl;
-(NSString*) getTargetUrl;
-(NSString*) getQueueId;
-(void)update:(NSString*)queueUrl urlTTL:(NSString*)urlTtlString targetUrl:(NSString*)targetUrl queueId:(NSString*) queueId;
-(void)clear;

@end
